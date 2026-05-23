import 'dart:io';
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

  /// Faz login com o Google (OAuth)
  static Future<void> entrarComGoogle() async {
    // 1. Inicia o servidor local na porta 3000 antes de abrir o browser
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
      _escutarCallbackLocal(server);
    } catch (e) {
      // Se a porta 3000 já estiver em uso, apenas loga. O usuário ainda pode receber o redirecionamento se o app ja estava ouvindo.
      print('Aviso ao iniciar servidor local: $e');
    }

    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'http://localhost:3000',
      queryParams: {
        'prompt': 'select_account',
      },
    );
  }

  static void _escutarCallbackLocal(HttpServer server) async {
    try {
      await for (HttpRequest request in server) {
        final code = request.uri.queryParameters['code'];
        if (code != null) {
          // Troca o código de autenticação pela sessão ativa
          await _supabase.auth.exchangeCodeForSession(code);

          // Retorna uma página amigável ao navegador do usuário
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write('''
              <!DOCTYPE html>
              <html>
                <head>
                  <meta charset="utf-8">
                  <title>Autenticado</title>
                  <style>
                    body { font-family: sans-serif; text-align: center; padding-top: 80px; background-color: #ECEFF1; }
                    .card { display: inline-block; padding: 40px; background: white; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.08); }
                    h1 { color: #37474F; margin-bottom: 8px; }
                    p { color: #78909C; font-size: 16px; margin-top: 0; }
                  </style>
                </head>
                <body>
                  <div class="card">
                    <h1>Autenticação concluída!</h1>
                    <p>Você já pode fechar esta aba e retornar ao aplicativo Opala.</p>
                  </div>
                </body>
              </html>
            ''');
          await request.response.close();
          break; // Para o loop e fecha o servidor
        } else {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Erro: Código não encontrado.');
          await request.response.close();
        }
      }
    } catch (e) {
      print('Erro ao processar callback: $e');
    } finally {
      await server.close(force: true);
    }
  }
}
