import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();
  final _apelidoController = TextEditingController();

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _placaController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Novo Veículo'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _marcaController,
              decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _anoController,
              decoration: const InputDecoration(labelText: 'Ano', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(labelText: 'Placa', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apelidoController,
              decoration: const InputDecoration(labelText: 'Apelido (opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final novoVeiculo = Veiculo(
                    id: DateTime.now().millisecondsSinceEpoch,
                    marca: _marcaController.text,
                    modelo: _modeloController.text,
                    ano: int.tryParse(_anoController.text) ?? 0,
                    placa: _placaController.text,
                    apelido: _apelidoController.text
                  );
                  Navigator.pop(context, novoVeiculo);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: const TextoFormatado('Salvar Veículo', cor: Colors.white, tamanho: 16, peso: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
