import 'package:flutter/material.dart';
import 'package:opala/services/auth_service.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _carregando = false;
  bool _senhaOculta = true;
  bool _modoLogin = true; // Se false, exibe modo de Cadastro

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
    });

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    try {
      if (_modoLogin) {
        await AuthService.entrarComEmail(email, senha);
        if (mounted) {
          SnackbarWidget.mostrar(context, 'Bem-vindo de volta!');
        }
      } else {
        await AuthService.criarConta(email, senha);
        if (mounted) {
          SnackbarWidget.mostrar(
            context,
            'Conta criada com sucesso! Verifique seu e-mail caso necessário ou faça login.',
          );
          // Volta para o modo de login para o usuário entrar
          setState(() {
            _modoLogin = true;
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String mensagemErro = e.message;
        if (e.message.contains('Invalid login credentials')) {
          mensagemErro = 'E-mail ou senha incorretos.';
        } else if (e.message.contains('User already exists')) {
          mensagemErro = 'Este e-mail já está cadastrado.';
        } else if (e.message.contains('Password should be')) {
          mensagemErro = 'A senha precisa ter pelo menos 6 caracteres.';
        }
        SnackbarWidget.mostrar(context, mensagemErro, corFundo: Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        SnackbarWidget.mostrar(
          context,
          'Ocorreu um erro inesperado. Tente novamente.',
          corFundo: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone e Título da Marca
                const Icon(
                  Icons.directions_car_filled,
                  size: 80,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: TextoFormatado(
                    'OPALA',
                    tamanho: 32,
                    peso: FontWeight.bold,
                    cor: Colors.blueGrey,
                  ),
                ),
                const Center(
                  child: TextoFormatado(
                    'Controle de Abastecimentos',
                    tamanho: 14,
                    cor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Título do Modo (Entrar / Cadastrar)
                TextoFormatado(
                  _modoLogin ? 'Acessar Conta' : 'Criar Nova Conta',
                  tamanho: 22,
                  peso: FontWeight.bold,
                  cor: Colors.blueGrey.shade800,
                ),
                const SizedBox(height: 20),

                // Campo de E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email, color: Colors.blueGrey),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu e-mail.';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Informe um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: _senhaOculta,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaOculta ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _senhaOculta = !_senhaOculta;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de Envio (Entrar / Cadastrar)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _submeter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      disabledBackgroundColor: Colors.blueGrey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : TextoFormatado(
                            _modoLogin ? 'Entrar' : 'Cadastrar',
                            cor: Colors.white,
                            tamanho: 16,
                            peso: FontWeight.bold,
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Alternador de modo
                TextButton(
                  onPressed: () {
                    setState(() {
                      _modoLogin = !_modoLogin;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: TextoFormatado(
                    _modoLogin
                        ? 'Não tem uma conta? Cadastre-se'
                        : 'Já tem uma conta? Faça Login',
                    cor: Colors.blueGrey.shade700,
                    tamanho: 14,
                    peso: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
