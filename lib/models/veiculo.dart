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

  double get mediaGlobal {
    if (abastecimentos.isEmpty || abastecimentos.length < 2) return 0.0;
    
    final primeiro = abastecimentos.first;
    final ultimo = abastecimentos.last;

    double distanciaTotal = ultimo.odometro - primeiro.odometro;
    
    double quantidadeTotalGasta = 0.0;
    // Começa do índice 1 pois o primeiro abastecimento é a referência inicial
    for (int i = 1; i < abastecimentos.length; i++) {
        quantidadeTotalGasta += abastecimentos[i].quantidade;
    }

    if(distanciaTotal <= 0 || quantidadeTotalGasta <= 0) return 0.0;

    return distanciaTotal / quantidadeTotalGasta;
  }

  double get ultimoConsumoSeguro {
    if (abastecimentos.isEmpty || abastecimentos.length < 2) return 0.0;

    final ultimo = abastecimentos.last;
    
    if(!ultimo.tanqueCheio) {
        return 0.0;
    }

    int indexAnterior = abastecimentos.length - 2;
    double litrosGastosDesdeUltimoTanqueCheio = ultimo.quantidade;

    while(indexAnterior >= 0) {
      final anterior = abastecimentos[indexAnterior];
      
      if (anterior.tanqueCheio) {
          double distanciaPeriodo = ultimo.odometro - anterior.odometro;
          if (distanciaPeriodo <= 0) return 0.0;
          return distanciaPeriodo / litrosGastosDesdeUltimoTanqueCheio;
      } else {
          litrosGastosDesdeUltimoTanqueCheio += anterior.quantidade;
      }
      indexAnterior--;
    }
    
    return 0.0;
  }

  // Mantendo o getter mediaKmLitro para compatibilidade inicial ou padrão
  double get mediaKmLitro {
    double ultimo = ultimoConsumoSeguro;
    if (ultimo > 0) return ultimo;
    return mediaGlobal;
  }
}
