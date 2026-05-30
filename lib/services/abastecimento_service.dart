import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/abastecimento.dart';

class AbastecimentoService {
  final _client = Supabase.instance.client;

  Future<List<Abastecimento>> obterAbastecimentosPorVeiculo(
    int veiculoId, {
    String? tipoCombustivel,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
    var query = _client.from('abastecimentos').select().eq('veiculo_id', veiculoId);

    if (tipoCombustivel != null && tipoCombustivel.isNotEmpty) {
      query = query.eq('tipo_combustivel', tipoCombustivel);
    }
    if (dataInicial != null) {
      query = query.gte('data', dataInicial.toIso8601String());
    }
    if (dataFinal != null) {
      final dataFimAjustada = DateTime(dataFinal.year, dataFinal.month, dataFinal.day, 23, 59, 59);
      query = query.lte('data', dataFimAjustada.toIso8601String());
    }

    final response = await query.order('odometro', ascending: true);
    
    return (response as List).map((item) => Abastecimento.fromMap(item)).toList();
  }


  Future<Abastecimento> adicionarAbastecimento(Abastecimento abastecimento) async {
    final response = await _client
        .from('abastecimentos')
        .insert(abastecimento.toMap())
        .select()
        .single();
    
    return Abastecimento.fromMap(response);
  }

  Future<void> deletarAbastecimento(int id) async {
    await _client.from('abastecimentos').delete().eq('id', id);
  }
}
