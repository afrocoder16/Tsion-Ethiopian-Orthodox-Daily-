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
class _TrackArtPainter extends CustomPainter {
  const _TrackArtPainter({required this.seed, required this.size});
  final String seed;
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final v = _artVariant(seed);
    final bgPaint = Paint()
      ..color = v == 0
          ? const Color(0xFFECDFBB)
          : v == 1
          ? const Color(0xFFE4D5A8)
          : v == 2
          ? const Color(0xFFDDD0A0)
          : v == 3
          ? const Color(0xFFEAD9B0)
          : const Color(0xFFE7D4A5);
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.width, sz.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF8A6A2E).withValues(alpha: 0.55)
      ..strokeWidth = sz.width * 0.018
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = sz.width / 2;
    final cy = sz.height / 2;
    final r = sz.width * 0.32;

    if (v == 0 || v == 3) {
      // Meskel cross with diamond
      final pts = [
        Offset(cx, cy - r * 1.1),
        Offset(cx + r * 0.35, cy - r * 0.55),
        Offset(cx + r * 1.1, cy),
        Offset(cx + r * 0.35, cy + r * 0.55),
        Offset(cx, cy + r * 1.1),
        Offset(cx - r * 0.35, cy + r * 0.55),
        Offset(cx - r * 1.1, cy),
        Offset(cx - r * 0.35, cy - r * 0.55),
      ];
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, linePaint);
      canvas.drawLine(
        Offset(cx, cy - r * 0.6),
        Offset(cx, cy + r * 0.6),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.6, cy),
        Offset(cx + r * 0.6, cy),
        linePaint,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        sz.width * 0.04,
        Paint()..color = const Color(0xFF8A6A2E).withValues(alpha: 0.7),
      );
    } else if (v == 1) {
      // Arch / tabot form
      final archPath = Path()
        ..moveTo(cx - r, cy + r * 0.6)
        ..lineTo(cx - r, cy - r * 0.2)
        ..arcToPoint(
          Offset(cx + r, cy - r * 0.2),
          radius: Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(cx + r, cy + r * 0.6)
        ..close();
      canvas.drawPath(archPath, linePaint);
      canvas.drawLine(
        Offset(cx, cy - r * 0.6),
        Offset(cx, cy + r * 0.5),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.45, cy),
        Offset(cx + r * 0.45, cy),
        linePaint,
      );
    } else if (v == 2) {
      // Interlace grid
      final step = sz.width / 5;
      for (var i = 1; i < 5; i++) {
        canvas.drawLine(
          Offset(step * i, 0),
          Offset(step * i, sz.height),
          linePaint,
        );
        canvas.drawLine(
          Offset(0, step * i),
          Offset(sz.width, step * i),
          linePaint,
        );
      }
      canvas.drawLine(Offset(0, 0), Offset(sz.width, sz.height), linePaint);
      canvas.drawLine(Offset(sz.width, 0), Offset(0, sz.height), linePaint);
    } else {
      // Margin grid with central cross
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: r * 1.8,
          height: r * 1.8,
        ),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx, cy - r * 0.7),
        Offset(cx, cy + r * 0.7),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.7, cy),
        Offset(cx + r * 0.7, cy),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrackArtPainter old) => old.seed != seed;
}

// Deterministic track artwork widget
class _TrackArt extends StatelessWidget {
  const _TrackArt({required this.seed, required this.size, this.radius = 10});
  final String seed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _TrackArtPainter(seed: seed, size: size),
        size: Size(size, size),
      ),
    );
  }
}

// Artist avatar — illuminated initial with dotted coin border
class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AvatarCoinPainter(),
        child: Container(
          margin: EdgeInsets.all(size * 0.07),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFECDFBB), Color(0xFFD4BF88)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: _oxbloodDeep,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final r = s.width / 2 - 1;
    final p = Paint()
      ..color = _gold.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    // outer ring
    canvas.drawCircle(Offset(cx, cy), r, p);
    // dot border
    const dots = 24;
    final dotPaint = Paint()
      ..color = _gold.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * pi;
      final dx = cx + (r - 3) * cos(angle);
      final dy = cy + (r - 3) * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_AvatarCoinPainter old) => false;
}

// Small inline meskel cross (SVG-like via CustomPaint)
class _MeskelCrossIcon extends StatelessWidget {
  const _MeskelCrossIcon({this.size = 12, this.color = _gold});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrossPainter(color: color)),
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width / 2, s.height), p);
    canvas.drawLine(Offset(0, s.height / 2), Offset(s.width, s.height / 2), p);
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.09,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}

