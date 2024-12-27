import 'dart:convert';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  Future<User?> login(String email, String password) async {
    final response = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['loginResult']);
      await _saveUserToPreferences(user);
      return user;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await ApiService.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> _saveUserToPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', user.userId);
    prefs.setString('name', user.name);
    prefs.setString('token', user.token);
  }

  Future<User?> getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final name = prefs.getString('name');
    final token = prefs.getString('token');
    if (userId != null && name != null && token != null) {
      return User(userId: userId, name: name, token: token);
    }
    return null;
  }

  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ??
        false; // Default ke false jika tidak ada
  }

  Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  Future<String> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('languageCode') ??
        'en'; // Default ke 'en' jika tidak ada
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
