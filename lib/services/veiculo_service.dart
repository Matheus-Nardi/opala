import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/veiculo.dart';

class VeiculoService {
  final _client = Supabase.instance.client;

  Future<List<Veiculo>> obterVeiculos({String? busca}) async {
    var query = _client.from('veiculos').select();
    
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
}