// 8-pointed Meskel star — used as large watermark in hero card
class _StarCrossPainter extends CustomPainter {
  const _StarCrossPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final r = s.width * 0.44;
    final p = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // 8 spokes at 45° intervals
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi - pi / 2;
      final innerR = r * 0.28;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + r * cos(angle), cy + r * sin(angle)),
        p,
      );
    }
    // outer circle
    canvas.drawCircle(Offset(cx, cy), r, p..strokeWidth = s.width * 0.018);
    // inner circle
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.28,
      p..strokeWidth = s.width * 0.018,
    );
    // cross overlay
    final cp = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - r * 0.22), Offset(cx, cy + r * 0.22), cp);
    canvas.drawLine(Offset(cx - r * 0.22, cy), Offset(cx + r * 0.22, cy), cp);
    canvas.drawCircle(Offset(cx, cy), s.width * 0.03, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarCrossPainter old) => old.color != color;
}

// Instrument backdrop (subtle watermark for hero sections)
class _InstrumentBackdrop extends StatelessWidget {
  const _InstrumentBackdrop();
  static const double opacity = 0.07;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(painter: _BackdropPainter(), size: Size.infinite),
    );
  }
}

class _ParchmentThumbShape extends SliderComponentShape {
  const _ParchmentThumbShape({this.radius = 7});
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(radius * 2, radius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, radius, Paint()..color = _oxblood);
    canvas.drawCircle(center, radius - 2.5, Paint()..color = _screenBackground);
    canvas.drawCircle(
      center,
      radius - 2.5,
      Paint()
        ..color = _oxblood
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = _gold
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Begena (lyre) — top left rotated
    canvas.save();
    canvas.translate(s.width * 0.08, s.height * 0.1);
    canvas.rotate(-0.21);
    final lyreSz = s.width * 0.28;
    // box
    canvas.drawRect(
      Rect.fromLTWH(0, lyreSz * 0.55, lyreSz * 0.68, lyreSz * 0.35),
      p,
    );
    // arms
    canvas.drawLine(Offset(lyreSz * 0.06, lyreSz * 0.55), Offset(0, 0), p);
    canvas.drawLine(
      Offset(lyreSz * 0.62, lyreSz * 0.55),
      Offset(lyreSz * 0.68, 0),
      p,
    );
    canvas.drawLine(Offset(0, 0), Offset(lyreSz * 0.68, 0), p);
    for (var i = 1; i <= 5; i++) {
      canvas.drawLine(
        Offset(lyreSz * i / 6.5, 0),
        Offset(lyreSz * i / 6.5, lyreSz * 0.55),
        p,
      );
    }
    canvas.restore();

    // Kebero drum — bottom right rotated
    canvas.save();
    canvas.translate(s.width * 0.68, s.height * 0.6);
    canvas.rotate(0.26);
    final kSz = s.width * 0.22;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(kSz / 2, kSz * 0.15),
        width: kSz,
        height: kSz * 0.22,
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(kSz / 2, kSz * 0.85),
        width: kSz * 0.7,
        height: kSz * 0.16,
      ),
      p,
    );
    canvas.drawLine(Offset(0, kSz * 0.15), Offset(kSz * 0.15, kSz * 0.85), p);
    canvas.drawLine(Offset(kSz, kSz * 0.15), Offset(kSz * 0.85, kSz * 0.85), p);
    canvas.restore();

    // Tsenatsel (sistrum) — center right
    canvas.save();
    canvas.translate(s.width * 0.62, s.height * 0.12);
    canvas.rotate(0.14);
    final tSz = s.width * 0.14;
    final uPath = Path()
      ..moveTo(0, tSz * 0.4)
      ..lineTo(0, tSz * 1.0)
      ..arcToPoint(
        Offset(tSz, tSz * 1.0),
        radius: Radius.circular(tSz / 2),
        clockwise: false,
      )
      ..lineTo(tSz, tSz * 0.4);
    canvas.drawPath(uPath, p);
    for (var i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(-tSz * 0.1, tSz * i * 0.28),
        Offset(tSz * 1.1, tSz * i * 0.28),
        p,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(tSz * 0.4, tSz * 1.0, tSz * 0.2, tSz * 0.6),
      p,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => false;
}

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

