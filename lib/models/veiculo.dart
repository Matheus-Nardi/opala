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

  double get mediaKmLitro {
    if (abastecimentos.length < 2) {
      return 0.0;
    }

    final ultimo = abastecimentos.last;
    final penultimo = abastecimentos[abastecimentos.length - 2];

    final distanciaPercorrida = ultimo.odometro - penultimo.odometro;

    if (distanciaPercorrida <= 0 || ultimo.quantidade <= 0) {
      return 0.0;
    }

    return distanciaPercorrida / ultimo.quantidade;
  }
}
