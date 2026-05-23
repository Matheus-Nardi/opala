class Abastecimento {
  final int? id;
  final int veiculoId;
  final String posto;
  final String tipoCombustivel;
  final double quantidade;
  final double valorTotal;
  final double odometro;
  final bool tanqueCheio;
  final DateTime data;

  Abastecimento({
    this.id,
    required this.veiculoId,
    required this.posto,
    required this.tipoCombustivel,
    required this.quantidade,
    required this.valorTotal,
    required this.odometro,
    required this.data,
    this.tanqueCheio = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'veiculo_id': veiculoId,
      'posto': posto,
      'tipo_combustivel': tipoCombustivel,
      'quantidade': quantidade,
      'valor_total': valorTotal,
      'odometro': odometro,
      'tanque_cheio': tanqueCheio,
      'data': data.toIso8601String(),
    };
  }

  factory Abastecimento.fromMap(Map<String, dynamic> map) {
    return Abastecimento(
      id: map['id'],
      veiculoId: map['veiculo_id'],
      posto: map['posto'],
      tipoCombustivel: map['tipo_combustivel'],
      quantidade: (map['quantidade'] as num).toDouble(),
      valorTotal: (map['valor_total'] as num).toDouble(),
      odometro: (map['odometro'] as num).toDouble(),
      tanqueCheio: map['tanque_cheio'] ?? true,
      data: DateTime.parse(map['data']),
    );
  }
}