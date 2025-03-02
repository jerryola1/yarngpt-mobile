import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://hull-chat--yarn-gpt-api-fastapi-app.modal.run';
  static const int _maxWords = 60;
  
  // Cloudinary configuration
  static const Map<String, String> _cloudinaryConfig = {
    'cloud_name': 'dpq2iblna',
    'api_key': '737484834235925',
    'api_secret': '8ngMxbUSasOOZV6Y1HO7Tye4IJ0',
  };

  Future<String> generateSpeech({
    required String text,
    required String speaker,
    required String language,
  }) async {
    // Check word count
    final wordCount = text.split(' ').where((word) => word.isNotEmpty).length;
    if (wordCount > _maxWords) {
      throw Exception('Text exceeds maximum limit of $_maxWords words');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/generate-speech'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'speaker': speaker,
          'language': language.toLowerCase(),
          'temperature': 0.1,
          'repetition_penalty': 1.1,
          'max_length': 4000,
          'cloudinary': {
            'cloud_name': _cloudinaryConfig['cloud_name'],
            'api_key': _cloudinaryConfig['api_key'],
            'api_secret': _cloudinaryConfig['api_secret'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['audio_url'];
      } else {
        print('API Error Response: ${response.body}');  // For debugging
        throw Exception('Failed to generate speech: ${response.statusCode}');
      }
    } catch (e) {
      print('Error details: $e');  // For debugging
      throw Exception('Error generating speech: $e');
    }
  }
} 