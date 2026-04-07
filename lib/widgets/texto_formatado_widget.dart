import 'package:flutter/material.dart';

class TextoFormatado extends StatelessWidget {
  final String texto;
  final double tamanho;
  final Color cor;
  final Color? corFundo; //? permite ser nulo
  final FontWeight peso;
  final FontStyle estilo;
  final double padding;

  const TextoFormatado(
    this.texto, {
    super.key,
    this.tamanho = 16,
    this.cor = Colors.black,
    this.corFundo, // Se não for passado, será null
    this.peso = FontWeight.normal,
    this.estilo = FontStyle.normal,
    this.padding = 0, // Valor padrão zero para evitar erros de layout
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: tamanho,
          color: cor,
          backgroundColor: corFundo, 
          fontWeight: peso,
          fontStyle: estilo,
        ),
      ),
    );
  }
}