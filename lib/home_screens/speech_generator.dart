import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../models/generated_audio.dart';
import '../widgets/custom_notification.dart';
import 'package:uuid/uuid.dart';

class SpeechGenerator {
  final ApiService apiService;
  final Function(bool) updateIsGenerating;
  final Function(GeneratedAudio) updateCurrentAudio;
  final Function() refreshUserData;
  final Function(bool) updateShowRegistrationSlider;
  final BuildContext context;

  SpeechGenerator({
    required this.apiService,
    required this.updateIsGenerating,
    required this.updateCurrentAudio,
    required this.refreshUserData,
    required this.updateShowRegistrationSlider,
    required this.context,
  });

  Future<GeneratedAudio?> generateSpeech({
    required String text,
    required String speaker,
    required String language,
    required UserService userService,
    required int remainingSpeeches,
    required bool hasUsedFirstSpeech,
    required Function(GeneratedAudio) saveGeneratedAudio,
  }) async {
    // Additional check for empty text
    if (text.trim().isEmpty) {
      print('Preventing speech generation - text is empty');
      return null;
    }

    // Check if user is registered OR logged in (either one is sufficient)
    final isRegistered = userService.isRegistered();
    final isLoggedIn = userService.isLoggedIn();
    final isAuthenticated = isRegistered || isLoggedIn;
    
    print('Speech generation check - isRegistered: $isRegistered, isLoggedIn: $isLoggedIn');
    
    // Check if this is the first time or if user is registered
    if (!hasUsedFirstSpeech) {
      print('First free trial speech - allowing without registration');
      showCustomNotification(context, 'Using your free trial speech generation');
      
      try {
        final audio = await processSpeechGeneration(
          text: text,
          speaker: speaker,
          language: language,
          saveGeneratedAudio: saveGeneratedAudio,
        );
        
        // Mark first speech as used only after successful generation
        await userService.markFirstSpeechAsUsed();
        await refreshUserData(); // Refresh UI to show updated status
        
        // Remove automatic registration prompt after first speech
        // We'll only show it when they try to generate another speech
        
        return audio;
      } catch (e) {
        // If there's an error, don't mark the first speech as used
        showCustomNotification(context, 'Error: ${e.toString()}', isError: true);
        return null;
      }
    } else if (isAuthenticated) {
      // User is registered or logged in, check remaining speeches
      if (remainingSpeeches > 0) {
        showCustomNotification(context, 'Generating speech ($remainingSpeeches remaining)');
        await userService.decrementSpeechCount();
        await refreshUserData(); // Refresh remaining count
        return await processSpeechGeneration(
          text: text,
          speaker: speaker,
          language: language,
          saveGeneratedAudio: saveGeneratedAudio,
        );
      } else {
        showCustomNotification(
          context, 
          'You have used all your free speeches for today. Please try again tomorrow.', 
          isError: true
        );
        return null;
      }
    } else {
      // User has used trial speech but is not registered AND not logged in
      print('User has used trial speech but is not authenticated, showing registration prompt');
      
      // Double-check authentication status before showing registration slider
      if (!userService.isLoggedIn() && !userService.isRegistered()) {
        showCustomNotification(context, 'Please register or sign in to continue generating speeches.');
        updateShowRegistrationSlider(true);
      } else {
        // This shouldn't happen, but just in case there's a race condition
        print('Authentication status changed during speech generation, not showing registration slider');
        showCustomNotification(context, 'Please try again.');
      }
      return null;
    }
  }

  Future<GeneratedAudio?> processSpeechGeneration({
    required String text,
    required String speaker,
    required String language,
    required Function(GeneratedAudio) saveGeneratedAudio,
  }) async {
    updateIsGenerating(true);

    try {
      final audioUrl = await apiService.generateSpeech(
        text: text,
        speaker: speaker,
        language: language,
      );

      final generatedAudio = GeneratedAudio(
        id: const Uuid().v4(),
        audioUrl: audioUrl,
        text: text,
        speaker: speaker,
        language: language,
        createdAt: DateTime.now(),
      );

      updateCurrentAudio(generatedAudio);
      updateIsGenerating(false);

      await saveGeneratedAudio(generatedAudio);
      await refreshUserData(); // Ensure user data is refreshed after generation
      showCustomNotification(context, 'Speech generated successfully!');
      
      return generatedAudio;
    } catch (e) {
      updateIsGenerating(false);
      showCustomNotification(context, 'Error generating speech: ${e.toString()}', isError: true);
      return null;
    }
  }
} 