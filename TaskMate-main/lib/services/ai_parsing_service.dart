import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/constants.dart';

class AIParsingService {
  /// Parse natural language input into structured task data
  static Future<Map<String, dynamic>> parseTask(
      String naturalLanguageInput, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.aiTest),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': token,
            },
            body: jsonEncode({
              'naturalLanguageInput': naturalLanguageInput,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['parsed'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to parse task: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection error: Please check if the backend is running and accessible at ${Constants.backendUri}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a task using AI parsing
  static Future<Map<String, dynamic>> createAITask(
      String naturalLanguageInput, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.aiCreate),
            headers: {
              'Content-Type': 'application/json',
              'x-auth-token': token,
            },
            body: jsonEncode({
              'naturalLanguageInput': naturalLanguageInput,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to create AI task: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection error: Please check if the backend is running and accessible at ${Constants.backendUri}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Test backend connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.health),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get connection status message
  static Future<String> getConnectionStatus() async {
    try {
      final isConnected = await testConnection();
      if (isConnected) {
        return 'Connected to backend at ${Constants.backendUri}';
      } else {
        return 'Cannot connect to backend at ${Constants.backendUri}';
      }
    } catch (e) {
      return 'Connection test failed: $e';
    }
  }
}
