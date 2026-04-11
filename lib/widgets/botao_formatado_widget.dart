import '../widgets/texto_formatado_widget.dart';
import 'package:flutter/material.dart';

class BotaoFormatado extends StatelessWidget {
  final IconData icone;
  final String legenda;
  
  //CallBack "chama de volta" a lógica que ficou no pai (na HomePage)
  final VoidCallback? onTap; // para botão ficar clicável - nome onTap escolhido pra remeter a chamada no pai

  const BotaoFormatado({
    super.key,
    required this.icone,
    required this.legenda,
    this.onTap, //define o que o botão fará (opcional)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell( //Torna o widget interativo e cria o efeito visual ao passar o mouse nele
          onTap: onTap, //Aciona a função CallBack recebida do widget pai (TelaHome)
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: Colors.blueGrey, size: 30),
          ),
        ),
        const SizedBox(height: 6),
       
        TextoFormatado(
          legenda,
          tamanho: 14,
          peso: FontWeight.bold,
          cor: Colors.blueGrey,
        ),
      ],
    );
  }
}