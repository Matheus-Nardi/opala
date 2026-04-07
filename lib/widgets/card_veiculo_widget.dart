import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CardVeiculoWidget extends StatelessWidget {
  final Veiculo veiculo;
  const CardVeiculoWidget({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: getRandomColor().shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          TextoFormatado(veiculo.modelo, tamanho: 18, peso: FontWeight.bold),
          const SizedBox(height: 8.0),
          TextoFormatado('Marca: ${veiculo.marca}'),
          TextoFormatado('Ano: ${veiculo.ano}'),
          TextoFormatado('Placa: ${veiculo.placa}'),
          TextoFormatado('Apelido: ${veiculo.apelido}'),
          TextoFormatado('Total Gasto: R\$ ${veiculo.totalGasto.toStringAsFixed(2)}'),
          TextoFormatado('Abastecimentos: ${veiculo.countAbastecimentos}'),
        ],
      ),
    );
  }

  MaterialColor getRandomColor() {
    final colors = Colors.primaries;
    return colors[veiculo.id % colors.length];
  }
}