part of 'mezmur_screen.dart';


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

