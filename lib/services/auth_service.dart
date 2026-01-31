import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKeyPrefix = 'user_';
  static const String _currentUserKey = 'current_user';

  // Simulate a backend response delay
  Future<void> _mockDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Register a new user
  Future<bool> register(String name, String username, String password) async {
    await _mockDelay();
    final prefs = await SharedPreferences.getInstance();

    // Check if user already exists
    if (prefs.containsKey('$_userKeyPrefix$username')) {
      return false; // User already exists
    }

    // Save user data
    final userData = {
      'name': name,
      'username': username,
      'password': password,
    };

    await prefs.setString('$_userKeyPrefix$username', jsonEncode(userData));

    // Auto login after register
    await prefs.setString(_currentUserKey, username);
    return true;
  }

  // Login user
  Future<bool> login(String username, String password) async {
    await _mockDelay();
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString('$_userKeyPrefix$username');
    if (userJson == null) {
      return false; // User not found
    }

    final userData = jsonDecode(userJson);
    if (userData['password'] == password) {
      await prefs.setString(_currentUserKey, username);
      return true;
    }

    return false; // Incorrect password
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  // Get current user name
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_currentUserKey);
    if (username == null) return null;

    final userJson = prefs.getString('$_userKeyPrefix$username');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return userData['name'];
    }
    return null;
  }
}
