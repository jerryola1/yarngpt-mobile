import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../models/generated_audio.dart';
import '../widgets/custom_notification.dart';
import 'quick_action_card.dart';

class HomeContent extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController textController;
  final String selectedLanguage;
  final String selectedSpeaker;
  final List<String> languages;
  final List<Map<String, String>> currentSpeakers;
  final int remainingSpeeches;
  final bool isGenerating;
  final GeneratedAudio? currentAudio;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Animation<double> scaleAnimation;
  
  final Function(String?) onLanguageChanged;
  final Function(String?) onSpeakerChanged;
  final VoidCallback onGenerateSpeech;
  final VoidCallback onTogglePlayPause;
  final Function(double) onSeek;
  final VoidCallback onDownload;

  const HomeContent({
    Key? key,
    required this.searchController,
    required this.textController,
    required this.selectedLanguage,
    required this.selectedSpeaker,
    required this.languages,
    required this.currentSpeakers,
    required this.remainingSpeeches,
    required this.isGenerating,
    required this.currentAudio,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.scaleAnimation,
    required this.onLanguageChanged,
    required this.onSpeakerChanged,
    required this.onGenerateSpeech,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions Row
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'Quick Speech',
                    duration: '15 min',
                    color: isDark ? theme.colorScheme.surface : Colors.black87,
                    isLight: false,
                    currentAudio: currentAudio,
                    isPlaying: isPlaying,
                    onTogglePlayPause: onTogglePlayPause,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'Voice Settings',
                    duration: '12 min',
                    color: theme.colorScheme.surface,
                    isLight: !isDark,
                    currentAudio: null,
                    isPlaying: false,
                    onTogglePlayPause: () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Speech Generation Card
            ScaleTransition(
              scale: scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generate Speech',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        // Remaining speeches indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: remainingSpeeches > 0 
                                ? Colors.green.withOpacity(0.2) 
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Remaining: $remainingSpeeches',
                            style: TextStyle(
                              fontSize: 12,
                              color: remainingSpeeches > 0 
                                  ? Colors.green 
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Enter text',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.text_fields,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      decoration: InputDecoration(
                        labelText: 'Language',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.language,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      dropdownColor: theme.colorScheme.surface,
                      items: languages.map((String language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(
                            language,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onLanguageChanged,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSpeaker,
                      decoration: InputDecoration(
                        labelText: 'Speaker',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.record_voice_over,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      dropdownColor: theme.colorScheme.surface,
                      items: currentSpeakers.map((speaker) {
                        return DropdownMenuItem(
                          value: speaker['value'],
                          child: Text(
                            speaker['label'] ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onSpeakerChanged,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : onGenerateSpeech,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: isDark ? Colors.black87 : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(isGenerating ? 'Generating...' : 'Generate Speech'),
                      ),
                    ),
                    if (currentAudio != null) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            onPressed: onTogglePlayPause,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble(),
                              onChanged: onSeek,
                            ),
                          ),
                          Text(
                            '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          IconButton(
                            onPressed: onDownload,
                            icon: Icon(
                              Icons.download,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
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