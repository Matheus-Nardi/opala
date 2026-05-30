import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/veiculo_service.dart';
import '../services/abastecimento_service.dart';
import '../services/pdf_export_service.dart';
import '../services/pdf_delivery_service.dart';

class VeiculoController extends ChangeNotifier {
  final VeiculoService _service = VeiculoService();
  final AbastecimentoService _abastecimentoService = AbastecimentoService();

  List<Veiculo> _veiculos = [];
  bool _carregando = false;
  String _busca = '';

  List<Veiculo> get veiculos => _veiculos;
  bool get carregando => _carregando;
  String get busca => _busca;

  Future<void> carregarVeiculos() async {
    _carregando = true;
    notifyListeners();

    try {
      _veiculos = await _service.obterVeiculos(busca: _busca);
    } catch (e) {
      debugPrint('Erro ao carregar veículos: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void definirBusca(String valor) {
    _busca = valor;
    carregarVeiculos();
  }

  // --- Métodos de Formatação para a View ---

  String obterTotalGastoFormatado(Veiculo veiculo) {
    final total = _service.calcularTotalGasto(veiculo);
    return 'R\$ ${total.toStringAsFixed(2)}';
  }

  String obterMediaFormatada(Veiculo veiculo) {
    final ultimoConsumo = _service.calcularUltimoConsumoSeguro(veiculo);
    if (ultimoConsumo > 0) {
      return ultimoConsumo.toStringAsFixed(1);
    }
    
    final mediaGlobal = _service.calcularMediaGlobal(veiculo);
    if (mediaGlobal > 0) {
      return '${mediaGlobal.toStringAsFixed(1)} (Global)';
    }
    
    return '--';
  }

  int obterCountAbastecimentos(Veiculo veiculo) {
    return veiculo.abastecimentos.length;
  }
  
  bool usarCorDestaqueNaMedia(Veiculo veiculo) {
    return _service.calcularUltimoConsumoSeguro(veiculo) > 0;
  }



  Future<void> adicionarVeiculo(Veiculo veiculo) async {
    try {
      final novoVeiculo = await _service.adicionarVeiculo(veiculo);
      _veiculos.add(novoVeiculo);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar veículo: $e');
      rethrow;
    }
  }

  Future<void> deletarVeiculo(int id) async {
    try {
      await _service.deletarVeiculo(id);
      _veiculos.removeWhere((v) => v.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar veículo: $e');
      rethrow;
    }
  }

  Future<void> exportarPdf() async {
    final pdfBytes = await PdfExportService.gerarRelatorioVeiculos(
      veiculos: _veiculos,
      busca: _busca,
    );

    final fileName = 'Relatorio_Frota_Veiculos_${DateTime.now().millisecondsSinceEpoch}';

    await PdfDeliveryService.entregarPdf(pdfBytes, fileName);
  }
}
