import 'package:flutter/material.dart';

class StatusSwitch extends StatefulWidget {
  final bool apenasVisualizacao;
  final bool aprovadoInicial;
  const StatusSwitch({
    Key? key,
    required this.apenasVisualizacao,
    required this.aprovadoInicial,
  }) : super(key: key);

  @override
  State<StatusSwitch> createState() => _StatusSwitchState();
}

class _StatusSwitchState extends State<StatusSwitch> {
  late bool aprovado;

  @override
  void initState() {
    super.initState();
    aprovado = widget.aprovadoInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: null,
            // widget.apenasVisualizacao
            //   ? null
            //   : () => setState(() => aprovado = !aprovado),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: aprovado
                  ? const Color(0xFFD93370)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(30),
            ),
            width: 60,
            height: 30,
            child: Stack(
              alignment:
                  aprovado ? Alignment.centerRight : Alignment.centerLeft,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: aprovado ? const Color(0xFF6B004B) : Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    aprovado ? Icons.check : Icons.remove,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Aprovado',
          style: TextStyle(
            fontFamily: 'Boomer',
            fontWeight: FontWeight.w600,
            color: aprovado ? Colors.black : Colors.black87,
          ),
        ),
        const SizedBox(width: 15),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Status",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontFamily: 'Boomer',
                ),
              ),
              Text(
                aprovado ? "Aprovado" : "Edição",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C2E35),
                  fontFamily: 'Boomer',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}