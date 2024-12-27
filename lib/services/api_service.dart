import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  static Future<http.Response> post(String url, Map<String, dynamic> body,
      {String? token}) {
    return http.post(Uri.parse('$baseUrl$url'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
  }

  static Future<http.Response> get(String url, {String? token}) {
    return http.get(Uri.parse('$baseUrl$url'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'});
  }
}
