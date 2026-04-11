import 'package:flutter/material.dart';
import 'package:opala/models/veiculo.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CardVeiculoWidget extends StatelessWidget {
  final Veiculo veiculo;
  const CardVeiculoWidget({super.key, required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blueGrey, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextoFormatado(
                        veiculo.apelido.isNotEmpty ? veiculo.apelido : veiculo.modelo,
                        tamanho: 18,
                        peso: FontWeight.bold,
                        cor: Colors.blueGrey.shade800,
                      ),
                      TextoFormatado(
                        '${veiculo.marca} ${veiculo.modelo} (${veiculo.ano})',
                        tamanho: 14,
                        cor: Colors.blueGrey.shade600,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: TextoFormatado(
                    veiculo.placa.toUpperCase(),
                    tamanho: 14,
                    peso: FontWeight.bold,
                    cor: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextoFormatado(
                      'Total Gasto',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      'R\$ ${veiculo.totalGasto.toStringAsFixed(2)}',
                      tamanho: 16,
                      peso: FontWeight.bold,
                      cor: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextoFormatado(
                      'Média (km/L)',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      veiculo.mediaKmLitro > 0 ? veiculo.mediaKmLitro.toStringAsFixed(1) : '--',
                      tamanho: 16,
                      peso: FontWeight.bold,
                      cor: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextoFormatado(
                      'Abastecimentos',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      '${veiculo.countAbastecimentos}',
                      tamanho: 16,
                      peso: FontWeight.bold,
                      cor: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}