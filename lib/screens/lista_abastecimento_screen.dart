import 'package:flutter/material.dart';
import 'package:opala/controllers/abastecimento_controller.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/screens/cadastro_abastecimento_screen.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/card_abastecimento_widget.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class ListaAbastecimentoScreen extends StatefulWidget {
  final Veiculo veiculo;
  const ListaAbastecimentoScreen({super.key, required this.veiculo});

  @override
  State<ListaAbastecimentoScreen> createState() =>
      _ListaAbastecimentoScreenState();
}

class _ListaAbastecimentoScreenState extends State<ListaAbastecimentoScreen> {
  late final AbastecimentoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AbastecimentoController(widget.veiculo);
    _controller.carregarAbastecimentos();
  }

  void _removerAbastecimento(Abastecimento abastecimento) async {
    if (abastecimento.id == null) return;
    try {
      await _controller.deletarAbastecimento(abastecimento.id!);
      if (mounted) {
        SnackbarWidget.mostrar(context, 'Abastecimento removido com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        SnackbarWidget.mostrar(context, 'Erro ao remover abastecimento.', corFundo: Colors.redAccent);
      }
    }
  }

  void _confirmarExclusao(Abastecimento abastecimento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Abastecimento'),
        content: const Text(
          'Tem certeza que deseja remover este abastecimento? Todo o histórico será perdido.',
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
              _removerAbastecimento(abastecimento);
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
        title: Text('Abastecimentos - ${widget.veiculo.modelo}'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: _controller.abastecimentos.isEmpty
                    ? const Center(
                        child: TextoFormatado(
                          'Nenhum abastecimento cadastrado.',
                          tamanho: 16,
                          cor: Colors.grey,
                          estilo: FontStyle.italic,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _controller.abastecimentos.length,
                        itemBuilder: (context, index) {
                          final abastecimentoAtual = _controller.abastecimentos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: InkWell(
                              onLongPress: () => _confirmarExclusao(abastecimentoAtual),
                              child: CardAbastecimentoWidget(
                                abastecimento: abastecimentoAtual,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          if (widget.veiculo.id == null) {
            SnackbarWidget.mostrar(context, 'Erro: Veículo sem identificação válida.');
            return;
          }

          final novoAbastecimento = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastroAbastecimentoScreen(veiculoId: widget.veiculo.id!),
            ),
          );

          if (novoAbastecimento != null && novoAbastecimento is Abastecimento) {
            try {
              await _controller.adicionarAbastecimento(
                posto: novoAbastecimento.posto,
                tipoCombustivel: novoAbastecimento.tipoCombustivel,
                quantidade: novoAbastecimento.quantidade,
                valorTotal: novoAbastecimento.valorTotal,
                odometro: novoAbastecimento.odometro,
                tanqueCheio: novoAbastecimento.tanqueCheio,
                data: novoAbastecimento.data,
              );
            } catch (e) {
              if (mounted) {
                SnackbarWidget.mostrar(context, 'Erro ao adicionar abastecimento.', corFundo: Colors.redAccent);
              }
            }
          }
        },
      ),
    );
  }
}