// ── Greeting ──────────────────────────────────────────────────────────────────
// ── Recently Played ───────────────────────────────────────────────────────────
class _RecentlyPlayedSection extends StatelessWidget {
  const _RecentlyPlayedSection({
    required this.tracks,
    required this.currentTrackId,
    required this.onTap,
  });

  final List<MezmurTrack> tracks;
  final String? currentTrackId;
  final ValueChanged<MezmurTrack> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: _CarouselHeader(title: 'Recently Played'),
        ),
        SizedBox(
          height: 152,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tracks.length,
            itemBuilder: (ctx, i) {
              final t = tracks[i];
              final isCurrent = t.id == currentTrackId;
              return GestureDetector(
                onTap: () => onTap(t),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _TrackArt(
                            seed: '${t.title}${t.artist}',
                            size: 110,
                            radius: 14,
                          ),
                          if (isCurrent)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _oxblood,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.equalizer_rounded,
                                  color: Color(0xFFF5ECD4),
                                  size: 14,
                                ),
                              ),
                            )
                          else
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _oxblood,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFFF5ECD4),
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: isCurrent ? _oxblood : _ink,
                        ),
                      ),
                      Text(
                        t.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: _mutedText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Liked Songs Card ──────────────────────────────────────────────────────────
class _LikedSongsCard extends StatelessWidget {
  const _LikedSongsCard({
    required this.count,
    required this.onTap,
    required this.onPlayAll,
  });

  final int count;
  final VoidCallback onTap;
  final VoidCallback onPlayAll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [_gold, _goldDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFF4A1414),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liked Songs',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2B1D10),
                    ),
                  ),
                  Text(
                    '$count · hymns you\'ve blessed',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0x994A1414),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onPlayAll,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _oxbloodDeep,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFF5ECD4),
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Play All',
                      style: TextStyle(
                        color: Color(0xFFF5ECD4),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Artists Carousel ──────────────────────────────────────────────────────────
class _FeaturedArtistsCarousel extends StatelessWidget {
  const _FeaturedArtistsCarousel({required this.artists, required this.onTap});

  final List<MezmurArtistSummary> artists;
  final ValueChanged<MezmurArtistSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: _CarouselHeader(title: 'Cantors'),
        ),
        SizedBox(
          height: 148,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            itemBuilder: (ctx, i) {
              final a = artists[i];
              return GestureDetector(
                onTap: () => onTap(a),
                child: Container(
                  width: 92,
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      _ArtistAvatar(name: a.name, size: 88),
                      const SizedBox(height: 8),
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                        ),
                      ),
                      Text(
                        '${a.trackCount} hymns',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: _mutedText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Albums Carousel ───────────────────────────────────────────────────────────
class _AlbumsCarousel extends StatelessWidget {
  const _AlbumsCarousel({required this.albums, required this.onTap});

  final List<MezmurAlbumSummary> albums;
  final ValueChanged<MezmurAlbumSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: _CarouselHeader(title: 'Albums'),
        ),
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: albums.length,
            itemBuilder: (ctx, i) {
              final a = albums[i];
              return GestureDetector(
                onTap: () => onTap(a),
                child: Container(
                  width: 136,
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _outlineColor),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _TrackArt(
                          seed: '${a.name}${a.artist}album',
                          size: 120,
                          radius: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: _ink,
                        ),
                      ),
                      Text(
                        a.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: _mutedText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Compilations Section (2-row horizontal grid) ─────────────────────────────
class _CompilationsSection extends StatelessWidget {
  const _CompilationsSection({required this.compilations, required this.onTap});

  final List<MezmurAlbumSummary> compilations;
  final ValueChanged<MezmurAlbumSummary> onTap;

  static const double _itemW = 160;
  static const double _itemH = 52;
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    // Split into two rows, scrolling horizontally together
    final row0 = <MezmurAlbumSummary>[];
    final row1 = <MezmurAlbumSummary>[];
    for (var i = 0; i < compilations.length; i++) {
      if (i.isEven) {
        row0.add(compilations[i]);
      } else {
        row1.add(compilations[i]);
      }
    }

    Widget chip(MezmurAlbumSummary c) => InkWell(
      onTap: () => onTap(c),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: _itemW,
        height: _itemH,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _outlineColor),
        ),
        child: Row(
          children: [
            _TrackArt(seed: '${c.name}comp', size: 28, radius: 6),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                c.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: _ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final colCount = row0.length;
    final totalW = colCount * _itemW + (colCount - 1) * _gap + 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: _CarouselHeader(title: 'Compilations'),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: totalW,
            height: _itemH * 2 + _gap,
            child: Column(
              children: [
                Row(
                  children: row0
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: _gap),
                          child: chip(c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: _gap),
                Row(
                  children: row1
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: _gap),
                          child: chip(c),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Carousel Header — manuscript section heading with gold cross ──────────────
class _CarouselHeader extends StatelessWidget {
  const _CarouselHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: _ink,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _outlineColor)),
        const SizedBox(width: 8),
        const _MeskelCrossIcon(size: 13, color: _gold),
      ],
    );
  }
}

// ── Filter Bar (pinned sliver) ────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  _FilterBarDelegate({
    required this.filter,
    required this.focusedArtist,
    required this.focusedAlbum,
    required this.focusedCompilation,
    required this.playlistCount,
    required this.onFilterChanged,
    required this.onClearFocus,
    required this.onLibraryTap,
  });

  final _BrowseFilter filter;
  final String? focusedArtist;
  final String? focusedAlbum;
  final bool focusedCompilation;
  final int playlistCount;
  final ValueChanged<_BrowseFilter> onFilterChanged;
  final VoidCallback onClearFocus;
  final VoidCallback onLibraryTap;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.filter != filter ||
      old.focusedArtist != focusedArtist ||
      old.focusedAlbum != focusedAlbum ||
      old.focusedCompilation != focusedCompilation ||
      old.playlistCount != playlistCount;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final hasFocus =
        focusedArtist != null || focusedAlbum != null || focusedCompilation;
    final focusLabel = focusedCompilation && focusedAlbum != null
        ? focusedAlbum!
        : focusedArtist != null && focusedAlbum != null
        ? '$focusedArtist / $focusedAlbum'
        : focusedArtist ?? focusedAlbum ?? '';

    return Container(
      color: _screenBackground,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          if (hasFocus) ...[
            _FilterChip(
              label: '× $focusLabel',
              selected: true,
              onTap: onClearFocus,
            ),
            const SizedBox(width: 8),
          ],
          ...[
            _BrowseFilter.all,
            _BrowseFilter.artists,
            _BrowseFilter.albums,
            _BrowseFilter.tracks,
            _BrowseFilter.compilations,
          ].map(
            (f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: _filterLabel(f),
                selected: !hasFocus && filter == f,
                onTap: () => onFilterChanged(f),
              ),
            ),
          ),
          // Library (playlists) chip
          _FilterChip(
            label: playlistCount > 0 ? 'Library ($playlistCount)' : 'Library',
            selected: false,
            isAction: true,
            onTap: onLibraryTap,
          ),
        ],
      ),
    );
  }

  String _filterLabel(_BrowseFilter f) => switch (f) {
    _BrowseFilter.all => 'All',
    _BrowseFilter.artists => 'Artists',
    _BrowseFilter.albums => 'Albums',
    _BrowseFilter.tracks => 'Tracks',
    _BrowseFilter.compilations => 'Compilations',
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isAction = false,
  });

  final String label;
  final bool selected;
  final bool isAction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? _oxblood
        : isAction
        ? _panelBackground
        : _cardBackground;
    final textColor = selected ? const Color(0xFFF5ECD4) : _inkSoft;

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? _oxblood : _outlineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAction) ...[
              const _MeskelCrossIcon(size: 11, color: _goldDeep),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Artist List Row ───────────────────────────────────────────────────────────
class _ArtistListRow extends StatelessWidget {
  const _ArtistListRow({required this.artist, required this.onTap});

  final MezmurArtistSummary artist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _outlineColor),
        ),
        child: Row(
          children: [
            _ArtistAvatar(name: artist.name, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${artist.albumCount} albums · ${artist.trackCount} hymns',
                    style: const TextStyle(fontSize: 12, color: _mutedText),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Album List Row ────────────────────────────────────────────────────────────
class _AlbumListRow extends StatelessWidget {
  const _AlbumListRow({required this.album, required this.onTap});

  final MezmurAlbumSummary album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _outlineColor),
        ),
        child: Row(
          children: [
            _TrackArt(
              seed: '${album.name}${album.artist}list',
              size: 50,
              radius: 10,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    album.isCompilation
                        ? '${album.trackCount} hymns'
                        : '${album.artist} · ${album.trackCount} hymns',
                    style: const TextStyle(fontSize: 12, color: _mutedText),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Track Row ─────────────────────────────────────────────────────────────────
class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.isLoading,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
    required this.onMore,
  });

  final MezmurTrack track;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? _oxblood.withValues(alpha: 0.06) : _cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent ? _oxblood.withValues(alpha: 0.28) : _outlineColor,
          ),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                _TrackArt(
                  seed: '${track.title}${track.artist}row',
                  size: 44,
                  radius: 8,
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF5ECD4),
                    ),
                  )
                else if (isCurrent)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _oxblood.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xFFF5ECD4),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? _oxblood : _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${track.artist} · ${track.album}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _mutedText, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onLike,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? _oxblood : _mutedText,
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: onMore,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: _mutedText,
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Player ───────────────────────────────────────────────────────────────
class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({
    required this.track,
    required this.playerState,
    required this.position,
    required this.duration,
    required this.isLiked,
    required this.onPlayPause,
    required this.onNext,
    required this.onLike,
    required this.onTap,
  });

  final MezmurTrack track;
  final PlayerState playerState;
  final Duration position;
  final Duration duration;
  final bool isLiked;
  final VoidCallback onPlayPause;
  final VoidCallback onLike;
  final Future<bool> Function() onNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: _oxblood,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      children: [
                        // Track artwork
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _TrackArt(
                            seed: '${track.title}${track.artist}mini',
                            size: 44,
                            radius: 10,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFF5ECD4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xAAF5ECD4),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onLike,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? _gold : const Color(0x88F5ECD4),
                            size: 20,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        // Play/pause — gold ring button
                        GestureDetector(
                          onTap: onPlayPause,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF5ECD4),
                              border: Border.all(color: _gold, width: 1.5),
                            ),
                            child: Icon(
                              playerState == PlayerState.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: _oxblood,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onNext,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Color(0xAAF5ECD4),
                            size: 22,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  // Progress bar — gold on burgundy
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: _oxbloodDeep,
                      valueColor: AlwaysStoppedAnimation(_gold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Expanded Player ───────────────────────────────────────────────────────────
class _ExpandedPlayerOverlay extends StatelessWidget {
  const _ExpandedPlayerOverlay({
    required this.track,
    required this.queueCount,
    required this.queueLabel,
    required this.playerState,
    required this.position,
    required this.duration,
    required this.shuffleEnabled,
    required this.repeatEnabled,
    required this.isLiked,
    required this.playbackSpeed,
    required this.sleepTimerRemainingSeconds,
    required this.onClose,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onSeek,
    required this.onQueue,
    required this.onShuffle,
    required this.onRepeat,
    required this.onLike,
    required this.onSpeed,
    required this.onSleepTimer,
    required this.onTrackActions,
  });

  final MezmurTrack track;
  final int queueCount;
  final String queueLabel;
  final PlayerState playerState;
  final Duration position;
  final Duration duration;
  final bool shuffleEnabled;
  final bool repeatEnabled;
  final bool isLiked;
  final double playbackSpeed;
  final int? sleepTimerRemainingSeconds;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<double> onSeek;
  final VoidCallback onQueue;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onLike;
  final VoidCallback onSpeed;
  final VoidCallback onSleepTimer;
  final VoidCallback onTrackActions;

  @override
  Widget build(BuildContext context) {
    final totalMs = max(duration.inMilliseconds, 1);
    final sliderValue = position.inMilliseconds.clamp(0, totalMs).toDouble();

    return Material(
      color: _screenBackground,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF1D8), _screenBackground, Color(0xFFEBDCAE)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // instrument watermark behind everything
            Positioned.fill(child: _InstrumentBackdrop()),
            SafeArea(
              child: Column(
                children: [
                  // Drag handle
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _inkSoft,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'PLAYING FROM',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _gold,
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                queueLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onTrackActions,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: _inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Artwork
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            // track art
                            _TrackArt(
                              seed: track.title,
                              size: double.infinity,
                              radius: 20,
                            ),
                            // gold cross flourish in corner
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: _MeskelCrossIcon(
                                    size: 16,
                                    color: _gold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Track info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VOL ${track.trackNumber.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.8,
                            color: _gold,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: _ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${track.artist} · ${track.album}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _mutedText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Seek bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            activeTrackColor: _oxblood,
                            inactiveTrackColor: _gold.withValues(alpha: 0.2),
                            thumbColor: _oxblood,
                            overlayColor: _oxblood.withValues(alpha: 0.10),
                            thumbShape: const _ParchmentThumbShape(radius: 7),
                          ),
                          child: Slider(
                            value: sliderValue,
                            max: totalMs.toDouble(),
                            onChanged: onSeek,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: _mutedText,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: _mutedText,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Primary controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlChip(
                          icon: Icons.shuffle_rounded,
                          active: shuffleEnabled,
                          onTap: onShuffle,
                        ),
                        const Spacer(),
                        _SecondaryControlButton(
                          icon: Icons.skip_previous_rounded,
                          onTap: onPrevious,
                        ),
                        const SizedBox(width: 14),
                        _PrimaryControlButton(
                          icon: playerState == PlayerState.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: onPlayPause,
                        ),
                        const SizedBox(width: 14),
                        _SecondaryControlButton(
                          icon: Icons.skip_next_rounded,
                          onTap: onNext,
                        ),
                        const Spacer(),
                        _ControlChip(
                          icon: Icons.repeat_rounded,
                          active: repeatEnabled,
                          onTap: onRepeat,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Secondary controls: heart · add · queue
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: onLike,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? _oxblood : _mutedText,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onTap: onTrackActions,
                          child: const Icon(
                            Icons.add_rounded,
                            color: _mutedText,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onTap: onQueue,
                          child: const Icon(
                            Icons.queue_music_rounded,
                            color: _mutedText,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared control buttons ────────────────────────────────────────────────────
class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _oxblood.withValues(alpha: 0.12) : _panelBackground,
          border: Border.all(color: active ? _oxblood : _outlineColor),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: active ? _oxblood : _mutedText, size: 18),
      ),
    );
  }
}

class _PrimaryControlButton extends StatelessWidget {
  const _PrimaryControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _oxblood,
          border: Border.all(color: _gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: _oxbloodDeep.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: _screenBackground, size: 36),
      ),
    );
  }
}

class _SecondaryControlButton extends StatelessWidget {
  const _SecondaryControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _panelBackground,
          border: Border.all(color: _outlineColor),
        ),
        child: Icon(icon, color: _oxblood, size: 26),
      ),
    );
  }
}

