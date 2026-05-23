import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/abastecimento.dart';

class AbastecimentoService {
  final _client = Supabase.instance.client;

  Future<List<Abastecimento>> obterAbastecimentosPorVeiculo(int veiculoId) async {
    final response = await _client
        .from('abastecimentos')
        .select()
        .eq('veiculo_id', veiculoId)
        .order('odometro', ascending: true); // Ordenando por odômetro para cálculo correto de médias
    
    return (response as List).map((item) => Abastecimento.fromMap(item)).toList();
  }

  Future<List<Abastecimento>> obterTodosAbastecimentos() async {
    final response = await _client
        .from('abastecimentos')
        .select()
        .order('odometro', ascending: true);
    
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
