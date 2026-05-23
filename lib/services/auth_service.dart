import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final _supabase = Supabase.instance.client;

  /// Obtém o usuário atual logado, ou null se não houver sessão ativa
  static User? get usuarioAtual => _supabase.auth.currentUser;

  /// Retorna true se houver um usuário logado
  static bool get estaLogado => _supabase.auth.currentSession != null;

  /// Faz login com email e senha
  static Future<AuthResponse> entrarComEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cria uma nova conta com email e senha
  static Future<AuthResponse> criarConta(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Encerra a sessão atual
  static Future<void> sair() async {
    await _supabase.auth.signOut();
  }
}
