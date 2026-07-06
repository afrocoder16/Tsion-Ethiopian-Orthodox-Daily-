import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/sign_in_guard.dart';
import '../data/mezmur_library.dart';

part 'mezmur_screen_art.dart';
part 'mezmur_screen_sections.dart';
part 'mezmur_screen_player.dart';
part 'mezmur_screen_subscreens.dart';


// ── Palette — Ethiopian Orthodox manuscript aesthetic ────────────────────────
// Parchment + sepia ink + aged gold + liturgical oxblood
const _screenBackground = Color(0xFFFBF5E1); // parchment surface
const _panelBackground = Color(0xFFF5ECD4); // parchment card
const _cardBackground = Color(0xFFFDF8E8); // lightest card
const _oxblood = Color(0xFF6B2222); // primary liturgical red
const _oxbloodDeep = Color(0xFF4A1414); // deep burgundy
const _gold = Color(0xFFB8914C); // aged gold
const _goldDeep = Color(0xFF8A6A2E); // ochre gold
const _ink = Color(0xFF2B1D10); // primary text
const _inkSoft = Color(0xFF4E3A25); // body text
const _mutedText = Color(0xFF7A664D); // muted / labels
const _outlineColor = Color(0x23432913); // hairline
const _divider = Color(0x142B1D10); // divider

// Legacy alias so unchanged code keeps compiling
const _accent = _oxblood;

