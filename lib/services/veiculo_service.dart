import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/veiculo.dart';

class VeiculoService {
  final _client = Supabase.instance.client;

  Future<List<Veiculo>> obterVeiculos({String? busca}) async {
    var query = _client.from('veiculos').select('*, abastecimentos(*)');
    
    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim();
      query = query.or('apelido.ilike.%$termo%,marca.ilike.%$termo%,modelo.ilike.%$termo%');
    }
    
    final response = await query.order('id', ascending: true);
    
    return (response as List).map((item) => Veiculo.fromMap(item)).toList();
  }

  Future<Veiculo> adicionarVeiculo(Veiculo veiculo) async {
    final response = await _client
        .from('veiculos')
        .insert(veiculo.toMap())
        .select()
        .single();
    
    return Veiculo.fromMap(response);
  }

  Future<void> deletarVeiculo(int id) async {
    await _client.from('veiculos').delete().eq('id', id);
  }

  Future<String> uploadFotoVeiculo(String pathLocal, String nomeArquivo) async {
    final file = File(pathLocal);
    final storagePath = 'fotos/$nomeArquivo';
    
    await _client.storage.from('veiculos_fotos').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('veiculos_fotos').getPublicUrl(storagePath);
  }

  // --- Regras de Negócio transferidas do Model ---

  double calcularTotalGasto(Veiculo veiculo) {
    double total = 0;
    for (var abastecimento in veiculo.abastecimentos) {
      total += abastecimento.valorTotal;
    }
    return total;
  }

  double calcularMediaGlobal(Veiculo veiculo) {
    if (veiculo.abastecimentos.isEmpty || veiculo.abastecimentos.length < 2) return 0.0;
    
    // Garantir ordenação por hodômetro
    final abastecimentos = List.of(veiculo.abastecimentos)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

    final primeiro = abastecimentos.first;
    final ultimo = abastecimentos.last;

    double distanciaTotal = ultimo.odometro - primeiro.odometro;
    
    double quantidadeTotalGasta = 0.0;
    for (int i = 1; i < abastecimentos.length; i++) {
        quantidadeTotalGasta += abastecimentos[i].quantidade;
    }

    if(distanciaTotal <= 0 || quantidadeTotalGasta <= 0) return 0.0;

    return distanciaTotal / quantidadeTotalGasta;
  }

  double calcularUltimoConsumoSeguro(Veiculo veiculo) {
    if (veiculo.abastecimentos.isEmpty || veiculo.abastecimentos.length < 2) return 0.0;

    final abastecimentos = List.of(veiculo.abastecimentos)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

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
}
