import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/screens/cadastro_veiculo_screen.dart';
import 'package:opala/screens/lista_abastecimento_screen.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/card_veiculo_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Veiculo> listaVeiculos = []; // Nosso "banco de dados" temporário

  void _removerVeiculo(int index) {
    setState(() {
      listaVeiculos.removeAt(index);
    });
    SnackbarWidget.mostrar(context, 'Veículo removido com sucesso!');
  }

  void _confirmarExclusao(int index) {
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
              _removerVeiculo(index);
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final novoVeiculo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroVeiculoScreen()),
          );

          if (novoVeiculo != null) {
            setState(() {
              listaVeiculos.add(novoVeiculo);
            });
          }
        },
      ),
      body: Column(
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
            child: listaVeiculos.isEmpty
                ? const Center(
                    child: TextoFormatado(
                      'Nenhum veículo cadastrado.',
                      tamanho: 16,
                      cor: Colors.grey,
                      estilo: FontStyle.italic,
                    ),
                  )
                : ListView.builder(
                    itemCount: listaVeiculos.length,
                    itemBuilder: (context, index) {
                final veiculoAtual = listaVeiculos[index];
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

                      setState(() {});
                    },
                    onLongPress: () => _confirmarExclusao(index),
                    child: CardVeiculoWidget(veiculo: veiculoAtual),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
