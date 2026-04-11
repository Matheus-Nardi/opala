import 'package:flutter/material.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CadastroAbastecimentoScreen extends StatefulWidget {
  const CadastroAbastecimentoScreen({super.key});

  @override
  State<CadastroAbastecimentoScreen> createState() =>
      _CadastroAbastecimentoScreenState();
}

class _CadastroAbastecimentoScreenState
    extends State<CadastroAbastecimentoScreen> {
  final _postoController = TextEditingController();
  final _tipoCombustivelController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _odometroController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void dispose() {
    _postoController.dispose();
    _tipoCombustivelController.dispose();
    _quantidadeController.dispose();
    _valorTotalController.dispose();
    _odometroController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void salvarAbastecimento() {
      if (_postoController.text.isEmpty ||
          _tipoCombustivelController.text.isEmpty ||
          _quantidadeController.text.isEmpty ||
          _valorTotalController.text.isEmpty ||
          _odometroController.text.isEmpty ||
          _dataController.text.isEmpty) {
        SnackbarWidget.mostrar(
          context,
          'Preencha os campos obrigatórios.',
          corFundo: Colors.grey.shade800,
        );
        return;
      }
      final novoAbastecimento = Abastecimento(
        id: DateTime.now().millisecondsSinceEpoch,
        posto: _postoController.text,
        tipoCombustivel: _tipoCombustivelController.text,
        quantidade: double.tryParse(_quantidadeController.text) ?? 0,
        valorTotal: double.tryParse(_valorTotalController.text) ?? 0,
        odometro: double.tryParse(_odometroController.text) ?? 0,
        data: DateTime.tryParse(_dataController.text) ?? DateTime.now(),
      );

      SnackbarWidget.mostrar(context, 'Abastecimento adicionado com sucesso!');
      Navigator.pop(context, novoAbastecimento);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Novo Abastecimento'),
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
              controller: _postoController,
              decoration: const InputDecoration(
                labelText: 'Posto*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tipoCombustivelController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Combustível*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valorTotalController,
              decoration: const InputDecoration(
                labelText: 'Valor Total*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _odometroController,
              decoration: const InputDecoration(
                labelText: 'Odômetro*',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Data*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: salvarAbastecimento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child: const TextoFormatado(
                  'Salvar Abastecimento',
                  cor: Colors.white,
                  tamanho: 16,
                  peso: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
