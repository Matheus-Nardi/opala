import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/veiculo.dart';

class VeiculoService {
  final _client = Supabase.instance.client;

  Future<List<Veiculo>> obterVeiculos() async {
    final response = await _client
        .from('veiculos')
        .select()
        .order('id', ascending: true);
    
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
}
