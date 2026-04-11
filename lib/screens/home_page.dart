import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/screens/cadastro_veiculo_screen.dart';
import 'package:opala/screens/lista_abastecimento_screen.dart';
import 'package:opala/widgets/card_veiculo_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Veiculo> listaVeiculos = []; // Nosso "banco de dados" temporário

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
            MaterialPageRoute(
              builder: (_) => const CadastroVeiculoScreen(),
            ),
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
            child: ListView.builder(
              itemCount: listaVeiculos.length,
              itemBuilder: (context, index) {
                final veiculoAtual = listaVeiculos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: InkWell(
                    onTap: () async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListaAbastecimentoScreen(veiculo: veiculoAtual),
                        ),
                      );

                      setState(() {});
                    },
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
