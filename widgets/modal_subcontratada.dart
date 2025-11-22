import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SubcontratadaComNome {
  final String uid;
  final String abreviacao;
  final String nomeEmpresa;
  final String contatoPrincipal;
  final String dataHoraInclusao;

  SubcontratadaComNome({
    required this.uid,
    required this.abreviacao,
    required this.nomeEmpresa,
    required this.contatoPrincipal,
    required this.dataHoraInclusao,
  });

  SubcontratadaComNome copyWith({
    String? uid,
    String? abreviacao,
    String? nomeEmpresa,
    String? contatoPrincipal,
    String? dataHoraInclusao,
  }) {
    return SubcontratadaComNome(
      uid: uid ?? this.uid,
      abreviacao: abreviacao ?? this.abreviacao,
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      contatoPrincipal: contatoPrincipal ?? this.contatoPrincipal,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class ModalSubcontratada extends StatefulWidget {
  final DiarioObraConsultarSubcontratadaData? subcontratada;
  final String? uidTemporario;
  final String abreviacao;
  final String nomeEmpresa;
  final String contatoPrincipal;
  final bool apenaVisualizacao;
  final bool modoVinculacao;
  final Function(SubcontratadaComNome)? onSalvar;

  const ModalSubcontratada({
    super.key,
    this.subcontratada,
    this.uidTemporario,
    this.abreviacao = '',
    this.nomeEmpresa = '',
    this.contatoPrincipal = '',
    this.apenaVisualizacao = false,
    this.modoVinculacao = false,
    this.onSalvar,
  });

  @override
  State<ModalSubcontratada> createState() => _ModalSubcontratadaState();
}

class _ModalSubcontratadaState extends State<ModalSubcontratada> {
  late final TextEditingController abreviacaoController;
  late final TextEditingController nomeEmpresaController;
  late final TextEditingController contatoPrincipalController;

  @override
  void initState() {
    super.initState();
    abreviacaoController = TextEditingController(text: widget.abreviacao);
    nomeEmpresaController = TextEditingController(text: widget.nomeEmpresa);
    contatoPrincipalController = TextEditingController(text: widget.contatoPrincipal);
  }

  @override
  void dispose() {
    abreviacaoController.dispose();
    nomeEmpresaController.dispose();
    contatoPrincipalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.modoVinculacao
                      ? 'Subcontratada'
                      : widget.apenaVisualizacao
                          ? 'Visualizar'
                          : 'Editar',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Boomer',
                    color: Color(0xFF2C2E35),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo Abreviação
            TextField(
              controller: abreviacaoController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              decoration: InputDecoration(
                labelText: 'Abreviação',
                labelStyle: TextStyle(
                  color: widget.apenaVisualizacao
                      ? Colors.grey
                      : Colors.black54,
                  fontFamily: 'Boomer',
                ),
                filled: true,
                fillColor: widget.apenaVisualizacao
                    ? Colors.grey.shade200
                    : const Color.fromARGB(255, 236, 238, 238),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 15, 135, 233),
                  ),
                ),
              ),
              onTap: () {
                if (!widget.apenaVisualizacao) {
                  abreviacaoController.selection = TextSelection.fromPosition(
                    TextPosition(offset: abreviacaoController.text.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Campo Nome Empresa
            TextField(
              controller: nomeEmpresaController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              decoration: InputDecoration(
                labelText: 'Nome da Empresa',
                labelStyle: TextStyle(
                  color: widget.apenaVisualizacao
                      ? Colors.grey
                      : Colors.black54,
                  fontFamily: 'Boomer',
                ),
                filled: true,
                fillColor: widget.apenaVisualizacao
                    ? Colors.grey.shade200
                    : const Color.fromARGB(255, 236, 238, 238),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 15, 135, 233),
                  ),
                ),
              ),
              onTap: () {
                if (!widget.apenaVisualizacao) {
                  nomeEmpresaController.selection = TextSelection.fromPosition(
                    TextPosition(offset: nomeEmpresaController.text.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Campo Contato Principal
            TextField(
              controller: contatoPrincipalController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              decoration: InputDecoration(
                labelText: 'Contato Principal',
                labelStyle: TextStyle(
                  color: widget.apenaVisualizacao
                      ? Colors.grey
                      : Colors.black54,
                  fontFamily: 'Boomer',
                ),
                filled: true,
                fillColor: widget.apenaVisualizacao
                    ? Colors.grey.shade200
                    : const Color.fromARGB(255, 236, 238, 238),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 15, 135, 233),
                  ),
                ),
              ),
              onTap: () {
                if (!widget.apenaVisualizacao) {
                  contatoPrincipalController.selection = TextSelection.fromPosition(
                    TextPosition(offset: contatoPrincipalController.text.length),
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão Cancelar
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Boomer',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Botão Salvar
                if (!widget.apenaVisualizacao)
                  ElevatedButton(
                    onPressed: () {
                      if (abreviacaoController.text.trim().isEmpty ||
                          nomeEmpresaController.text.trim().isEmpty ||
                          contatoPrincipalController.text.trim().isEmpty) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Todos os campos são obrigatórios'),
                        //     duration: Duration(seconds: 2),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                        return;
                      }

                      final _uuid = Uuid();

                      final nova = SubcontratadaComNome(
                        uid: widget.uidTemporario ?? 
                            widget.subcontratada?.uid ?? 
                             'temp_${_uuid.v4()}',
                        abreviacao: abreviacaoController.text,
                        nomeEmpresa: nomeEmpresaController.text,
                        contatoPrincipal: contatoPrincipalController.text,
                        dataHoraInclusao: DateTime.now().toIso8601String(),
                      );

                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                      
                      if(widget.onSalvar != null){
                        widget.onSalvar!(nova);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Boomer',
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}