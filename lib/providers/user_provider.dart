import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  String _userEmail = '';
  bool _isAuthenticated = false;

  String get userEmail => _userEmail;
  bool get isAuthenticated => _isAuthenticated;

  /// Tries ReqRes login first; if fails, falls back to demo credentials
  Future<bool> login(String email, String password) async {
    // First try ReqRes mock login
    final ok = await _api.login(email, password);
    if (ok) {
      _userEmail = email;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    // Fallback: demo creds
    if (email == 'test@test.com' && password == 'password') {
      _userEmail = email;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _userEmail = '';
    _isAuthenticated = false;
    notifyListeners();
  }
}
