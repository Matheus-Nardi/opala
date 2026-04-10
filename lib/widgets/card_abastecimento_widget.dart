import 'package:flutter/material.dart';
import 'package:opala/models/abastecimento.dart';
import 'package:opala/widgets/texto_formatado_widget.dart';

class CardAbastecimentoWidget extends StatelessWidget {
  final Abastecimento abastecimento;
  const CardAbastecimentoWidget({super.key, required this.abastecimento});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          TextoFormatado('Posto: ${abastecimento.posto}'),
          TextoFormatado('Tipo Combustível: ${abastecimento.tipoCombustivel}'),
          TextoFormatado('Quantidade: ${abastecimento.quantidade} L'),
          TextoFormatado('Valor Total: R\$ ${abastecimento.valorTotal.toStringAsFixed(2)}'),
          TextoFormatado('Odômetro: ${abastecimento.odometro} km'),
          TextoFormatado('Data: ${abastecimento.data.day}/${abastecimento.data.month}/${abastecimento.data.year}'),
        ],
      ),
    );
  }
}