import 'package:flutter/material.dart';
import '../widgets/custom_notification.dart';

class RegistrationHandler {
  final Function(bool) updateShowRegistrationSlider;
  final Function() refreshUserData;
  final Function() clearTextController;
  final Function(int) updateSelectedIndex;
  final BuildContext context;

  RegistrationHandler({
    required this.updateShowRegistrationSlider,
    required this.refreshUserData,
    required this.clearTextController,
    required this.updateSelectedIndex,
    required this.context,
  });

  Future<void> handleRegistrationComplete() async {
    print('Registration complete handler called');
    
    // First, clear any text in the text controller to prevent automatic speech generation
    clearTextController();
    
    // Hide the registration slider
    updateShowRegistrationSlider(false);
    
    // Refresh user data to update UI with new registration status
    await refreshUserData();
    
    // Show success notification
    showCustomNotification(
      context, 
      'Registration successful! You can now generate up to 10 speeches daily.',
    );
    
    // Stay on home screen instead of navigating to profile
    print('Staying on home screen after successful registration');
    updateSelectedIndex(0); // Index 0 is the home screen
  }

  void handleRegistrationCancel() {
    print('Registration cancelled by user');
    updateShowRegistrationSlider(false);
    
    // Reset text controller if user cancels registration during speech generation
    clearTextController();
    
    showCustomNotification(
      context, 
      'Registration is required to generate more speeches. You can try again later.', 
      isError: true
    );
  }
} 