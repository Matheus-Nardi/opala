import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:opala/services/supabase_service.dart';
import 'package:opala/screens/home_page.dart';
import 'package:opala/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.inicializar();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Session? _session;
  bool _inicializado = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Obtém a sessão atual síncrona/imediata para evitar piscadas de carregamento
    _session = Supabase.instance.client.auth.currentSession;
    _inicializado = true;

    // Escuta mudanças no estado de autenticação (login, cadastro, logout, etc)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _session = data.session;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inicializado) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueGrey),
        ),
      );
    }

    if (_session != null) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}
