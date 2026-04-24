import 'package:flutter/material.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CardAbastecimentoWidget extends StatelessWidget {
  final Abastecimento abastecimento;
  const CardAbastecimentoWidget({super.key, required this.abastecimento});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.local_gas_station, color: Colors.blueGrey, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextoFormatado(
                          abastecimento.posto,
                          tamanho: 16,
                          peso: FontWeight.bold,
                          cor: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: abastecimento.tanqueCheio ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: abastecimento.tanqueCheio ? Colors.green.shade200 : Colors.orange.shade200,
                          ),
                        ),
                        child: TextoFormatado(
                          abastecimento.tanqueCheio ? 'Cheio' : 'Parcial',
                          tamanho: 10,
                          peso: FontWeight.bold,
                          cor: abastecimento.tanqueCheio ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextoFormatado(
                  '${abastecimento.data.day.toString().padLeft(2, '0')}/${abastecimento.data.month.toString().padLeft(2, '0')}/${abastecimento.data.year}',
                  tamanho: 14,
                  cor: Colors.blueGrey.shade600,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextoFormatado(
                      'Combustível',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      '${abastecimento.quantidade}L ${abastecimento.tipoCombustivel}',
                      tamanho: 14,
                      peso: FontWeight.bold,
                      cor: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextoFormatado(
                      'Odômetro',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      '${abastecimento.odometro} km',
                      tamanho: 14,
                      peso: FontWeight.bold,
                      cor: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextoFormatado(
                      'Valor Total',
                      tamanho: 12,
                      cor: Colors.grey.shade600,
                    ),
                    TextoFormatado(
                      'R\$ ${abastecimento.valorTotal.toStringAsFixed(2)}',
                      tamanho: 14,
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