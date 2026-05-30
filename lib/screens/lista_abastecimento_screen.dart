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

  String _formatarData(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _FiltroBottomSheet(
          filtroTipoCombustivel: _controller.filtroTipoCombustivel,
          filtroDataInicial: _controller.filtroDataInicial,
          filtroDataFinal: _controller.filtroDataFinal,
          onAplicar: (tipo, inicio, fim) {
            _controller.aplicarFiltros(
              tipoCombustivel: tipo,
              dataInicial: inicio,
              dataFinal: fim,
            );
          },
          onLimpar: () {
            _controller.limparFiltros();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return AppBar(
              title: Text('Abastecimentos - ${widget.veiculo.modelo}'),
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    if (_controller.abastecimentosFiltrados.isEmpty) {
                      SnackbarWidget.mostrar(
                        context,
                        'Não há dados para exportar.',
                        corFundo: Colors.orangeAccent,
                      );
                      return;
                    }
                    _controller.exportarPdf();
                  },
                ),
                IconButton(
                  icon: Icon(
                    _controller.temFiltrosAtivos ? Icons.filter_alt : Icons.filter_alt_outlined,
                  ),
                  onPressed: _abrirFiltros,
                ),
              ],
            );
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> chips = [];
          if (_controller.filtroTipoCombustivel != null) {
            chips.add(
              Chip(
                label: Text('Combustível: ${_controller.filtroTipoCombustivel}'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  _controller.removerFiltroTipo();
                },
              ),
            );
          }
          if (_controller.filtroDataInicial != null || _controller.filtroDataFinal != null) {
            String label = 'Período: ';
            if (_controller.filtroDataInicial != null) {
              label += _formatarData(_controller.filtroDataInicial);
            }
            label += ' até ';
            if (_controller.filtroDataFinal != null) {
              label += _formatarData(_controller.filtroDataFinal);
            }
            chips.add(
              Chip(
                label: Text(label),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  _controller.removerFiltroPeriodo();
                },
              ),
            );
          }

          final Widget chipsRow = chips.isEmpty
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: chips
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: c,
                            ))
                        .toList(),
                  ),
                );

          return Column(
            children: [
              chipsRow,
              Expanded(
                child: _controller.abastecimentosFiltrados.isEmpty
                    ? Center(
                        child: TextoFormatado(
                          _controller.temFiltrosAtivos
                              ? 'Nenhum abastecimento encontrado para os filtros selecionados.'
                              : 'Nenhum abastecimento cadastrado.',
                          tamanho: 16,
                          cor: Colors.grey,
                          estilo: FontStyle.italic,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _controller.abastecimentosFiltrados.length,
                        itemBuilder: (context, index) {
                          final abastecimentoAtual = _controller.abastecimentosFiltrados[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: InkWell(
                              onLongPress: () => _confirmarExclusao(abastecimentoAtual),
                              child: CardAbastecimentoWidget(
                                abastecimento: abastecimentoAtual,
                                controller: _controller,
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

class _FiltroBottomSheet extends StatefulWidget {
  final String? filtroTipoCombustivel;
  final DateTime? filtroDataInicial;
  final DateTime? filtroDataFinal;
  final Function(String?, DateTime?, DateTime?) onAplicar;
  final VoidCallback onLimpar;

  const _FiltroBottomSheet({
    required this.filtroTipoCombustivel,
    required this.filtroDataInicial,
    required this.filtroDataFinal,
    required this.onAplicar,
    required this.onLimpar,
  });

  @override
  State<_FiltroBottomSheet> createState() => _FiltroBottomSheetState();
}

class _FiltroBottomSheetState extends State<_FiltroBottomSheet> {
  String? _tipoCombustivel;
  DateTime? _dataInicial;
  DateTime? _dataFinal;

  @override
  void initState() {
    super.initState();
    _tipoCombustivel = widget.filtroTipoCombustivel;
    _dataInicial = widget.filtroDataInicial;
    _dataFinal = widget.filtroDataFinal;
  }

  Future<void> _selecionarDataInicial(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicial ?? DateTime.now(),
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
    if (data != null) {
      setState(() {
        _dataInicial = data;
        if (_dataFinal != null && _dataFinal!.isBefore(data)) {
          _dataFinal = data;
        }
      });
    }
  }

  Future<void> _selecionarDataFinal(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataFinal ?? _dataInicial ?? DateTime.now(),
      firstDate: _dataInicial ?? DateTime(2000),
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
    if (data != null) {
      setState(() {
        _dataFinal = data;
      });
    }
  }

  String _formatarData(DateTime? dt) {
    if (dt == null) return 'Selecionar';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextoFormatado(
            'Filtrar Abastecimentos',
            tamanho: 20,
            peso: FontWeight.bold,
            cor: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _tipoCombustivel,
            decoration: const InputDecoration(
              labelText: 'Tipo de Combustível',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos'),
              ),
              ...['Gasolina', 'Etanol', 'Diesel', 'GNV'].map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _tipoCombustivel = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const TextoFormatado(
            'Período',
            tamanho: 16,
            peso: FontWeight.bold,
            cor: Colors.blueGrey,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selecionarDataInicial(context),
                  icon: const Icon(Icons.date_range, size: 18, color: Colors.blueGrey),
                  label: Text(
                    'De: ${_formatarData(_dataInicial)}',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selecionarDataFinal(context),
                  icon: const Icon(Icons.date_range, size: 18, color: Colors.blueGrey),
                  label: Text(
                    'Até: ${_formatarData(_dataFinal)}',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onLimpar();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  child: const Text('Limpar Filtros', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAplicar(_tipoCombustivel, _dataInicial, _dataFinal);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

