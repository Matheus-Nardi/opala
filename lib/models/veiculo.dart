import 'package:opala/models/abastecimento.dart';

class Veiculo {
  final int? id;
  final String marca;
  final String modelo;
  final int ano;
  final String placa;
  final String apelido;
  final String? fotoUrl;
  List<Abastecimento> abastecimentos = [];

  Veiculo({
    this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.apelido,
    this.fotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'apelido': apelido,
      'foto_url': fotoUrl,
    };
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    final veiculo = Veiculo(
      id: map['id'],
      marca: map['marca'],
      modelo: map['modelo'],
      ano: map['ano'],
      placa: map['placa'],
      apelido: map['apelido'],
      fotoUrl: map['foto_url'],
    );
    
    if (map['abastecimentos'] != null) {
      veiculo.abastecimentos = (map['abastecimentos'] as List)
          .map((e) => Abastecimento.fromMap(e))
          .toList();
    }
    
    return veiculo;
  }
}
