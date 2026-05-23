import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';
import 'package:opala/utils/snackbar_util.dart'; 

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  int? _anoSelecionado;
  final _placaController = TextEditingController();
  final _apelidoController = TextEditingController();

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  void _salvarVeiculo() {
    if (_marcaController.text.isEmpty ||
        _modeloController.text.isEmpty ||
        _anoSelecionado == null ||
        _placaController.text.isEmpty) {
      
      SnackbarWidget.mostrar(context, 'Preencha os campos obrigatórios.', corFundo: Colors.grey.shade800);
      return; 
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final novoVeiculo = Veiculo(
      marca: _marcaController.text,
      modelo: _modeloController.text,
      ano: _anoSelecionado!,
      placa: _placaController.text,
      apelido: _apelidoController.text,
    );

    messenger.showSnackBar(
      const SnackBar(content: Text('Veículo adicionado com sucesso!')),
    );
    navigator.pop(novoVeiculo);
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '* Campos obrigatórios',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _marcaController,
              decoration: const InputDecoration(labelText: 'Marca*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(labelText: 'Modelo*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _anoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Ano*',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                (DateTime.now().year + 1) - 1950 + 1,
                (index) => (DateTime.now().year + 1) - index,
              ).map((ano) {
                return DropdownMenuItem<int>(
                  value: ano,
                  child: Text(ano.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _anoSelecionado = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(labelText: 'Placa*', border: OutlineInputBorder()),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
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
                onPressed: _salvarVeiculo, 
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