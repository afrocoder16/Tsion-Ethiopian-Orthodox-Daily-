part of 'mezmur_screen.dart';

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

