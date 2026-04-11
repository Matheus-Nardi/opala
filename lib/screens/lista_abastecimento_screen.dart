import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/screens/cadastro_abastecimento_screen.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/card_abastecimento_widget.dart';

class ListaAbastecimentoScreen extends StatefulWidget {
  final Veiculo veiculo;
  const ListaAbastecimentoScreen({super.key, required this.veiculo});

  @override
  State<ListaAbastecimentoScreen> createState() =>
      _ListaAbastecimentoScreenState();
}

class _ListaAbastecimentoScreenState extends State<ListaAbastecimentoScreen> {
  void _removerAbastecimento(int index) {
    setState(() {
      widget.veiculo.abastecimentos.removeAt(index);
    });

    SnackbarWidget.mostrar(context, 'Abastecimento removido com sucesso!');
  }

  void _confirmarExclusao(int index) {
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
              _removerAbastecimento(index);
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

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.veiculo.abastecimentos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: InkWell(
                    onLongPress: () => _confirmarExclusao(index),
                    child: CardAbastecimentoWidget(
                      abastecimento: widget.veiculo.abastecimentos[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final novoAbastecimento = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroAbastecimentoScreen(),
            ),
          );

          if (novoAbastecimento != null) {
            setState(() {
              widget.veiculo.abastecimentos.add(novoAbastecimento);
            });
          }
        },
      ),
    );
  }
}
