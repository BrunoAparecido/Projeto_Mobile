import 'package:flutter/material.dart';

class SecaoComBotao extends StatelessWidget {
  final String titulo;
  final String textoBotao;
  final VoidCallback onPressed;
  final bool visivel;

  const SecaoComBotao({
    super.key,
    required this.titulo,
    required this.textoBotao,
    required this.onPressed,
    required this.visivel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF2C2E35),
            fontFamily: 'Boomer',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Visibility(
          visible: visivel,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_circle),
            label: Text(
              textoBotao,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Boomer',
              ),
            ),
            iconAlignment: IconAlignment.start,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
