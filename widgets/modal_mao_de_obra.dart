import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ModalMaoDeObra extends StatefulWidget {
  final DiarioObraConsultarMaoDeObraData? maoDeObra;
  final String? uidTemporario;
  final String? descricao;
  final bool apenaVisualizacao;
  final String? status;
  final bool modoVinculacao;
  final int? statusTipoMaoDeObraEnum;
  final Function(MaoDeObraComNome)? onSalvar;

  const ModalMaoDeObra({
    super.key,
    this.uidTemporario,
    this.maoDeObra,
    this.descricao,
    this.status,
    this.apenaVisualizacao = false,
    this.modoVinculacao = false,
    this.onSalvar,
    this.statusTipoMaoDeObraEnum,
  });

  @override
  State<ModalMaoDeObra> createState() => _ModalMaoDeObraState();
}

class _ModalMaoDeObraState extends State<ModalMaoDeObra> {
  late bool _statusAtivo;

  late final TextEditingController descricaoController = TextEditingController(
    text: widget.descricao ?? '',
  );

  // Armazena mão de obra completa (com UID e statusTipoMaoDeObraEnum)
  List<MaoDeObraData> listaMaoDeObra = [];
  MaoDeObraData? maoDeObraSelecionada;

  Future<void> carregarListaMaoDeObra() async {
    final database = context.read<AppDatabase>();
    final maoDeObra = await database.select(database.maoDeObra).get();
    setState(() {
      listaMaoDeObra = maoDeObra;
      
      // Se já tem uma descrição selecionada, encontra a mão de obra correspondente
      if (widget.descricao != null && widget.descricao!.isNotEmpty) {
        maoDeObraSelecionada = maoDeObra.firstWhere(
          (m) => m.descricao == widget.descricao,
          orElse: () => null as MaoDeObraData,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    carregarListaMaoDeObra();

    _statusAtivo = (widget.status ?? 'Ativo').toLowerCase() == 'ativo';
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
                      ? 'Mão de Obra'
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

            // Campo Descrição - Autocomplete
            Autocomplete<MaoDeObraData>(
              initialValue: TextEditingValue(text: widget.descricao ?? ''),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return listaMaoDeObra;
                }
                return listaMaoDeObra.where((MaoDeObraData option) {
                  return option.descricao.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              displayStringForOption: (MaoDeObraData option) => option.descricao,
              onSelected: (MaoDeObraData selecionada) {
                setState(() {
                  maoDeObraSelecionada = selecionada;
                  descricaoController.text = selecionada.descricao;
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                // Sincroniza com o controller interno
                if (controller.text != descricaoController.text) {
                  controller.text = descricaoController.text;
                }
                
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !widget.apenaVisualizacao,
                  readOnly: widget.apenaVisualizacao,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
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
                  onChanged: (value) {
                    descricaoController.text = value;
                    // Se o texto mudou e não corresponde ao selecionado, limpa a seleção
                    if (maoDeObraSelecionada != null &&
                        maoDeObraSelecionada!.descricao != value) {
                      setState(() {
                        maoDeObraSelecionada = null;
                      });
                    }
                  },
                  onTap: () {
                    if (!widget.apenaVisualizacao) {
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // Campo Status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(
                      text: _statusAtivo ? 'Ativo' : 'Inativo',
                    ),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final opcoes = ['Ativo', 'Inativo'];

                      if (textEditingValue.text.isEmpty) {
                        return opcoes;
                      }

                      return opcoes.where(
                        (opcao) => opcao.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (String valorSelecionado) {
                      setState(() {
                        _statusAtivo = valorSelecionado.toLowerCase() == 'ativo';
                      });
                    },
                    fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController textController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      textController.text = _statusAtivo ? 'Ativo' : 'Inativo';

                      return TextField(
                        controller: textController,
                        focusNode: focusNode,
                        enabled: !widget.apenaVisualizacao,
                        readOnly: widget.apenaVisualizacao,
                        onTap: () {
                          if (!widget.apenaVisualizacao) {
                            textController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                offset: textController.text.length,
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
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
                        style: TextStyle(
                          fontFamily: 'Boomer',
                          color: widget.apenaVisualizacao
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(8),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(fontFamily: 'Boomer'),
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
                      if (maoDeObraSelecionada == null) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text(
                        //       'Selecione uma mão de obra válida da lista.',
                        //     ),
                        //     duration: Duration(seconds: 2),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                        return;
                      }

                      final _uuid = Uuid();

                      final atualizado = MaoDeObraComNome(
                        uid: widget.uidTemporario ?? 
                            widget.maoDeObra?.uid ??
                            'temp_${_uuid.v4()}',
                        descricao: maoDeObraSelecionada!.descricao,
                        status: _statusAtivo ? 'Ativo' : 'Inativo',
                        statusTipoMaoDeObraEnum:
                            maoDeObraSelecionada!.statusTipoMaoDeObraEnum,
                        maoDeObraUid: maoDeObraSelecionada!.uid,
                        dataHoraInclusao: DateTime.now().toIso8601String(),
                      );

                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();

                      if(widget.onSalvar != null){
                        widget.onSalvar!(atualizado);
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