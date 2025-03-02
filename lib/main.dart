import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'services/theme_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final themeService = await ThemeService.create();
  
  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const YarnGPTTTSApp(),
    ),
  );
}

class YarnGPTTTSApp extends StatelessWidget {
  const YarnGPTTTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: 'YarnGPT TTS',
          themeMode: themeService.themeMode,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String _response = '';

  void _submitText() async {
    String inputText = _textController.text;
    // TODO: Integrate your API call here.
    setState(() {
      _response = 'Audio generated for: $inputText';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YarnGPT TTS')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Logo at the top
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/logo.png'),
              ),
              SizedBox(height: 20),
              // Card for input and button
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: 'Enter your text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitText,
                        child: Text('Generate Audio'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display API response
              Text(
                _response,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
