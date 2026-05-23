import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/services/veiculo_service.dart';
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

  File? _imagemSelecionada;
  bool _enviandoImagem = false;

  Future<void> _selecionarImagem() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagemSelecionada = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarWidget.mostrar(context, 'Erro ao selecionar imagem: $e', corFundo: Colors.redAccent);
      }
    }
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  void _salvarVeiculo() async {
    if (_marcaController.text.isEmpty ||
        _modeloController.text.isEmpty ||
        _anoSelecionado == null ||
        _placaController.text.isEmpty) {
      
      SnackbarWidget.mostrar(context, 'Preencha os campos obrigatórios.', corFundo: Colors.grey.shade800);
      return; 
    }

    setState(() {
      _enviandoImagem = true;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    String? fotoUrl;

    try {
      if (_imagemSelecionada != null) {
        final service = VeiculoService();
        final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        fotoUrl = await service.uploadFotoVeiculo(_imagemSelecionada!.path, nomeArquivo);
      }

      final novoVeiculo = Veiculo(
        marca: _marcaController.text,
        modelo: _modeloController.text,
        ano: _anoSelecionado!,
        placa: _placaController.text,
        apelido: _apelidoController.text,
        fotoUrl: fotoUrl,
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Veículo adicionado com sucesso!')),
      );
      navigator.pop(novoVeiculo);
    } catch (e) {
      if (mounted) {
        SnackbarWidget.mostrar(
          context,
          'Erro ao salvar veículo: $e',
          corFundo: Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviandoImagem = false;
        });
      }
    }
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
            GestureDetector(
              onTap: _enviandoImagem ? null : _selecionarImagem,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imagemSelecionada != null
                      ? DecorationImage(
                          image: FileImage(_imagemSelecionada!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imagemSelecionada == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.blueGrey),
                          SizedBox(height: 8),
                          TextoFormatado(
                            'Adicionar foto do veículo',
                            cor: Colors.blueGrey,
                            tamanho: 14,
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
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
                onPressed: _enviandoImagem ? null : _salvarVeiculo, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: _enviandoImagem
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const TextoFormatado('Salvar Veículo', cor: Colors.white, tamanho: 16, peso: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}