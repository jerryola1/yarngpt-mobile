import 'package:flutter/material.dart';
import '../models/generated_audio.dart';

class AudioPlayerOverlay extends StatelessWidget {
  final GeneratedAudio audio;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onClose;
  final bool isDark;

  const AudioPlayerOverlay({
    Key? key,
    required this.audio,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
    required this.onClose,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1),
        curve: Curves.easeOut,
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF212121),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: const Color(0xFF909090),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, -3),
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0xFF909090),
                blurRadius: 1,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFf7d786),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFFf7d786),
                          child: Icon(
                            Icons.music_note,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audio.text.split(' ').take(3).join(' '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Palanquin',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              audio.speaker,
                              style: const TextStyle(
                                color: Color(0xFF909090),
                                fontSize: 12,
                                fontFamily: 'Palanquin',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Color(0xFF909090),
                        ),
                        onPressed: () {}, // Add settings functionality
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF909090),
                        ),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Color(0xFF909090), 
                          fontSize: 12,
                          fontFamily: 'Palanquin',
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: const Color(0xFFf7d786),
                            inactiveTrackColor: const Color(0xFF909090).withOpacity(0.3),
                            thumbColor: const Color(0xFFf7d786),
                            overlayColor: const Color(0xFFf7d786).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: position.inSeconds.toDouble(),
                            max: duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              onSeek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Color(0xFF909090), 
                          fontSize: 12,
                          fontFamily: 'Palanquin',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.replay_10,
                          color: Color(0xFF909090),
                        ),
                        onPressed: () {
                          final newPosition = position - const Duration(seconds: 10);
                          onSeek(newPosition.isNegative ? Duration.zero : newPosition);
                        },
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onPlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf7d786),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFF212121),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.forward_10,
                          color: Color(0xFF909090),
                        ),
                        onPressed: () {
                          final newPosition = position + const Duration(seconds: 10);
                          onSeek(newPosition > duration ? duration : newPosition);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
} 