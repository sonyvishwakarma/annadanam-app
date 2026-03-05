import 'package:http/http.dart' as http;

class ConnectionTester {
  static Future<Map<String, dynamic>> testConnection(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Accept': 'application/json'},
      );
      
      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200 
            ? '✅ Backend connection successful!' 
            : '❌ Backend responded with status ${response.statusCode}',
        'status': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '❌ Cannot connect to backend: $e',
        'status': 0,
        'body': '',
      };
    }
  }
  
  static Future<Map<String, dynamic>> testAuthEndpoint(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Accept': 'application/json'},
      );
      
      return {
        'success': true,
        'message': 'Auth endpoint accessible',
        'status': response.statusCode,
        'expected': 401, // Should be unauthorized without token
        'isCorrect': response.statusCode == 401,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to auth endpoint: $e',
        'status': 0,
      };
    }
  }
}