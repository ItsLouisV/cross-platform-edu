import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../providers/audio_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/song.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _supabase = SupabaseService();
  bool _isFavorite = false;
  Song? _lastCheckedSong;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final currentSong =
        Provider.of<AudioProvider>(context, listen: false).currentSong;
    if (currentSong == null) return;
    if (_lastCheckedSong?.id != currentSong.id) {
      _lastCheckedSong = currentSong;
      final val = await _supabase.isFavorite(currentSong);
      if (mounted) setState(() => _isFavorite = val);
    }
  }

  void _toggleFavorite(Song song) async {
    setState(() => _isFavorite = !_isFavorite);
    await _supabase.toggleFavorite(song);
    final val = await _supabase.isFavorite(song);
    if (mounted) setState(() => _isFavorite = val);
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final currentSong = audioProvider.currentSong;

    if (currentSong == null) {
      return const Scaffold(body: Center(child: Text('No song playing')));
    }

    _checkFavoriteStatus();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen album art ──────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: currentSong.albumArtUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: const Color(0xFF1A1A2E)),
              errorWidget: (_, _, _) => Container(
                color: const Color(0xFF1A1A2E),
                child: const Icon(CupertinoIcons.music_note,
                    size: 100, color: Colors.white24),
              ),
            ),
          ),

          // ── Animated Blur Overlay (Lighter than ImageFiltered) ────────
          Positioned.fill(
            child: StreamBuilder<bool>(
              stream: audioProvider.player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isPlaying ? 0.0 : 1.0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(color: Colors.black.withValues(alpha: 0.1)),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Top gradient (for drag handle + safe area legibility) ──────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom frosted-glass panel ─────────────────────────────────
          // ── Bottom frosted-glass panel with feather edge ──────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0), Colors.black],
                  stops: [0.0, 0.4],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Safe-area content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Spacer pushes controls to bottom half
                const Spacer(),

                // ── Controls panel ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title + favorite
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black54,
                                          blurRadius: 8)
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentSong.artist,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    shadows: const [
                                      Shadow(
                                          color: Colors.black38,
                                          blurRadius: 6)
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _toggleFavorite(currentSong),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _isFavorite
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                key: ValueKey(_isFavorite),
                                color: _isFavorite
                                    ? Colors.redAccent
                                    : Colors.white,
                                size: 28,
                                shadows: const [
                                  Shadow(color: Colors.black45, blurRadius: 6)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Progress bar
                      StreamBuilder<Duration>(
                        stream: audioProvider.player.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = audioProvider.player.duration ??
                              Duration(seconds: currentSong.durationSeconds);
                          return ProgressBar(
                            progress: position,
                            total: duration,
                            onSeek: audioProvider.player.seek,
                            baseBarColor: Colors.white.withValues(alpha: 0.2),
                            progressBarColor: Colors.white,
                            bufferedBarColor:
                                Colors.white.withValues(alpha: 0.15),
                            thumbColor: Colors.white,
                            thumbRadius: 6,
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            timeLabelPadding: 8,
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Playback controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle
                          StreamBuilder<bool>(
                            stream:
                                audioProvider.player.shuffleModeEnabledStream,
                            builder: (context, snapshot) {
                              final isShuffle = snapshot.data ?? false;
                              return _ControlButton(
                                icon: CupertinoIcons.shuffle,
                                size: 22,
                                color: isShuffle
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                onTap: audioProvider.toggleShuffle,
                              );
                            },
                          ),

                          // Previous
                          _ControlButton(
                            icon: CupertinoIcons.backward_fill,
                            size: 34,
                            color: audioProvider.hasPrevious
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            onTap: audioProvider.hasPrevious
                                ? audioProvider.playPrevious
                                : null,
                          ),

                          // Play / Pause
                          StreamBuilder<bool>(
                            stream: audioProvider.player.playingStream,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data ?? false;
                              return GestureDetector(
                                onTap: () => isPlaying
                                    ? audioProvider.pause()
                                    : audioProvider.resume(),
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? CupertinoIcons.pause_fill
                                        : CupertinoIcons.play_fill,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Next
                          _ControlButton(
                            icon: CupertinoIcons.forward_fill,
                            size: 34,
                            color: audioProvider.hasNext
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            onTap: audioProvider.hasNext
                                ? audioProvider.playNext
                                : null,
                          ),

                          // Repeat
                          StreamBuilder<LoopMode>(
                            stream: audioProvider.player.loopModeStream,
                            builder: (context, snapshot) {
                              final mode = snapshot.data ?? LoopMode.off;
                              return _ControlButton(
                                icon: mode == LoopMode.one
                                    ? CupertinoIcons.repeat_1
                                    : CupertinoIcons.repeat,
                                size: 22,
                                color: mode != LoopMode.off
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                onTap: audioProvider.toggleRepeat,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Volume
                      Row(
                        children: [
                          Icon(CupertinoIcons.speaker_fill,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StreamBuilder<double>(
                              stream: audioProvider.player.volumeStream,
                              builder: (context, snapshot) {
                                final volume = snapshot.data ?? 1.0;
                                return SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5),
                                    overlayShape:
                                        SliderComponentShape.noOverlay,
                                    activeTrackColor:
                                        Colors.white.withValues(alpha: 0.85),
                                    inactiveTrackColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: volume,
                                    min: 0,
                                    max: 1,
                                    onChanged:
                                        audioProvider.player.setVolume,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(CupertinoIcons.speaker_3_fill,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.5)),
                        ],
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helper widget for icon buttons ─────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: size, color: color,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 6)]),
      ),
    );
  }
}