// ── Helpers ──────────────────────────────────────────────────────────────────
String _formatDuration(Duration d) {
  final m = (d.inSeconds ~/ 60).toString();
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String _formatCountdown(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

// ── Instrument + artwork painters ───────────────────────────────────────────

// Deterministic artwork variant from a seed string (0–4)
int _artVariant(String seed) {
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0xFFFFFFFF;
  }
  return h % 5;
}

// Generative meskel-cross tile — manuscript style
// ── Browse filter enum ────────────────────────────────────────────────────────
enum _BrowseFilter { all, artists, albums, tracks, compilations }

// ── Root widget ───────────────────────────────────────────────────────────────
class MezmurScreen extends StatelessWidget {
  const MezmurScreen({super.key});

  @override
  Widget build(BuildContext context) => const _MezmurLibraryScreen();
}

class _MezmurLibraryScreen extends ConsumerStatefulWidget {
  const _MezmurLibraryScreen();

  @override
  ConsumerState<_MezmurLibraryScreen> createState() =>
      _MezmurLibraryScreenState();
}

class _MezmurLibraryScreenState extends ConsumerState<_MezmurLibraryScreen> {
  static const _repository = MezmurLibraryRepository();

  // Audio
  final AudioPlayer _player = AudioPlayer()
    ..setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
          isSpeakerphoneOn: false,
          stayAwake: true,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {},
        ),
      ),
    );
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<String, String> _localAssetCache = {};
  final Random _random = Random();

  late final Future<MezmurLibrary> _libraryFuture;
  MezmurLibrary? _cachedLibrary;

  // Playback state
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  String? _loadingTrackId;

  // Queue
  List<MezmurTrack> _playQueue = const [];
  int _queueIndex = -1;
  String _queueLabel = 'Library Queue';
  bool _playerExpanded = false;
  bool _shuffleEnabled = false;
  bool _repeatEnabled = false;
  double _playerDragOffset = 0.0;

  // Browse / search
  String _query = '';
  _BrowseFilter _filter = _BrowseFilter.all;
  String? _focusedArtist;
  String? _focusedAlbum;
  bool _focusedCompilation = false;

  // Persistent features
  Set<String> _likedTrackIds = {};
  List<String> _recentlyPlayedIds = [];
  // Playlists: name → ordered list of track IDs
  Map<String, List<String>> _playlists = {};

  // Playback extras
  double _playbackSpeed = 1.0;
  Timer? _sleepTimer;
  int? _sleepTimerRemainingSeconds;

  // ── Computed ────────────────────────────────────────────────────────────────
  MezmurTrack? get _currentTrack =>
      _queueIndex >= 0 && _queueIndex < _playQueue.length
      ? _playQueue[_queueIndex]
      : null;

  bool get _hasNext =>
      _playQueue.isNotEmpty &&
      _queueIndex >= 0 &&
      _queueIndex < _playQueue.length - 1;

  bool _isLiked(MezmurTrack t) => _likedTrackIds.contains(t.id);

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _libraryFuture = _repository.load();
    _loadPersistedState();
    _subscriptions.addAll([
      _player.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() => _playerState = state);
      }),
      _player.onPositionChanged.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
      }),
      _player.onDurationChanged.listen((dur) {
        if (!mounted) return;
        setState(() => _duration = dur);
      }),
      _player.onPlayerComplete.listen((_) {
        unawaited(_handleTrackCompleted());
      }),
    ]);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final likedRaw = prefs.getString('mezmur_liked_ids');
    final recentRaw = prefs.getString('mezmur_recently_played_ids');
    final playlistRaw = prefs.getString('mezmur_playlists');
    if (!mounted) return;
    setState(() {
      if (likedRaw != null) {
        _likedTrackIds = Set<String>.from(
          (jsonDecode(likedRaw) as List<dynamic>).cast<String>(),
        );
      }
      if (recentRaw != null) {
        _recentlyPlayedIds = List<String>.from(
          (jsonDecode(recentRaw) as List<dynamic>).cast<String>(),
        );
      }
      if (playlistRaw != null) {
        final decoded = jsonDecode(playlistRaw) as Map<String, dynamic>;
        _playlists = decoded.map(
          (k, v) => MapEntry(k, List<String>.from(v as List<dynamic>)),
        );
      }
    });
  }

  Future<void> _persistPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mezmur_playlists', jsonEncode(_playlists));
  }

  void _createPlaylist(String name) {
    if (name.trim().isEmpty || _playlists.containsKey(name.trim())) return;
    setState(() => _playlists = {..._playlists, name.trim(): []});
    _persistPlaylists();
  }

  void _deletePlaylist(String name) {
    final updated = Map<String, List<String>>.from(_playlists)..remove(name);
    setState(() => _playlists = updated);
    _persistPlaylists();
  }

  void _addTrackToPlaylist(String playlistName, MezmurTrack track) {
    final list = List<String>.from(_playlists[playlistName] ?? []);
    if (!list.contains(track.id)) {
      list.add(track.id);
      setState(() => _playlists = {..._playlists, playlistName: list});
      _persistPlaylists();
    }
  }

  void _removeTrackFromPlaylist(String playlistName, String trackId) {
    final list = List<String>.from(_playlists[playlistName] ?? [])
      ..remove(trackId);
    setState(() => _playlists = {..._playlists, playlistName: list});
    _persistPlaylists();
  }

  Future<void> _toggleLike(MezmurTrack track) async {
    setState(() {
      if (_likedTrackIds.contains(track.id)) {
        _likedTrackIds = Set.from(_likedTrackIds)..remove(track.id);
      } else {
        _likedTrackIds = Set.from(_likedTrackIds)..add(track.id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'mezmur_liked_ids',
      jsonEncode(_likedTrackIds.toList()),
    );
  }

  Future<void> _recordRecentlyPlayed(MezmurTrack track) async {
    final updated = [
      track.id,
      ..._recentlyPlayedIds.where((id) => id != track.id),
    ];
    if (updated.length > 20) updated.removeRange(20, updated.length);
    setState(() => _recentlyPlayedIds = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mezmur_recently_played_ids', jsonEncode(updated));
  }

  // ── Sleep timer ─────────────────────────────────────────────────────────────
  void _startSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() => _sleepTimerRemainingSeconds = minutes * 60);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _sleepTimerRemainingSeconds;
      if (remaining == null || remaining <= 0) {
        _cancelSleepTimer();
        _player.pause();
        return;
      }
      setState(() => _sleepTimerRemainingSeconds = remaining - 1);
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (mounted) setState(() => _sleepTimerRemainingSeconds = null);
  }

  // ── Speed ────────────────────────────────────────────────────────────────────
  Future<void> _setPlaybackSpeed(double speed) async {
    await _player.setPlaybackRate(speed);
    setState(() => _playbackSpeed = speed);
  }

  // ── Playback ─────────────────────────────────────────────────────────────────
  Future<void> _handleTrackCompleted() async {
    final advanced = await _playNextTrack(fromCompletion: true);
    if (!advanced && mounted) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    }
  }

  Future<void> _playTrack(
    MezmurTrack track, {
    List<MezmurTrack>? queue,
    String? queueLabel,
    bool openPlayer = true,
  }) async {
    final allowed = await ref
        .read(signInGuardProvider)
        .ensureSignedIn(context, feature: SignInFeature.mezmurPlayback);
    if (!allowed) {
      return;
    }

    if (queue != null && queue.isNotEmpty) {
      final qi = queue.indexWhere((t) => t.id == track.id);
      setState(() {
        _playQueue = List<MezmurTrack>.from(queue);
        _queueIndex = qi >= 0 ? qi : 0;
        _queueLabel = queueLabel ?? _queueLabel;
      });
    } else if (_playQueue.isEmpty) {
      setState(() {
        _playQueue = [track];
        _queueIndex = 0;
      });
    } else {
      final ei = _playQueue.indexWhere((t) => t.id == track.id);
      if (ei >= 0) setState(() => _queueIndex = ei);
    }

    setState(() {
      _loadingTrackId = track.id;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    try {
      await _player.stop();
      final localPath = await _materializeAsset(track.assetPath);
      await _player.play(DeviceFileSource(localPath));
      if (_playbackSpeed != 1.0) await _player.setPlaybackRate(_playbackSpeed);
      unawaited(_recordRecentlyPlayed(track));
      if (!mounted) return;
      setState(() {
        if (openPlayer) _playerExpanded = true;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play ${track.title}: $error')),
      );
    } finally {
      if (mounted) setState(() => _loadingTrackId = null);
    }
  }

  Future<void> _togglePlayback() async {
    final t = _currentTrack;
    if (t == null) return;
    final allowed = await ref
        .read(signInGuardProvider)
        .ensureSignedIn(context, feature: SignInFeature.mezmurPlayback);
    if (!allowed) {
      return;
    }
    try {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
      } else if (_playerState == PlayerState.paused) {
        await _player.resume();
      } else {
        await _playTrack(t);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Playback error: $error')));
    }
  }

  Future<void> _seekTo(double value) async {
    await _player.seek(Duration(milliseconds: value.round()));
  }

  Future<bool> _playQueueIndex(int index) async {
    if (index < 0 || index >= _playQueue.length) return false;
    await _playTrack(
      _playQueue[index],
      queue: _playQueue,
      queueLabel: _queueLabel,
    );
    return true;
  }

  Future<bool> _playNextTrack({bool fromCompletion = false}) async {
    if (_playQueue.isEmpty || _queueIndex < 0) return false;
    int nextIndex;
    if (_shuffleEnabled && _playQueue.length > 1) {
      do {
        nextIndex = _random.nextInt(_playQueue.length);
      } while (nextIndex == _queueIndex);
    } else {
      nextIndex = _queueIndex + 1;
      if (nextIndex >= _playQueue.length) {
        if (!_repeatEnabled) return false;
        nextIndex = 0;
      }
    }
    if (!fromCompletion && !_repeatEnabled && !_shuffleEnabled && !_hasNext) {
      return false;
    }
    return _playQueueIndex(nextIndex);
  }

  Future<void> _playPreviousTrack() async {
    if (_currentTrack == null) return;
    if (_position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    int prev = _queueIndex - 1;
    if (prev < 0) {
      if (!_repeatEnabled) {
        await _player.seek(Duration.zero);
        return;
      }
      prev = _playQueue.length - 1;
    }
    await _playQueueIndex(prev);
  }

  void _addTrackNext(MezmurTrack track) {
    if (_currentTrack == null) {
      setState(() {
        _playQueue = [track];
        _queueIndex = 0;
        _queueLabel = 'Manual Queue';
      });
      return;
    }
    final q = List<MezmurTrack>.from(_playQueue);
    q.removeWhere((t) => t.id == track.id && t.id != _currentTrack!.id);
    q.insert(_queueIndex + 1, track);
    setState(() {
      _playQueue = q;
      _queueLabel = 'Manual Queue';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${track.title} will play next.')));
  }

  void _addTrackToQueue(MezmurTrack track) {
    final q = List<MezmurTrack>.from(_playQueue);
    q.removeWhere((t) => t.id == track.id && t.id != _currentTrack?.id);
    q.add(track);
    setState(() {
      _playQueue = q;
      if (_queueIndex < 0) _queueIndex = 0;
      _queueLabel = 'Manual Queue';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${track.title} added to queue.')));
  }

  // ── Asset materialisation ───────────────────────────────────────────────────
  Future<String> _materializeAsset(String assetPath) async {
    final cached = _localAssetCache[assetPath];
    if (cached != null && await File(cached).exists()) return cached;

    final externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception('External storage is not available on this device.');
    }

    const libraryPrefix = 'assets/mezmuer/library/';
    final relativePath = assetPath.startsWith(libraryPrefix)
        ? assetPath.substring(libraryPrefix.length)
        : assetPath;
    final localFile = File(
      '${externalDir.path}${Platform.pathSeparator}mezmuer${Platform.pathSeparator}library${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}',
    );
    if (!await localFile.exists()) {
      throw Exception(
        'Mezmur library is not synced to this device yet. Run tools/push_mezmur_library_to_android.ps1 after installing the app.',
      );
    }
    _localAssetCache[assetPath] = localFile.path;
    return localFile.path;
  }

  // ── Focus helpers ────────────────────────────────────────────────────────────
  void _openArtist(String name) {
    final library = _cachedLibrary;
    if (library == null) return;
    final artistTracks = library.tracks
        .where((t) => !t.isCompilation && t.artist == name)
        .toList();
    final albums = library.albumSummaries(artistTracks);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => _CantorDetailScreen(
          name: name,
          tracks: artistTracks,
          albums: albums,
          currentTrackId: _currentTrack?.id,
          likedTrackIds: _likedTrackIds,
          onPlayAll: (tracks) =>
              _playTrack(tracks.first, queue: tracks, queueLabel: name),
          onPlayTrack: (track) =>
              _playTrack(track, queue: artistTracks, queueLabel: name),
          onLike: (track) => _toggleLike(track),
          onMore: (track, queue) => _showTrackActions(track, queue),
        ),
      ),
    );
  }

  void _openAlbum(MezmurAlbumSummary album) {
    setState(() {
      _focusedArtist = album.artist;
      _focusedAlbum = album.name;
      _focusedCompilation = false;
      _filter = _BrowseFilter.tracks;
    });
  }

  void _openCompilation(String name) {
    setState(() {
      _focusedArtist = null;
      _focusedAlbum = name;
      _focusedCompilation = true;
      _filter = _BrowseFilter.tracks;
    });
  }

  void _clearFocus() {
    setState(() {
      _focusedArtist = null;
      _focusedAlbum = null;
      _focusedCompilation = false;
    });
  }

  List<MezmurTrack> _applyFocus(List<MezmurTrack> tracks) {
    return tracks
        .where((t) {
          if (_focusedCompilation) {
            if (!t.isCompilation) return false;
            return _focusedAlbum == null || t.album == _focusedAlbum;
          }
          if (_focusedArtist != null && t.artist != _focusedArtist) {
            return false;
          }
          if (_focusedAlbum != null && t.album != _focusedAlbum) return false;
          return true;
        })
        .toList(growable: false);
  }

  String _queueContextLabel() {
    if (_focusedCompilation && _focusedAlbum != null) return _focusedAlbum!;
    if (_focusedArtist != null && _focusedAlbum != null) {
      return '$_focusedArtist / $_focusedAlbum';
    }
    if (_focusedArtist != null) return _focusedArtist!;
    if (_query.trim().isNotEmpty) return 'Search Results';
    return 'All Tracks';
  }

  bool _isCurrentTrack(MezmurTrack t) => _currentTrack?.id == t.id;

  void _closeExpandedPlayer() {
    setState(() {
      _playerExpanded = false;
      _playerDragOffset = 0;
    });
  }

  // ── Queue bottom sheet ───────────────────────────────────────────────────────
  void _showQueueSheet() {
    if (_playQueue.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panelBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const _MeskelCrossIcon(size: 14, color: _gold),
                  const SizedBox(width: 8),
                  Text(
                    'Queue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _queueLabel,
                style: const TextStyle(color: _mutedText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: StatefulBuilder(
                  builder: (ctx, setSheetState) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: _playQueue.length,
                    itemBuilder: (ctx, i) {
                      final t = _playQueue[i];
                      final isCurrent = i == _queueIndex;
                      return Dismissible(
                        key: ValueKey('${t.id}-$i'),
                        direction: isCurrent
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: _oxblood.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: _oxblood,
                          ),
                        ),
                        onDismissed: (_) {
                          final newQueue = List<MezmurTrack>.from(_playQueue)
                            ..removeAt(i);
                          setState(() {
                            _playQueue = newQueue;
                            if (_queueIndex > i) _queueIndex--;
                          });
                          setSheetState(() {});
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          leading: _TrackArt(
                            seed: t.title,
                            size: 40,
                            radius: 10,
                          ),
                          title: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent ? _oxblood : _ink,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          subtitle: Text(
                            '${t.artist} · ${t.album}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isCurrent
                              ? const Icon(
                                  Icons.equalizer,
                                  color: _oxblood,
                                  size: 18,
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: _mutedText,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    final newQueue = List<MezmurTrack>.from(
                                      _playQueue,
                                    )..removeAt(i);
                                    setState(() {
                                      _playQueue = newQueue;
                                      if (_queueIndex > i) _queueIndex--;
                                    });
                                    setSheetState(() {});
                                  },
                                ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _playQueueIndex(i);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Track actions sheet ──────────────────────────────────────────────────────
  void _showTrackActions(MezmurTrack track, List<MezmurTrack> queueContext) {
    final liked = _isLiked(track);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panelBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              const SizedBox(height: 14),
              Row(
                children: [
                  _TrackArt(seed: track.title, size: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${track.artist} · ${track.album}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: _divider, height: 1),
              const SizedBox(height: 4),
              const SizedBox(height: 8),
              _ActionTile(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                label: liked ? 'Remove from Liked Songs' : 'Add to Liked Songs',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _toggleLike(track);
                },
              ),
              _ActionTile(
                icon: Icons.play_arrow_rounded,
                label: 'Play from here',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _playTrack(
                    track,
                    queue: queueContext,
                    queueLabel: _queueContextLabel(),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.skip_next_rounded,
                label: 'Play next',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _addTrackNext(track);
                },
              ),
              _ActionTile(
                icon: Icons.queue_music_rounded,
                label: 'Add to queue',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _addTrackToQueue(track);
                },
              ),
              if (!track.isCompilation)
                _ActionTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Go to artist',
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _openArtist(track.artist);
                  },
                ),
              _ActionTile(
                icon: Icons.album_outlined,
                label: 'Go to album',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  if (track.isCompilation) {
                    _openCompilation(track.album);
                  } else {
                    _openAlbum(
                      MezmurAlbumSummary(
                        name: track.album,
                        artist: track.artist,
                        trackCount: 0,
                        isCompilation: false,
                      ),
                    );
                  }
                },
              ),
              _ActionTile(
                icon: Icons.playlist_add_rounded,
                label: 'Add to playlist',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showAddToPlaylistSheet(track);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Speed sheet ──────────────────────────────────────────────────────────────
  void _showSpeedSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panelBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _MeskelCrossIcon(size: 14, color: _gold),
                  SizedBox(width: 8),
                  Text(
                    'Playback Speed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [0.5, 0.75, 1.0, 1.25, 1.5].map((speed) {
                  final selected = _playbackSpeed == speed;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _setPlaybackSpeed(speed);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: selected ? _oxblood : _cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? _oxblood : _outlineColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          color: selected ? _screenBackground : _inkSoft,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sleep timer sheet ────────────────────────────────────────────────────────
  void _showSleepTimerSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panelBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 18),
              Row(
                children: const [
                  _MeskelCrossIcon(size: 14, color: _gold),
                  SizedBox(width: 8),
                  Text(
                    'Sleep Timer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Playback will stop after the selected time.',
                style: TextStyle(color: _mutedText, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ...[15, 30, 45, 60].map(
                (minutes) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_rounded, color: _gold),
                  title: Text(
                    '$minutes minutes',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _inkSoft,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _startSleepTimer(minutes);
                  },
                ),
              ),
              if (_sleepTimerRemainingSeconds != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cancel_outlined, color: _oxblood),
                  title: Text(
                    'Cancel timer (${_formatCountdown(_sleepTimerRemainingSeconds!)} left)',
                    style: const TextStyle(
                      color: _oxblood,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _cancelSleepTimer();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Liked songs list screen ───────────────────────────────────────────────────
  void _showLikedSongsList(
    List<MezmurTrack> likedTracks,
    MezmurLibrary library,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => _TrackListScreen(
          title: 'Liked Songs',
          icon: Icons.favorite_rounded,
          tracks: likedTracks,
          currentTrackId: _currentTrack?.id,
          likedTrackIds: _likedTrackIds,
          onPlay: (track) {
            Navigator.of(ctx).pop();
            _playTrack(track, queue: likedTracks, queueLabel: 'Liked Songs');
          },
          onLike: (track) => _toggleLike(track),
          onMore: (track) {
            Navigator.of(ctx).pop();
            _showTrackActions(track, likedTracks);
          },
        ),
      ),
    );
  }

  // ── Add to playlist sheet ────────────────────────────────────────────────────
  void _showAddToPlaylistSheet(MezmurTrack track) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panelBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetHandle(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add to Playlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: _oxblood, size: 18),
                      label: const Text(
                        'New',
                        style: TextStyle(
                          color: _oxblood,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final name = await _promptPlaylistName();
                        if (name != null) {
                          _createPlaylist(name);
                          _addTrackToPlaylist(name, track);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to "$name"')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No playlists yet. Tap "New" to create one.',
                        style: TextStyle(color: _mutedText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...(_playlists.keys.toList()..sort()).map((name) {
                    final alreadyAdded = (_playlists[name] ?? []).contains(
                      track.id,
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _outlineColor),
                        ),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: _oxblood,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                        ),
                      ),
                      subtitle: Text(
                        '${(_playlists[name] ?? []).length} tracks',
                        style: const TextStyle(color: _mutedText, fontSize: 12),
                      ),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check_rounded, color: _oxblood)
                          : null,
                      onTap: alreadyAdded
                          ? null
                          : () {
                              _addTrackToPlaylist(name, track);
                              setSheetState(() {});
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added to "$name"')),
                              );
                            },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _promptPlaylistName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panelBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'New Playlist',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          cursorColor: _accent,
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: _mutedText),
            filled: true,
            fillColor: _screenBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _outlineColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'Create',
              style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Playlist screen ───────────────────────────────────────────────────────────
  void _showPlaylistScreen(MezmurLibrary library) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => _PlaylistScreen(
          playlists: _playlists,
          library: library,
          currentTrackId: _currentTrack?.id,
          likedTrackIds: _likedTrackIds,
          onCreatePlaylist: (name) => _createPlaylist(name),
          onDeletePlaylist: (name) => _deletePlaylist(name),
          onRemoveTrackFromPlaylist: (playlistName, trackId) =>
              _removeTrackFromPlaylist(playlistName, trackId),
          onPlayPlaylist: (playlistName, tracks) {
            Navigator.of(ctx).pop();
            _playTrack(tracks.first, queue: tracks, queueLabel: playlistName);
          },
          onPlayTrack: (track, queue) {
            Navigator.of(ctx).pop();
            final label = _playlists.entries
                .firstWhere(
                  (e) => e.value.contains(track.id),
                  orElse: () => const MapEntry('Playlist', []),
                )
                .key;
            _playTrack(track, queue: queue, queueLabel: label);
          },
          onLike: (track) => _toggleLike(track),
          onTrackMore: (track, queue) {
            Navigator.of(ctx).pop();
            _showTrackActions(track, queue);
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          !_playerExpanded &&
          _focusedArtist == null &&
          _focusedAlbum == null &&
          !_focusedCompilation,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_playerExpanded) {
            _closeExpandedPlayer();
          } else if (_focusedArtist != null ||
              _focusedAlbum != null ||
              _focusedCompilation) {
            _clearFocus();
          }
        }
      },
      child: Scaffold(
        backgroundColor: _screenBackground,
        appBar: AppBar(
          backgroundColor: _screenBackground,
          elevation: 0,
          title: const Text(
            'Mezmur Library',
            style: TextStyle(color: Colors.black87),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
        ),
        bottomNavigationBar: _currentTrack == null || _playerExpanded
            ? null
            : _MiniPlayerBar(
                track: _currentTrack!,
                playerState: _playerState,
                position: _position,
                duration: _duration,
                isLiked: _isLiked(_currentTrack!),
                onPlayPause: _togglePlayback,
                onNext: _playNextTrack,
                onLike: () => _toggleLike(_currentTrack!),
                onTap: () => setState(() => _playerExpanded = true),
              ),
        body: FutureBuilder<MezmurLibrary>(
          future: _libraryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: _accent),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load the mezmur library.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }

            final library = snapshot.data!;
            _cachedLibrary ??= library;
            final searched = library.filter(_query);
            final focused = _applyFocus(searched);

            final recentTracks = _recentlyPlayedIds
                .map(
                  (id) => library.tracks.where((t) => t.id == id).firstOrNull,
                )
                .whereType<MezmurTrack>()
                .toList();

            final likedTracks = library.tracks
                .where((t) => _likedTrackIds.contains(t.id))
                .toList();

            final artists = library.artistSummaries(searched);
            final albums = library.albumSummaries(searched);
            final compilations = library.compilationSummaries(searched);

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Greeting + search
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SearchField(
                              query: _query,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recently played
                    if (recentTracks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _RecentlyPlayedSection(
                          tracks: recentTracks,
                          currentTrackId: _currentTrack?.id,
                          onTap: (t) => _playTrack(
                            t,
                            queue: recentTracks,
                            queueLabel: 'Recently Played',
                          ),
                        ),
                      ),

                    // Liked songs card
                    if (likedTracks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: _LikedSongsCard(
                            count: likedTracks.length,
                            onTap: () =>
                                _showLikedSongsList(likedTracks, library),
                            onPlayAll: () {
                              final sorted = List<MezmurTrack>.from(likedTracks)
                                ..sort((a, b) {
                                  final c = a.artist.compareTo(b.artist);
                                  if (c != 0) return c;
                                  final d = a.album.compareTo(b.album);
                                  if (d != 0) return d;
                                  return a.trackNumber.compareTo(b.trackNumber);
                                });
                              _playTrack(
                                sorted.first,
                                queue: sorted,
                                queueLabel: 'Liked Songs',
                              );
                            },
                          ),
                        ),
                      ),

                    // Artists carousel
                    if (_query.isEmpty)
                      SliverToBoxAdapter(
                        child: _FeaturedArtistsCarousel(
                          artists: artists.take(10).toList(),
                          onTap: (a) => _openArtist(a.name),
                        ),
                      ),

                    // Albums carousel
                    if (_query.isEmpty)
                      SliverToBoxAdapter(
                        child: _AlbumsCarousel(
                          albums: albums.take(12).toList(),
                          onTap: (a) => _openAlbum(a),
                        ),
                      ),

                    // Compilations
                    if (_query.isEmpty && compilations.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _CompilationsSection(
                          compilations: compilations,
                          onTap: (c) => _openCompilation(c.name),
                        ),
                      ),

                    // Pinned filter bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _FilterBarDelegate(
                        filter: _filter,
                        focusedArtist: _focusedArtist,
                        focusedAlbum: _focusedAlbum,
                        focusedCompilation: _focusedCompilation,
                        playlistCount: _playlists.length,
                        onFilterChanged: (f) => setState(() => _filter = f),
                        onClearFocus: _clearFocus,
                        onLibraryTap: () => _showPlaylistScreen(library),
                      ),
                    ),

                    // Track / artist / album list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      sliver: _buildListSliver(
                        focused,
                        artists,
                        albums,
                        compilations,
                        library,
                      ),
                    ),
                  ],
                ),

                // Expanded player overlay
                if (_playerExpanded && _currentTrack != null)
                  GestureDetector(
                    onVerticalDragUpdate: (d) => setState(
                      () => _playerDragOffset = max(
                        0.0,
                        _playerDragOffset + d.delta.dy,
                      ),
                    ),
                    onVerticalDragEnd: (d) {
                      if (_playerDragOffset > 80 ||
                          (d.primaryVelocity ?? 0) > 400) {
                        _closeExpandedPlayer();
                      } else {
                        setState(() => _playerDragOffset = 0);
                      }
                    },
                    child: Transform.translate(
                      offset: Offset(0, _playerDragOffset),
                      child: _ExpandedPlayerOverlay(
                        track: _currentTrack!,
                        queueCount: _playQueue.length,
                        queueLabel: _queueLabel,
                        playerState: _playerState,
                        position: _position,
                        duration: _duration,
                        shuffleEnabled: _shuffleEnabled,
                        repeatEnabled: _repeatEnabled,
                        isLiked: _isLiked(_currentTrack!),
                        playbackSpeed: _playbackSpeed,
                        sleepTimerRemainingSeconds: _sleepTimerRemainingSeconds,
                        onClose: _closeExpandedPlayer,
                        onPlayPause: _togglePlayback,
                        onPrevious: _playPreviousTrack,
                        onNext: () => _playNextTrack(),
                        onSeek: _seekTo,
                        onQueue: _showQueueSheet,
                        onShuffle: () =>
                            setState(() => _shuffleEnabled = !_shuffleEnabled),
                        onRepeat: () =>
                            setState(() => _repeatEnabled = !_repeatEnabled),
                        onLike: () => _toggleLike(_currentTrack!),
                        onSpeed: _showSpeedSheet,
                        onSleepTimer: _showSleepTimerSheet,
                        onTrackActions: () =>
                            _showTrackActions(_currentTrack!, _playQueue),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListSliver(
    List<MezmurTrack> focused,
    List<MezmurArtistSummary> artists,
    List<MezmurAlbumSummary> albums,
    List<MezmurAlbumSummary> compilations,
    MezmurLibrary library,
  ) {
    // Determine which list to show based on filter
    final effectiveFilter =
        _focusedArtist != null || _focusedAlbum != null || _focusedCompilation
        ? _BrowseFilter.tracks
        : _filter;

    switch (effectiveFilter) {
      case _BrowseFilter.all:
      case _BrowseFilter.tracks:
        if (focused.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'No tracks matched this filter.'),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _TrackRow(
              track: focused[i],
              isCurrent: _isCurrentTrack(focused[i]),
              isPlaying:
                  _isCurrentTrack(focused[i]) &&
                  _playerState == PlayerState.playing,
              isLoading: _loadingTrackId == focused[i].id,
              isLiked: _isLiked(focused[i]),
              onTap: () => _playTrack(
                focused[i],
                queue: focused,
                queueLabel: _queueContextLabel(),
              ),
              onLike: () => _toggleLike(focused[i]),
              onMore: () => _showTrackActions(focused[i], focused),
            ),
            childCount: focused.length,
          ),
        );

      case _BrowseFilter.artists:
        if (artists.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'No artists matched this filter.'),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _ArtistListRow(
              artist: artists[i],
              onTap: () => _openArtist(artists[i].name),
            ),
            childCount: artists.length,
          ),
        );

      case _BrowseFilter.albums:
        if (albums.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'No albums matched this filter.'),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _AlbumListRow(
              album: albums[i],
              onTap: () => _openAlbum(albums[i]),
            ),
            childCount: albums.length,
          ),
        );

      case _BrowseFilter.compilations:
        if (compilations.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'No compilations matched this filter.'),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _AlbumListRow(
              album: compilations[i],
              onTap: () => _openCompilation(compilations[i].name),
            ),
            childCount: compilations.length,
          ),
        );
    }
  }
}
