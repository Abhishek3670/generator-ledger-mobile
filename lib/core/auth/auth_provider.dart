import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, initial }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.initial;
  User? _user;

  AuthProvider(this._authService) {
    _restoreAuth();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isInitial => _status == AuthStatus.initial;

  Future<String?> getToken() => _authService.getToken();

  Future<void> _restoreAuth() async {
    try {
      final token = await _authService.getToken();
      final user = await _authService.getUser();

      if (token != null && user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        // Clear anything partial
        await _authService.clear();
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String token, User user) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _authService.saveToken(token);
    await _authService.saveUser(user);

    _user = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.clear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
