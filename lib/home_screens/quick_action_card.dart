import 'package:flutter/material.dart';
import '../models/generated_audio.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String duration;
  final Color color;
  final bool isLight;
  final GeneratedAudio? currentAudio;
  final bool isPlaying;
  final VoidCallback onTogglePlayPause;

  const QuickActionCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.color,
    required this.isLight,
    required this.currentAudio,
    required this.isPlaying,
    required this.onTogglePlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If this is the Quick Speech card and we have a current audio
    if (title == 'Quick Speech' && currentAudio != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Generated',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentAudio!.text.length > 30 
                  ? '${currentAudio!.text.substring(0, 30)}...'
                  : currentAudio!.text,
              style: TextStyle(
                fontSize: 12,
                color: isLight ? Colors.black87.withOpacity(0.7) : Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: onTogglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.amber : Colors.amber[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey[200] : Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentAudio!.speaker,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Original card for other cases
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isLight ? Colors.black87 : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLight ? Colors.amber : Colors.amber[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: isLight ? Colors.black87 : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.grey[200] : Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 