class Abastecimento {
  final int id;
  final String posto;
  final String tipoCombustivel;
  final double quantidade;
  final double valorTotal;
  final double odometro;
  final bool tanqueCheio;
  final DateTime data;

  Abastecimento({
    required this.id,
    required this.posto,
    required this.tipoCombustivel,
    required this.quantidade,
    required this.valorTotal,
    required this.odometro,
    required this.data,
    this.tanqueCheio = true,
  });
}