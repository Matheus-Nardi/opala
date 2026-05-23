import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../services/abastecimento_service.dart';
import '../services/pdf_export_service.dart';
import 'package:printing/printing.dart';

class AbastecimentoController extends ChangeNotifier {
  final AbastecimentoService _service = AbastecimentoService();
  final Veiculo veiculo;

  bool _carregando = false;

  String? _filtroTipoCombustivel;
  DateTime? _filtroDataInicial;
  DateTime? _filtroDataFinal;

  List<Abastecimento> _abastecimentosFiltrados = [];

  bool get carregando => _carregando;
  List<Abastecimento> get abastecimentos => veiculo.abastecimentos;
  List<Abastecimento> get abastecimentosFiltrados => _abastecimentosFiltrados;

  String? get filtroTipoCombustivel => _filtroTipoCombustivel;
  DateTime? get filtroDataInicial => _filtroDataInicial;
  DateTime? get filtroDataFinal => _filtroDataFinal;

  bool get temFiltrosAtivos =>
      _filtroTipoCombustivel != null ||
      _filtroDataInicial != null ||
      _filtroDataFinal != null;

  AbastecimentoController(this.veiculo);

  Future<void> carregarAbastecimentos() async {
    if (veiculo.id == null) return;
    _carregando = true;
    notifyListeners();

    try {
      // Sempre carrega a lista completa no veículo para cálculo de estatísticas
      final listCompleta = await _service.obterAbastecimentosPorVeiculo(veiculo.id!);
      veiculo.abastecimentos = listCompleta;

      if (temFiltrosAtivos) {
        // Se houver filtros ativos, carrega os abastecimentos filtrados do Supabase
        _abastecimentosFiltrados = await _service.obterAbastecimentosPorVeiculo(
          veiculo.id!,
          tipoCombustivel: _filtroTipoCombustivel,
          dataInicial: _filtroDataInicial,
          dataFinal: _filtroDataFinal,
        );
      } else {
        _abastecimentosFiltrados = listCompleta;
      }
    } catch (e) {
      debugPrint('Erro ao carregar abastecimentos: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void aplicarFiltros({
    String? tipoCombustivel,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) {
    _filtroTipoCombustivel = tipoCombustivel;
    _filtroDataInicial = dataInicial;
    _filtroDataFinal = dataFinal;
    carregarAbastecimentos();
  }

  void limparFiltros() {
    _filtroTipoCombustivel = null;
    _filtroDataInicial = null;
    _filtroDataFinal = null;
    carregarAbastecimentos();
  }

  void removerFiltroTipo() {
    _filtroTipoCombustivel = null;
    carregarAbastecimentos();
  }

  void removerFiltroPeriodo() {
    _filtroDataInicial = null;
    _filtroDataFinal = null;
    carregarAbastecimentos();
  }

  Future<void> adicionarAbastecimento({
    required String posto,
    required String tipoCombustivel,
    required double quantidade,
    required double valorTotal,
    required double odometro,
    required bool tanqueCheio,
    required DateTime data,
  }) async {
    if (veiculo.id == null) return;
    try {
      final novoAbastecimento = Abastecimento(
        veiculoId: veiculo.id!,
        posto: posto,
        tipoCombustivel: tipoCombustivel,
        quantidade: quantidade,
        valorTotal: valorTotal,
        odometro: odometro,
        tanqueCheio: tanqueCheio,
        data: data,
      );

      final salvo = await _service.adicionarAbastecimento(novoAbastecimento);
      await carregarAbastecimentos();
    } catch (e) {
      debugPrint('Erro ao adicionar abastecimento: $e');
      rethrow;
    }
  }

  Future<void> deletarAbastecimento(int id) async {
    try {
      await _service.deletarAbastecimento(id);
      await carregarAbastecimentos();
    } catch (e) {
      debugPrint('Erro ao deletar abastecimento: $e');
      rethrow;
    }
  }

  Future<void> exportarPdf() async {
    final pdfBytes = await PdfExportService.gerarRelatorioAbastecimentos(
      veiculo: veiculo,
      abastecimentos: _abastecimentosFiltrados,
      filtroTipoCombustivel: _filtroTipoCombustivel,
      filtroDataInicial: _filtroDataInicial,
      filtroDataFinal: _filtroDataFinal,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Relatorio_Abastecimentos_${veiculo.modelo.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
