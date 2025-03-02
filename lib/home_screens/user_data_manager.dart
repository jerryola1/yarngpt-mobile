import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  final Function(int) updateRemainingSpeeches;
  final Function(bool) updateHasUsedFirstSpeech;
  final Function(String?) updateUserName;
  final Future<UserService> userServiceFuture;

  UserDataManager({
    required this.updateRemainingSpeeches,
    required this.updateHasUsedFirstSpeech,
    required this.updateUserName,
    required this.userServiceFuture,
  });

  Future<void> loadUserData() async {
    final userService = await userServiceFuture;
    final remaining = await userService.getRemainingSpeeches();
    final hasUsedFirstSpeech = userService.hasUsedFirstSpeech();
    final userName = userService.getUserName();
    
    updateRemainingSpeeches(remaining);
    updateHasUsedFirstSpeech(hasUsedFirstSpeech);
    updateUserName(userName);
    
    print('User data loaded:');
    print('- Remaining speeches: $remaining');
    print('- Has used first speech: $hasUsedFirstSpeech');
    print('- User name: $userName');
    print('- Is registered: ${userService.isRegistered()}');
    print('- Is logged in: ${userService.isLoggedIn()}');
  }

  Future<bool> checkIfJustSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final justSignedIn = prefs.getBool('just_signed_in') ?? false;
    
    print('checkIfJustSignedIn called, flag value: $justSignedIn');
    
    if (justSignedIn) {
      // Reset the flag immediately to prevent multiple redirects
      await prefs.setBool('just_signed_in', false);
      print('Reset just_signed_in flag to false');
      
      // Force reload user data to update UI
      await loadUserData();
      return true;
    }
    
    return false;
  }
  
  Future<bool> checkIfJustSignedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final justSignedOut = prefs.getBool('just_signed_out') ?? false;
    
    print('checkIfJustSignedOut called, flag value: $justSignedOut');
    
    if (justSignedOut) {
      // Reset the flag immediately
      await prefs.setBool('just_signed_out', false);
      print('Reset just_signed_out flag to false');
      
      // Force reload user data to update UI
      await loadUserData();
      return true;
    }
    
    return false;
  }
} 