// ── Search field ──────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: _ink, fontSize: 14),
      cursorColor: _oxblood,
      decoration: InputDecoration(
        hintText: 'Hymns, cantors, albums…',
        hintStyle: const TextStyle(color: _mutedText, fontSize: 14),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _mutedText,
          size: 20,
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: _mutedText,
                  size: 18,
                ),
                onPressed: () => onChanged(''),
              ),
        filled: true,
        fillColor: _cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: _outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: _outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: _oxblood, width: 1.3),
        ),
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 3,
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _oxblood, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: _inkSoft,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _outlineColor),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: _mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Track List Screen (Liked Songs / playlist detail) ─────────────────────────
class _TrackListScreen extends StatelessWidget {
  const _TrackListScreen({
    required this.title,
    required this.icon,
    required this.tracks,
    required this.currentTrackId,
    required this.likedTrackIds,
    required this.onPlay,
    required this.onLike,
    required this.onMore,
  });

  final String title;
  final IconData icon;
  final List<MezmurTrack> tracks;
  final String? currentTrackId;
  final Set<String> likedTrackIds;
  final void Function(MezmurTrack) onPlay;
  final void Function(MezmurTrack) onLike;
  final void Function(MezmurTrack) onMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: AppBar(
        backgroundColor: _screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _inkSoft,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _oxblood, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const Text(
              'YOUR COLLECTION',
              style: TextStyle(
                color: _gold,
                fontSize: 9,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${tracks.length} HYMNS',
              style: const TextStyle(
                color: _mutedText,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: tracks.isEmpty
          ? const Center(
              child: Text(
                'No tracks here yet.',
                style: TextStyle(color: _mutedText, fontSize: 15),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Hero banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      decoration: BoxDecoration(
                        color: _oxblood,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            top: -8,
                            child: Opacity(
                              opacity: 0.15,
                              child: SizedBox(
                                width: 110,
                                height: 110,
                                child: CustomPaint(
                                  painter: _StarCrossPainter(color: _gold),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const _MeskelCrossIcon(
                                    size: 11,
                                    color: _gold,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PERSONAL',
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                      color: _gold.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Liked Mezmurs',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFF5ECD4),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hymns you\'ve blessed — ${tracks.length} tracks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xAAF5ECD4),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: tracks.isNotEmpty
                                          ? () => onPlay(tracks.first)
                                          : null,
                                      child: Container(
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: _gold,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              color: Color(0xFF2B1D10),
                                              size: 20,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Play All',
                                              style: TextStyle(
                                                color: Color(0xFF2B1D10),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _gold.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.shuffle_rounded,
                                      color: _gold.withValues(alpha: 0.9),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Track list
                SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final track = tracks[i];
                    final isCurrent = track.id == currentTrackId;
                    final isLiked = likedTrackIds.contains(track.id);
                    return InkWell(
                      onTap: () => onPlay(track),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // index number
                            SizedBox(
                              width: 28,
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCurrent ? _oxblood : _mutedText,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            _TrackArt(
                              seed: '${track.title}${track.artist}',
                              size: 44,
                              radius: 10,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isCurrent ? _oxblood : _ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    track.artist,
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
                            const SizedBox(width: 8),
                            Text(
                              '#${track.trackNumber}',
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onLike(track),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? _oxblood : _mutedText,
                                  size: 18,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => onMore(track),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.more_vert_rounded,
                                  color: _mutedText,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: tracks.length),
                ),
              ],
            ),
    );
  }
}

// ── Cantor Detail Screen ──────────────────────────────────────────────────────
class _CantorDetailScreen extends StatelessWidget {
  const _CantorDetailScreen({
    required this.name,
    required this.tracks,
    required this.albums,
    required this.currentTrackId,
    required this.likedTrackIds,
    required this.onPlayAll,
    required this.onPlayTrack,
    required this.onLike,
    required this.onMore,
  });

  final String name;
  final List<MezmurTrack> tracks;
  final List<MezmurAlbumSummary> albums;
  final String? currentTrackId;
  final Set<String> likedTrackIds;
  final void Function(List<MezmurTrack>) onPlayAll;
  final void Function(MezmurTrack) onPlayTrack;
  final void Function(MezmurTrack) onLike;
  final void Function(MezmurTrack, List<MezmurTrack>) onMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: _screenBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _inkSoft,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: _inkSoft),
                onPressed: () {},
              ),
            ],
          ),

          // Hero section — avatar + name + stats + buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  // Avatar
                  _ArtistAvatar(name: name, size: 140),
                  const SizedBox(height: 16),

                  // CANTOR label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _MeskelCrossIcon(size: 11, color: _gold),
                      const SizedBox(width: 6),
                      const Text(
                        'CANTOR',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2.0,
                          color: _gold,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Name
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: _ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Text(
                    '${albums.length} ALBUMS  ·  ${tracks.length} HYMNS',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: _mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: tracks.isNotEmpty
                            ? () => onPlayAll(tracks)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: _oxblood,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: _oxbloodDeep.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: _screenBackground,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Play',
                                style: TextStyle(
                                  color: _screenBackground,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: _panelBackground,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: _outlineColor),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            color: _inkSoft,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _panelBackground,
                          border: Border.all(color: _outlineColor),
                        ),
                        child: const Icon(
                          Icons.shuffle_rounded,
                          color: _inkSoft,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // "Top Mezmurs" header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _CarouselHeader(title: 'Top Mezmurs'),
            ),
          ),

          // Track list
          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final track = tracks[i];
              final isCurrent = track.id == currentTrackId;
              return InkWell(
                onTap: () => onPlayTrack(track),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // italic rank number
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: isCurrent ? _oxblood : _gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // track art
                      _TrackArt(
                        seed: '${track.title}${track.artist}',
                        size: 46,
                        radius: 10,
                      ),
                      const SizedBox(width: 14),
                      // title + plays
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: isCurrent ? _oxblood : _ink,
                              ),
                            ),
                            Text(
                              '${track.trackNumber * 1200 ~/ 100 + 4}.${track.trackNumber}K plays',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // duration placeholder (track number as proxy)
                      Text(
                        '${4 + (track.trackNumber % 3)}:${((track.trackNumber * 17) % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedText,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onMore(track, tracks),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: _mutedText,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: tracks.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Playlist Screen ───────────────────────────────────────────────────────────
class _PlaylistScreen extends StatefulWidget {
  const _PlaylistScreen({
    required this.playlists,
    required this.library,
    required this.currentTrackId,
    required this.likedTrackIds,
    required this.onCreatePlaylist,
    required this.onDeletePlaylist,
    required this.onRemoveTrackFromPlaylist,
    required this.onPlayPlaylist,
    required this.onPlayTrack,
    required this.onLike,
    required this.onTrackMore,
  });

  final Map<String, List<String>> playlists;
  final MezmurLibrary library;
  final String? currentTrackId;
  final Set<String> likedTrackIds;
  final void Function(String name) onCreatePlaylist;
  final void Function(String name) onDeletePlaylist;
  final void Function(String playlistName, String trackId)
  onRemoveTrackFromPlaylist;
  final void Function(String playlistName, List<MezmurTrack> tracks)
  onPlayPlaylist;
  final void Function(MezmurTrack track, List<MezmurTrack> queue) onPlayTrack;
  final void Function(MezmurTrack) onLike;
  final void Function(MezmurTrack, List<MezmurTrack>) onTrackMore;

  @override
  State<_PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<_PlaylistScreen> {
  String? _openPlaylist;

  List<MezmurTrack> _resolvedTracks(String playlistName) {
    final ids = widget.playlists[playlistName] ?? [];
    final trackMap = {for (final t in widget.library.tracks) t.id: t};
    return ids.map((id) => trackMap[id]).whereType<MezmurTrack>().toList();
  }

  Future<void> _promptCreate() async {
    String name = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _screenBackground,
        title: const Text(
          'New Playlist',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          autofocus: true,
          onChanged: (v) => name = v.trim(),
          cursorColor: _accent,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: _mutedText),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Create',
              style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && name.isNotEmpty) {
      widget.onCreatePlaylist(name);
      setState(() {});
    }
  }

  void _confirmDelete(String playlistName) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _screenBackground,
        title: Text(
          'Delete "$playlistName"?',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'This playlist will be permanently removed.',
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _mutedText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (_openPlaylist == playlistName) {
                setState(() => _openPlaylist = null);
              }
              widget.onDeletePlaylist(playlistName);
              setState(() {});
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_openPlaylist != null && widget.playlists.containsKey(_openPlaylist)) {
      return _buildDetailView(_openPlaylist!);
    }
    return _buildListView();
  }

  Widget _buildListView() {
    final names = widget.playlists.keys.toList();
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: AppBar(
        backgroundColor: _screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Library',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: _accent),
            tooltip: 'New playlist',
            onPressed: _promptCreate,
          ),
        ],
      ),
      body: names.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.library_music_rounded,
                    color: _outlineColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No playlists yet',
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, color: _accent),
                    label: const Text(
                      'Create playlist',
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _promptCreate,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: names.length,
              itemBuilder: (ctx, i) {
                final name = names[i];
                final count = (widget.playlists[name] ?? []).length;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A96A), Color(0xFF7A5C2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.queue_music_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '$count ${count == 1 ? "track" : "tracks"}',
                    style: const TextStyle(color: _mutedText, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: _mutedText,
                    ),
                    onPressed: () => _confirmDelete(name),
                  ),
                  onTap: () => setState(() => _openPlaylist = name),
                );
              },
            ),
    );
  }

  Widget _buildDetailView(String playlistName) {
    final tracks = _resolvedTracks(playlistName);
    return Scaffold(
      backgroundColor: _screenBackground,
      appBar: AppBar(
        backgroundColor: _screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => setState(() => _openPlaylist = null),
        ),
        title: Text(
          playlistName,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (tracks.isNotEmpty)
            TextButton.icon(
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: _accent,
                size: 20,
              ),
              label: const Text(
                'Play All',
                style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onPlayPlaylist(playlistName, tracks);
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: _mutedText),
            tooltip: 'Delete playlist',
            onPressed: () => _confirmDelete(playlistName),
          ),
        ],
      ),
      body: tracks.isEmpty
          ? const Center(
              child: Text(
                'No tracks in this playlist.\nAdd tracks via the track menu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedText, fontSize: 15),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tracks.length,
              itemBuilder: (ctx, i) {
                final track = tracks[i];
                final isCurrent = track.id == widget.currentTrackId;
                final isLiked = widget.likedTrackIds.contains(track.id);
                return Dismissible(
                  key: ValueKey('${playlistName}_${track.id}_$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.shade100,
                    child: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Colors.red,
                    ),
                  ),
                  onDismissed: (_) {
                    widget.onRemoveTrackFromPlaylist(playlistName, track.id);
                    setState(() {});
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCurrent ? _accent : const Color(0xFFE7DDD0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isCurrent
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: isCurrent ? Colors.white : _accent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? _accent : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _mutedText, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? _accent : _mutedText,
                            size: 20,
                          ),
                          onPressed: () => widget.onLike(track),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: _mutedText,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onTrackMore(track, tracks);
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onPlayTrack(track, tracks);
                    },
                  ),
                );
              },
            ),
    );
  }
}
