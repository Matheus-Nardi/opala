import 'package:opala/models/abastecimento.dart';

class Veiculo {
  final int id;
  final String marca;
  final String modelo;
  final int ano;
  final String placa;
  final String apelido;
  List<Abastecimento> abastecimentos = [];

  Veiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.apelido,
  });

  double get totalGasto {
    double total = 0;
    for (Abastecimento abastecimento in abastecimentos) {
      total += abastecimento.valorTotal;
    }
    return total;
  }

  int get countAbastecimentos {
    return abastecimentos.length;
  }
}
