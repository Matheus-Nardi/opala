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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_road),
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
        ],
      ),
      body: Column(
        children: [
          const TextoFormatado(
            'SEUS VEÍCULOS',
            tamanho: 26,
            peso: FontWeight.bold,
            cor: Colors.indigo,
            padding: 20,
          ),
          const TextoFormatado(
            'Instrução: Role a tela para explorar seus veículos cadastrados.',
            corFundo: Color(0xFFFFF9C4),
            peso: FontWeight.w500,
            estilo: FontStyle.italic,
            padding: 20,
          ),

          const Divider(),

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
          const Divider(),

          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}
