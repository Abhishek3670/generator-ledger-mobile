import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth_service.dart';
import '../api/api_client.dart';
import 'package:dio/dio.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating, initial, loggingOut }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  ApiClient? _apiClient;
  AuthStatus _status = AuthStatus.initial;
  User? _user;

  AuthProvider(this._authService);

  /// Sets the ApiClient after it is created.
  /// This is needed because ApiClient depends on AuthProvider for tokens,
  /// but AuthProvider needs ApiClient for logout.
  void setApiClient(ApiClient apiClient) {
    _apiClient = apiClient;
    _restoreAuth();
  }

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isInitial => _status == AuthStatus.initial;

  Future<String?> getToken() => _authService.getToken();

  Future<void> _restoreAuth() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        final user = await _authService.getUser();
        if (user != null) {
          _user = user;
          _status = AuthStatus.authenticated;
        } else {
          await _authService.clear();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        await _authService.clear();
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String token, User user, int expiresIn) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _authService.saveToken(token);
    await _authService.saveUser(user);
    
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await _authService.saveExpiry(expiry);

    _user = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    // Prevent recursion and multiple simultaneous logout calls
    if (_status == AuthStatus.loggingOut || _status == AuthStatus.unauthenticated) {
      return;
    }

    final previousStatus = _status;
    _status = AuthStatus.loggingOut;
    notifyListeners();

    final token = await _authService.getToken();
    
    // Call backend logout BEFORE clearing local auth so the token is still available
    if (token != null && _apiClient != null && previousStatus == AuthStatus.authenticated) {
      try {
        // Use skipAuthHandler to prevent the global 401 interceptor from re-entering logout
        await _apiClient!.dio.post(
          '/api/logout',
          options: Options(extra: {'skipAuthHandler': true}),
        );
      } on DioException catch (_) {
        // Ignore logout errors (401, 500, network), we still clear locally
      } catch (_) {
        // Ignore other errors
      }
    }

    // Always clear local state exactly once
    await _authService.clear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
