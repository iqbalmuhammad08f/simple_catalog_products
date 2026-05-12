import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthController extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  // ─── Login ──────────────────────────────────────────────────────────────
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.login(username, password);

    if (result['success'] == true) {
      _token = result['token'] as String;
      _user = result['user'] as UserModel;
      await _storage.write(key: 'auth_token', value: _token);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'] as String;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── Load saved token ───────────────────────────────────────────────────
  Future<bool> loadToken() async {
    final saved = await _storage.read(key: 'auth_token');
    if (saved != null) {
      _token = saved;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _token = null;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}