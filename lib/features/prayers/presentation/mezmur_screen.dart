import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../data/mezmur_library.dart';

enum _MezmurBrowseMode {
  artists('Artists'),
  albums('Albums'),
  tracks('Tracks'),
  compilations('Compilations');

  const _MezmurBrowseMode(this.label);

  final String label;
}

class MezmurScreen extends StatelessWidget {
  const MezmurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MezmurLibraryScreen();
  }
}

class _MezmurLibraryScreen extends StatefulWidget {
  const _MezmurLibraryScreen();

  @override
  State<_MezmurLibraryScreen> createState() => _MezmurLibraryScreenState();
}

class _MezmurLibraryScreenState extends State<_MezmurLibraryScreen> {
  static const _repository = MezmurLibraryRepository();

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<String, String> _localAssetCache = {};

  late final Future<MezmurLibrary> _libraryFuture;
  String _query = '';
  _MezmurBrowseMode _mode = _MezmurBrowseMode.artists;
  MezmurTrack? _currentTrack;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _loadingTrackId;
  String? _focusedArtist;
  String? _focusedAlbum;
  bool _focusedCompilation = false;

  @override
  void initState() {
    super.initState();
    _libraryFuture = _repository.load();
    _subscriptions.addAll([
      _player.onPlayerStateChanged.listen((state) {
        if (!mounted) {
          return;
        }
        setState(() {
          _playerState = state;
        });
      }),
      _player.onPositionChanged.listen((position) {
        if (!mounted) {
          return;
        }
        setState(() {
          _position = position;
        });
      }),
      _player.onDurationChanged.listen((duration) {
        if (!mounted) {
          return;
        }
        setState(() {
          _duration = duration;
        });
      }),
      _player.onPlayerComplete.listen((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTrack(MezmurTrack track) async {
    setState(() {
      _loadingTrackId = track.id;
    });

    try {
      await _player.stop();
      final localPath = await _materializeAsset(track.assetPath);
      await _player.play(DeviceFileSource(localPath));
      if (!mounted) {
        return;
      }
      setState(() {
        _currentTrack = track;
        _position = Duration.zero;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play ${track.title}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingTrackId = null;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final currentTrack = _currentTrack;
    if (currentTrack == null) {
      return;
    }

    try {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
        return;
      }
      if (_playerState == PlayerState.paused) {
        await _player.resume();
        return;
      }
      await _playTrack(currentTrack);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Playback error: $error')));
    }
  }

  Future<void> _seekTo(double value) async {
    await _player.seek(Duration(milliseconds: value.round()));
  }

  Future<String> _materializeAsset(String assetPath) async {
    final cached = _localAssetCache[assetPath];
    if (cached != null && await File(cached).exists()) {
      return cached;
    }

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

  void _openArtist(MezmurArtistSummary artist) {
    setState(() {
      _focusedArtist = artist.name;
      _focusedAlbum = null;
      _focusedCompilation = false;
      _mode = _MezmurBrowseMode.tracks;
    });
  }

  void _openAlbum(MezmurAlbumSummary album) {
    setState(() {
      _focusedArtist = album.artist;
      _focusedAlbum = album.name;
      _focusedCompilation = false;
      _mode = _MezmurBrowseMode.tracks;
    });
  }

  void _openCompilation(MezmurAlbumSummary album) {
    setState(() {
      _focusedArtist = null;
      _focusedAlbum = album.name;
      _focusedCompilation = true;
      _mode = _MezmurBrowseMode.tracks;
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
        .where((track) {
          if (_focusedCompilation) {
            if (!track.isCompilation) {
              return false;
            }
            return _focusedAlbum == null || track.album == _focusedAlbum;
          }
          if (_focusedArtist != null && track.artist != _focusedArtist) {
            return false;
          }
          if (_focusedAlbum != null && track.album != _focusedAlbum) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  bool _isCurrentTrack(MezmurTrack track) => _currentTrack?.id == track.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        elevation: 0,
        title: const Text('Mezmur Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: _currentTrack == null
          ? null
          : _MiniPlayer(
              track: _currentTrack!,
              playerState: _playerState,
              position: _position,
              duration: _duration,
              onPlayPause: _togglePlayback,
              onSeek: _seekTo,
            ),
      body: FutureBuilder<MezmurLibrary>(
        future: _libraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load the mezmur library.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final library = snapshot.data!;
          final searchedTracks = library.filter(_query);
          final artists = library.artistSummaries(searchedTracks);
          final albums = library.albumSummaries(searchedTracks);
          final compilations = library.compilationSummaries(searchedTracks);
          final filteredTracks = _applyFocus(searchedTracks);
          final featuredTrack = filteredTracks.isEmpty
              ? null
              : filteredTracks.first;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _HeroCard(
                title: 'Cleaned Mezmur Archive',
                subtitle:
                    '${library.tracks.length} tracks across ${library.artistCount} artists and ${library.compilationCount} compilations',
                featuredTrack: featuredTrack,
                onPlayFeatured: featuredTrack == null
                    ? null
                    : () => _playTrack(featuredTrack),
              ),
              const SizedBox(height: 18),
              _SearchField(
                query: _query,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(
                    label: 'Artists',
                    value: '${library.artistCount}',
                  ),
                  _MetricChip(label: 'Albums', value: '${library.albumCount}'),
                  _MetricChip(
                    label: 'Tracks',
                    value: '${library.tracks.length}',
                  ),
                  _MetricChip(
                    label: 'Compilations',
                    value: '${library.compilationCount}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _MezmurBrowseMode.values
                    .map(
                      (mode) => _BrowseChip(
                        label: mode.label,
                        selected: _mode == mode,
                        onTap: () => setState(() => _mode = mode),
                      ),
                    )
                    .toList(growable: false),
              ),
              if (_focusedArtist != null ||
                  _focusedAlbum != null ||
                  _focusedCompilation) ...[
                const SizedBox(height: 14),
                _FocusBanner(
                  artist: _focusedArtist,
                  album: _focusedAlbum,
                  isCompilation: _focusedCompilation,
                  onClear: _clearFocus,
                ),
              ],
              const SizedBox(height: 22),
              _SectionTitle(
                title: _mode.label,
                subtitle: '${filteredTracks.length} matching tracks',
              ),
              const SizedBox(height: 12),
              ...switch (_mode) {
                _MezmurBrowseMode.artists => _buildArtistCards(artists),
                _MezmurBrowseMode.albums => _buildAlbumCards(albums),
                _MezmurBrowseMode.tracks => _buildTrackCards(filteredTracks),
                _MezmurBrowseMode.compilations => _buildCompilationCards(
                  compilations,
                ),
              },
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildArtistCards(List<MezmurArtistSummary> artists) {
    if (artists.isEmpty) {
      return const [_EmptyState(message: 'No artists matched this filter.')];
    }
    return artists
        .map(
          (artist) => _SummaryCard(
            icon: Icons.person_outline,
            title: artist.name,
            subtitle: '${artist.albumCount} albums',
            trailing: '${artist.trackCount} tracks',
            onTap: () => _openArtist(artist),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _buildAlbumCards(List<MezmurAlbumSummary> albums) {
    if (albums.isEmpty) {
      return const [_EmptyState(message: 'No albums matched this filter.')];
    }
    return albums
        .map(
          (album) => _SummaryCard(
            icon: Icons.album_outlined,
            title: album.name,
            subtitle: album.artist,
            trailing: '${album.trackCount} tracks',
            onTap: () => _openAlbum(album),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _buildCompilationCards(List<MezmurAlbumSummary> compilations) {
    if (compilations.isEmpty) {
      return const [
        _EmptyState(message: 'No compilations matched this filter.'),
      ];
    }
    return compilations
        .map(
          (album) => _SummaryCard(
            icon: Icons.library_music_outlined,
            title: album.name,
            subtitle: 'Compilation',
            trailing: '${album.trackCount} tracks',
            onTap: () => _openCompilation(album),
          ),
        )
        .toList(growable: false);
  }

  List<Widget> _buildTrackCards(List<MezmurTrack> tracks) {
    if (tracks.isEmpty) {
      return const [_EmptyState(message: 'No tracks matched this filter.')];
    }
    return tracks
        .map(
          (track) => _TrackCard(
            track: track,
            isCurrent: _isCurrentTrack(track),
            isPlaying:
                _isCurrentTrack(track) && _playerState == PlayerState.playing,
            isLoading: _loadingTrackId == track.id,
            onTap: () => _playTrack(track),
          ),
        )
        .toList(growable: false);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.featuredTrack,
    required this.onPlayFeatured,
  });

  final String title;
  final String subtitle;
  final MezmurTrack? featuredTrack;
  final VoidCallback? onPlayFeatured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1916), Color(0xFF4B3A22)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (featuredTrack != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPlayFeatured,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            featuredTrack!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${featuredTrack!.artist} / ${featuredTrack!.album}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.headphones,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search artists, albums, and tracks',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onChanged(''),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5DFD2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5DFD2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF9A7B48), width: 1.2),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DFD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseChip extends StatelessWidget {
  const _BrowseChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF201D18) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF201D18) : const Color(0xFFE5DFD2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FocusBanner extends StatelessWidget {
  const _FocusBanner({
    required this.artist,
    required this.album,
    required this.isCompilation,
    required this.onClear,
  });

  final String? artist;
  final String? album;
  final bool isCompilation;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (isCompilation) 'Compilation',
      if (artist != null) artist!,
      if (album != null) album!,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECDE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1D1B1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              parts.join(' / '),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F4822),
              ),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5DFD2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EBDD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF71572A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  final MezmurTrack track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFF2EBDC) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFFC9A96A)
                : const Color(0xFFE5DFD2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF71572A)
                    : track.isCompilation
                    ? const Color(0xFFECE5D5)
                    : const Color(0xFFE8EFE5),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isCurrent ? Colors.white : Colors.black87,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${track.artist} / ${track.album}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.assetPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              track.trackNumber.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.track,
    required this.playerState,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
  });

  final MezmurTrack track;
  final PlayerState playerState;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final durationMs = duration.inMilliseconds <= 0
        ? 1
        : duration.inMilliseconds;
    final positionMs = position.inMilliseconds.clamp(0, durationMs);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: const BoxDecoration(
          color: Color(0xFF14110D),
          border: Border(top: BorderSide(color: Color(0xFF332A1F))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: positionMs.toDouble(),
                min: 0,
                max: durationMs.toDouble(),
                activeColor: const Color(0xFFE0C188),
                inactiveColor: Colors.white24,
                onChanged: duration.inMilliseconds <= 0 ? null : onSeek,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${track.artist} / ${track.album}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    playerState == PlayerState.playing
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DFD2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
