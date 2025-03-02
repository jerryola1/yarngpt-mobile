import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'services/theme_service.dart';
import 'services/api_service.dart';
import 'models/generated_audio.dart';
import 'widgets/audio_player_overlay.dart';
import 'widgets/custom_notification.dart';
import 'widgets/registration_screen.dart';
import 'screens/profile_screen.dart';
import 'home_screens/home_content.dart';
import 'home_screens/placeholder_screen.dart';
import 'home_screens/audio_manager.dart';
import 'home_screens/speech_generator.dart';
import 'home_screens/navigation_manager.dart';
import 'home_screens/registration_handler.dart';
import 'home_screens/user_data_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Future<UserService> _userServiceFuture;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  String _selectedLanguage = 'English';
  String _selectedSpeaker = 'idera';
  bool _isPlaying = false;
  bool _isGenerating = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showAudioPlayer = false;
  bool showRegistrationSlider = false;
  int _remainingSpeeches = 5; // Default value
  bool _hasUsedFirstSpeech = false; // Track if first speech has been used
  String? _userName; // User's name

  final Map<String, List<Map<String, String>>> _voiceOptions = {
    'English': [
      {'value': 'idera', 'label': 'Idera (Female)'},
      {'value': 'jude', 'label': 'Jude (Male)'},
      {'value': 'emma', 'label': 'Emma (Female)'},
      {'value': 'joke', 'label': 'Joke (Female)'},
      {'value': 'osagie', 'label': 'Osagie (Male)'},
      {'value': 'remi', 'label': 'Remi (Female)'},
      {'value': 'tayo', 'label': 'Tayo (Male)'}
    ],
    'Yoruba': [
      {'value': 'abayomi', 'label': 'Abayomi (Male)'},
      {'value': 'aisha', 'label': 'Aisha (Female)'}
    ],
    'Igbo': [
      {'value': 'obinna', 'label': 'Obinna (Male)'}
    ],
    'Hausa': [
      {'value': 'amina', 'label': 'Amina (Female)'},
      {'value': 'fatima', 'label': 'Fatima (Female)'}
    ]
  };

  List<String> get _languages => _voiceOptions.keys.toList();

  List<Map<String, String>> get _currentSpeakers => _voiceOptions[_selectedLanguage] ?? [];

  int _selectedIndex = 0;

  final ApiService _apiService = ApiService();
  GeneratedAudio? _currentAudio;
  
  // Component managers
  late AudioManager _audioManager;
  late SpeechGenerator _speechGenerator;
  late NavigationManager _navigationManager;
  late RegistrationHandler _registrationHandler;
  late UserDataManager _userDataManager;

  @override
  void initState() {
    super.initState();
    _userServiceFuture = UserService.create();
    
    _initializeManagers();
    _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    
    // Set initial speaker to first available speaker for selected language
    _selectedSpeaker = _currentSpeakers.first['value'] ?? 'idera';
    
    // Check authentication status after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAuthStatus();
    });
  }
  
  void _initializeManagers() {
    _audioManager = AudioManager(
      audioPlayer: _audioPlayer,
      updateIsPlaying: (value) => setState(() => _isPlaying = value),
      updatePosition: (value) => setState(() => _position = value),
      updateDuration: (value) => setState(() => _duration = value),
      updateShowAudioPlayer: (value) => setState(() => _showAudioPlayer = value),
      context: context,
    );
    
    _speechGenerator = SpeechGenerator(
      apiService: _apiService,
      updateIsGenerating: (value) => setState(() => _isGenerating = value),
      updateCurrentAudio: (value) => setState(() => _currentAudio = value),
      refreshUserData: _loadUserData,
      updateShowRegistrationSlider: (value) => setState(() => showRegistrationSlider = value),
      context: context,
    );
    
    _navigationManager = NavigationManager(
      updateSelectedIndex: (value) => setState(() => _selectedIndex = value),
    );
    
    _registrationHandler = RegistrationHandler(
      updateShowRegistrationSlider: (value) => setState(() => showRegistrationSlider = value),
      refreshUserData: _loadUserData,
      clearTextController: () => _textController.clear(),
      updateSelectedIndex: (value) => setState(() => _selectedIndex = value),
      context: context,
    );
    
    _userDataManager = UserDataManager(
      updateRemainingSpeeches: (value) => setState(() => _remainingSpeeches = value),
      updateHasUsedFirstSpeech: (value) => setState(() => _hasUsedFirstSpeech = value),
      updateUserName: (value) => setState(() => _userName = value),
      userServiceFuture: _userServiceFuture,
    );
  }

  Future<void> _loadUserData() async {
    final userService = await _userServiceFuture;
    
    // Check and reset speech count if it's a new day
    await userService.checkAndResetSpeechCount();
    
    await _userDataManager.loadUserData();
  }

  void _handleLanguageChange(String? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
        // Set speaker to first available speaker for new language
        _selectedSpeaker = _voiceOptions[language]?.first['value'] ?? 'idera';
      });
    }
  }

  Future<void> _generateSpeech() async {
    // Check if text is empty to prevent automatic generation
    if (_textController.text.trim().isEmpty) {
      print('Preventing speech generation - text is empty');
      return;
    }
    
    final userService = await _userServiceFuture;
    await _speechGenerator.generateSpeech(
      text: _textController.text,
      speaker: _selectedSpeaker,
      language: _selectedLanguage,
      userService: userService,
      remainingSpeeches: _remainingSpeeches,
      hasUsedFirstSpeech: _hasUsedFirstSpeech,
      saveGeneratedAudio: _audioManager.saveGeneratedAudio,
    );
  }

  Future<void> _togglePlayPause() async {
    await _audioManager.togglePlayPause(_currentAudio);
  }

  Future<void> _downloadAudio() async {
    await _audioManager.downloadAudio(_currentAudio);
  }

  void _handleSeek(double value) async {
    await _audioManager.seek(Duration(seconds: value.toInt()));
  }

  // Check authentication status and update UI accordingly
  Future<void> _checkAuthStatus() async {
    print('Checking authentication status...');
    final userService = await _userServiceFuture;
    
    // Check if user just signed out
    final justSignedOut = await _userDataManager.checkIfJustSignedOut();
    if (justSignedOut) {
      print('User just signed out, refreshing UI state');
      setState(() {
        // Reset UI state as needed
        _userName = null;
        _remainingSpeeches = 5; // Default value
        showRegistrationSlider = false;
      });
    }
    
    final isAuthenticated = userService.isLoggedIn() || userService.isRegistered();
    print('User is authenticated: $isAuthenticated');
    
    // Check if user just signed in
    final justSignedIn = await _userDataManager.checkIfJustSignedIn();
    print('Just signed in: $justSignedIn');
    
    // IMPORTANT: Always hide registration slider for authenticated users
    // or users who just signed in
    if (isAuthenticated || justSignedIn) {
      print('User is authenticated or just signed in, hiding registration slider');
      setState(() {
        showRegistrationSlider = false;
      });
      
      if (justSignedIn) {
        print('User just signed in, staying on home screen');
        
        // Clear text controller to prevent automatic speech generation
        _textController.clear();
      }
      
      // Refresh user data to update UI with correct speech count
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomeScreen with _selectedIndex: $_selectedIndex');
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;
    final theme = Theme.of(context);
    
    return FutureBuilder<UserService>(
      future: _userServiceFuture,
      builder: (context, snapshot) {
        // Show loading indicator while waiting for UserService
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final userService = snapshot.data!;
        final isAuthenticated = userService.isLoggedIn() || userService.isRegistered();
        
        // CRITICAL: Force hide registration slider if user is authenticated
        if (isAuthenticated && showRegistrationSlider) {
          print('User is authenticated but registration slider was showing - hiding it now');
          // Use Future.microtask to avoid setState during build
          Future.microtask(() => setState(() => showRegistrationSlider = false));
        }
        
        return Stack(
          children: [
            Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _selectedIndex == 3 ? null : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Text(
                      'Hi, ${_userName ?? 'User'}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('assets/logo.png'),
                    ),
                  ],
                ),
                actions: [
                  // Only show profile button if authenticated
                  if (isAuthenticated)
                    IconButton(
                      icon: const Icon(Icons.person),
                      tooltip: 'Go to Profile',
                      onPressed: () {
                        print('Profile button pressed, calling direct navigation method');
                        _navigationManager.navigateToProfileScreen();
                      },
                    ),
                  // Developer reset button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset User (Dev Only)',
                    onPressed: () async {
                      await userService.resetUser();
                      await _loadUserData();
                      showCustomNotification(context, 'User status reset for testing');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => themeService.toggleTheme(),
                  ),
                ],
              ),
              body: IndexedStack(
                key: ValueKey<int>(_selectedIndex),
                index: isAuthenticated ? _selectedIndex : 0, // Always show home for unauthenticated users
                children: [
                  HomeContent(
                    searchController: _searchController,
                    textController: _textController,
                    selectedLanguage: _selectedLanguage,
                    selectedSpeaker: _selectedSpeaker,
                    languages: _languages,
                    currentSpeakers: _currentSpeakers,
                    remainingSpeeches: _remainingSpeeches,
                    isGenerating: _isGenerating,
                    currentAudio: _currentAudio,
                    isPlaying: _isPlaying,
                    position: _position,
                    duration: _duration,
                    scaleAnimation: _scaleAnimation,
                    onLanguageChanged: _handleLanguageChange,
                    onSpeakerChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSpeaker = value;
                        });
                      }
                    },
                    onGenerateSpeech: _generateSpeech,
                    onTogglePlayPause: _togglePlayPause,
                    onSeek: _handleSeek,
                    onDownload: _downloadAudio,
                  ),
                  PlaceholderScreen(title: 'Play'),
                  PlaceholderScreen(title: 'Library'),
                  const ProfileScreen(),
                ],
              ),
              // Only show bottom navigation if authenticated
              bottomNavigationBar: isAuthenticated ? NavigationBar(
                key: ValueKey<String>('navigation_bar'),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  print('Navigation bar item $index selected');
                  _navigationManager.onItemTapped(index);
                },
                backgroundColor: theme.colorScheme.surface,
                indicatorColor: theme.colorScheme.secondary.withOpacity(0.5),
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                height: 65,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    selectedIcon: Icon(
                      Icons.home,
                      color: isDark ? Colors.black87 : Colors.white,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.play_circle_outline,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    selectedIcon: Icon(
                      Icons.play_circle,
                      color: isDark ? Colors.black87 : Colors.white,
                    ),
                    label: 'Play',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.menu_book_outlined,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    selectedIcon: Icon(
                      Icons.menu_book,
                      color: isDark ? Colors.black87 : Colors.white,
                    ),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    selectedIcon: Icon(
                      Icons.person,
                      color: isDark ? Colors.black87 : Colors.white,
                    ),
                    label: 'Profile',
                  ),
                ],
              ) : null,
              bottomSheet: _showAudioPlayer && _currentAudio != null
                  ? AudioPlayerOverlay(
                      audio: _currentAudio!,
                      isPlaying: _isPlaying,
                      position: _position,
                      duration: _duration,
                      isDark: isDark,
                      onPlayPause: _togglePlayPause,
                      onSeek: (position) async {
                        await _audioPlayer.seek(position);
                        setState(() => _position = position);
                      },
                      onClose: () => setState(() {
                        _showAudioPlayer = false;
                        _audioPlayer.stop();
                        _isPlaying = false;
                        _position = Duration.zero;
                      }),
                    )
                  : null,
            ),
            // Only show registration slider if user is not authenticated AND showRegistrationSlider is true
            if (!isAuthenticated && showRegistrationSlider)
              RegistrationScreen(
                onRegistrationComplete: _registrationHandler.handleRegistrationComplete,
                onCancel: _registrationHandler.handleRegistrationCancel,
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _searchController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
