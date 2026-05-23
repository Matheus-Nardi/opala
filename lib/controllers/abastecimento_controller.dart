import 'package:flutter/material.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../services/abastecimento_service.dart';

class AbastecimentoController extends ChangeNotifier {
  final AbastecimentoService _service = AbastecimentoService();
  final Veiculo veiculo;

  bool _carregando = false;

  bool get carregando => _carregando;
  List<Abastecimento> get abastecimentos => veiculo.abastecimentos;

  AbastecimentoController(this.veiculo);

  Future<void> carregarAbastecimentos() async {
    if (veiculo.id == null) return;
    _carregando = true;
    notifyListeners();

    try {
      final list = await _service.obterAbastecimentosPorVeiculo(veiculo.id!);
      veiculo.abastecimentos = list;
    } catch (e) {
      debugPrint('Erro ao carregar abastecimentos: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
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
      veiculo.abastecimentos.add(salvo);
      // Ordena por odômetro após adicionar para que a matemática de consumo permaneça correta
      veiculo.abastecimentos.sort((a, b) => a.odometro.compareTo(b.odometro));
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar abastecimento: $e');
      rethrow;
    }
  }

  Future<void> deletarAbastecimento(int id) async {
    try {
      await _service.deletarAbastecimento(id);
      veiculo.abastecimentos.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar abastecimento: $e');
      rethrow;
    }
  }
}
