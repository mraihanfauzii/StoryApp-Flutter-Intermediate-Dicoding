import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Locale _locale = const Locale('en');

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  Locale get locale => _locale;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await _authService.getUserFromPreferences();
    _isDarkMode = await _authService.getThemePreference();
    String languageCode = await _authService.getLanguagePreference();
    _locale = Locale(languageCode);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name, email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void changeLanguage(Locale locale) async {
    _locale = locale;
    await _authService.saveLanguagePreference(locale.languageCode);
    notifyListeners();
  }

  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _authService.saveThemePreference(value);
    notifyListeners();
  }
}