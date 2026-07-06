part of 'mezmur_screen.dart';

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
