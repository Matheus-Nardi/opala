import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/utils/snackbar_util.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CadastroAbastecimentoScreen extends StatefulWidget {
  final int veiculoId;
  const CadastroAbastecimentoScreen({super.key, required this.veiculoId});

  @override
  State<CadastroAbastecimentoScreen> createState() =>
      _CadastroAbastecimentoScreenState();
}

class _CadastroAbastecimentoScreenState
    extends State<CadastroAbastecimentoScreen> {
  final _postoController = TextEditingController();
  String? _tipoCombustivelSelecionado;
  final _quantidadeController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _odometroController = TextEditingController();
  final _dataController = TextEditingController();
  bool _tanqueCheio = true;

  final List<String> _tiposCombustivel = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

  @override
  void initState() {
    super.initState();
    // Preenche com a data atual formatada por padrão para ajudar o usuário
    _dataController.text = DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  void dispose() {
    _postoController.dispose();
    _quantidadeController.dispose();
    _valorTotalController.dispose();
    _odometroController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final dataAtual = DateTime.tryParse(_dataController.text) ?? DateTime.now();
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataAtual,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              onSurface: Colors.blueGrey,
            ),
          ),
          child: child!,
        );
      },
    );
    if (dataSelecionada != null) {
      setState(() {
        _dataController.text = dataSelecionada.toIso8601String().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void salvarAbastecimento() {
      if (_postoController.text.isEmpty ||
          _tipoCombustivelSelecionado == null ||
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
      
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final novoAbastecimento = Abastecimento(
        veiculoId: widget.veiculoId,
        posto: _postoController.text,
        tipoCombustivel: _tipoCombustivelSelecionado!,
        quantidade: double.tryParse(_quantidadeController.text) ?? 0,
        valorTotal: double.tryParse(_valorTotalController.text) ?? 0,
        odometro: double.tryParse(_odometroController.text) ?? 0,
        tanqueCheio: _tanqueCheio,
        data: DateTime.tryParse(_dataController.text) ?? DateTime.now(),
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Abastecimento adicionado com sucesso!')),
      );
      navigator.pop(novoAbastecimento);
    }

    final doubleFormatter = [
      TextInputFormatter.withFunction((oldValue, newValue) {
        // Converte vírgula para ponto dinamicamente para facilitar no teclado em Português
        final newText = newValue.text.replaceAll(',', '.');
        return newValue.copyWith(text: newText);
      }),
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
    ];

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
            DropdownButtonFormField<String>(
              value: _tipoCombustivelSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Combustível*',
                border: OutlineInputBorder(),
              ),
              items: _tiposCombustivel.map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoCombustivelSelecionado = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade (L)*',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: doubleFormatter,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valorTotalController,
              decoration: const InputDecoration(
                labelText: 'Valor Total (R\$)*',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: doubleFormatter,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _odometroController,
              decoration: const InputDecoration(
                labelText: 'Odômetro (km)*',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: doubleFormatter,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dataController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data*',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blueGrey),
              ),
              onTap: () => _selecionarData(context),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const TextoFormatado('Tanque Cheio?', tamanho: 16),
              subtitle: const TextoFormatado(
                'Marque se você completou o tanque',
                tamanho: 12,
                cor: Colors.grey,
              ),
              value: _tanqueCheio,
              onChanged: (bool value) {
                setState(() {
                  _tanqueCheio = value;
                });
              },
              activeColor: Colors.blueGrey,
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
