import 'package:flutter/material.dart';

class NavigationManager {
  final Function(int) updateSelectedIndex;

  NavigationManager({
    required this.updateSelectedIndex,
  });

  void onItemTapped(int index) {
    print('Bottom navigation tapped, changing index from current to $index');
    updateSelectedIndex(index);
  }

  void navigateToProfileScreen() {
    print('Direct navigation to profile screen called');
    // Navigate to profile screen once, no need for post-frame callback
    updateSelectedIndex(3);
  }
} 