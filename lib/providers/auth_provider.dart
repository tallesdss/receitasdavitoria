import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthService get authService => _authService;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated;
  User? get currentUser => _authService.currentUser;

  AuthProvider() {
    // Escutar mudanças no estado de autenticação
    _authService.authStateChanges.listen((event) {
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? nome,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        nome: nome,
      );

      if (response.user != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Falha ao criar conta. Tente novamente.');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Falha ao fazer login. Verifique suas credenciais.');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signOut();
      _setLoading(false);
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? nome,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.updateUserProfile(
        nome: nome,
        avatarUrl: avatarUrl,
      );
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      return await _authService.getCurrentUserProfile();
    } catch (error) {
      _setError(_getErrorMessage(error));
      return null;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Credenciais inválidas. Verifique seu e-mail e senha.';
        case 'User already registered':
          return 'Este e-mail já está cadastrado.';
        case 'Password should be at least 6 characters':
          return 'A senha deve ter pelo menos 6 caracteres.';
        case 'Unable to validate email address: invalid format':
          return 'Formato de e-mail inválido.';
        default:
          return error.message;
      }
    }

    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
