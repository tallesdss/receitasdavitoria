import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Criar conta com e-mail e senha
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? nome,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: nome != null ? {'nome': nome} : null,
      );

      if (response.user != null) {
        // Criar registro na tabela usuários se necessário
        await _createUserProfile(response.user!, nome);
      }

      notifyListeners();
      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Fazer login com e-mail e senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      notifyListeners();
      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Alterar senha
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (error) {
      rethrow;
    }
  }

  // Enviar e-mail para reset de senha
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (error) {
      rethrow;
    }
  }

  // Fazer logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Criar perfil do usuário na tabela usuários
  Future<void> _createUserProfile(User user, String? nome) async {
    try {
      final userData = {
        'id': user.id,
        'email': user.email,
        'nome': nome ?? user.email?.split('@').first,
        'data_criacao': DateTime.now().toIso8601String(),
        'data_atualizacao': DateTime.now().toIso8601String(),
      };

      await _supabase.from('usuarios').upsert(userData);
    } catch (error) {
      // Se a tabela ainda não existir, ignorar por enquanto
      debugPrint('Erro ao criar perfil do usuário: $error');
    }
  }

  // Obter dados do perfil do usuário atual
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      debugPrint('Erro ao obter perfil do usuário: $error');
      return null;
    }
  }

  // Atualizar perfil do usuário
  Future<void> updateUserProfile({
    String? nome,
    String? avatarUrl,
  }) async {
    if (!isAuthenticated) return;

    try {
      final updates = {
        'data_atualizacao': DateTime.now().toIso8601String(),
      };

      if (nome != null) updates['nome'] = nome;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase
          .from('usuarios')
          .update(updates)
          .eq('id', currentUser!.id);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Deletar conta
  Future<void> deleteAccount() async {
    if (!isAuthenticated) return;

    try {
      // Primeiro deletar dados do usuário
      await _supabase.from('usuarios').delete().eq('id', currentUser!.id);

      // Depois deletar a conta de autenticação
      await _supabase.auth.admin.deleteUser(currentUser!.id);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
