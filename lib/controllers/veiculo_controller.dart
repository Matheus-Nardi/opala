import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/veiculo_service.dart';

import '../services/abastecimento_service.dart';

class VeiculoController extends ChangeNotifier {
  final VeiculoService _service = VeiculoService();
  final AbastecimentoService _abastecimentoService = AbastecimentoService();

  List<Veiculo> _veiculos = [];
  bool _carregando = false;

  List<Veiculo> get veiculos => _veiculos;
  bool get carregando => _carregando;

  Future<void> carregarVeiculos() async {
    _carregando = true;
    notifyListeners();

    try {
      final veiculosList = await _service.obterVeiculos();
      final todosAbastecimentos = await _abastecimentoService.obterTodosAbastecimentos();

      for (var veiculo in veiculosList) {
        veiculo.abastecimentos = todosAbastecimentos
            .where((a) => a.veiculoId == veiculo.id)
            .toList();
      }

      _veiculos = veiculosList;
    } catch (e) {
      debugPrint('Erro ao carregar veículos: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
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
}
