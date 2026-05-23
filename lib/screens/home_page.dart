import 'package:flutter/material.dart';
import 'package:opala/controllers/veiculo_controller.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/screens/cadastro_veiculo_screen.dart';
import 'package:opala/screens/lista_abastecimento_screen.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/card_veiculo_widget.dart';
import 'package:opala/services/auth_service.dart';
import '../widgets/texto_formatado_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VeiculoController _controller = VeiculoController();

  @override
  void initState() {
    super.initState();
    _controller.carregarVeiculos();
  }

  void _removerVeiculo(Veiculo veiculo) async {
    if (veiculo.id == null) return;
    try {
      await _controller.deletarVeiculo(veiculo.id!);
      if (mounted) {
        SnackbarWidget.mostrar(context, 'Veículo removido com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        SnackbarWidget.mostrar(context, 'Erro ao remover veículo.', corFundo: Colors.redAccent);
      }
    }
  }

  void _confirmarExclusao(Veiculo veiculo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Veículo'),
        content: const Text(
          'Tem certeza que deseja remover este veículo? Todo o histórico será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              _removerVeiculo(veiculo);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opala - Controle de Veículos'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final user = AuthService.usuarioAtual;
                final metadata = user?.userMetadata;
                final String? nome = metadata?['full_name'] ?? metadata?['name'];
                final String? fotoUrl = metadata?['avatar_url'];
                final String? email = user?.email;

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                    child: fotoUrl == null
                        ? Text(
                            (nome ?? email ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          )
                        : null,
                  ),
                  accountName: Text(
                    nome ?? 'Usuário Opala',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(email ?? ''),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blueGrey),
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            const Divider(),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair da Conta',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair do App'),
                    content: const Text('Deseja realmente encerrar sua sessão?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.blueGrey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sair', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmar == true) {
                  if (context.mounted) {
                    Navigator.pop(context); // Fecha o Drawer
                  }
                  await AuthService.sair();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final novoVeiculo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroVeiculoScreen()),
          );

          if (novoVeiculo != null && novoVeiculo is Veiculo) {
            try {
              await _controller.adicionarVeiculo(novoVeiculo);
            } catch (e) {
              if (mounted) {
                SnackbarWidget.mostrar(context, 'Erro ao cadastrar veículo.', corFundo: Colors.redAccent);
              }
            }
          }
        },
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              const TextoFormatado(
                'Seus Veículos',
                tamanho: 24,
                peso: FontWeight.bold,
                cor: Colors.blueGrey,
                padding: 20,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _controller.veiculos.isEmpty
                    ? const Center(
                        child: TextoFormatado(
                          'Nenhum veículo cadastrado.',
                          tamanho: 16,
                          cor: Colors.grey,
                          estilo: FontStyle.italic,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _controller.veiculos.length,
                        itemBuilder: (context, index) {
                          final veiculoAtual = _controller.veiculos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ListaAbastecimentoScreen(veiculo: veiculoAtual),
                                  ),
                                );

                                // Ao retornar, atualiza a lista de veículos para re-calcular as médias baseadas em novos abastecimentos
                                _controller.carregarVeiculos();
                              },
                              onLongPress: () => _confirmarExclusao(veiculoAtual),
                              child: CardVeiculoWidget(veiculo: veiculoAtual),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
