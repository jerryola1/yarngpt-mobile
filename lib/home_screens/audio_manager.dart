import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/generated_audio.dart';
import '../widgets/custom_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AudioManager {
  final AudioPlayer audioPlayer;
  final Function(bool) updateIsPlaying;
  final Function(Duration) updatePosition;
  final Function(Duration) updateDuration;
  final Function(bool) updateShowAudioPlayer;
  final BuildContext context;

  AudioManager({
    required this.audioPlayer,
    required this.updateIsPlaying,
    required this.updatePosition,
    required this.updateDuration,
    required this.updateShowAudioPlayer,
    required this.context,
  }) {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    audioPlayer.onPositionChanged.listen((position) {
      updatePosition(position);
    });

    audioPlayer.onDurationChanged.listen((duration) {
      updateDuration(duration);
    });

    audioPlayer.onPlayerComplete.listen((_) {
      updateIsPlaying(false);
      updatePosition(Duration.zero);
    });
  }

  Future<void> togglePlayPause(GeneratedAudio? currentAudio) async {
    if (currentAudio == null) return;

    try {
      if (audioPlayer.state == PlayerState.playing) {
        await audioPlayer.pause();
        updateIsPlaying(false);
      } else {
        updateShowAudioPlayer(true);
        await audioPlayer.play(UrlSource(currentAudio.audioUrl));
        updateIsPlaying(true);
      }
    } catch (e) {
      showCustomNotification(context, 'Error playing audio: $e', isError: true);
    }
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
    updatePosition(position);
  }

  Future<void> downloadAudio(GeneratedAudio? currentAudio) async {
    if (currentAudio == null) return;
    // TODO: Implement download functionality
    showCustomNotification(context, 'Download started...');
  }

  Future<void> saveGeneratedAudio(GeneratedAudio audio) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAudios = prefs.getStringList('generated_audios') ?? [];
    savedAudios.add(jsonEncode(audio.toJson()));
    await prefs.setStringList('generated_audios', savedAudios);
  }

  void dispose() {
    audioPlayer.dispose();
  }
} 