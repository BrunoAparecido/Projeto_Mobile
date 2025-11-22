import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ModalEquipamento extends StatefulWidget {
  final DiarioObraConsultarEquipamentoData? equipamento;
  final String? uidTemporario;
  final String? nomeEquipamento;
  final bool apenaVisualizacao;
  final String? status;
  final bool modoVinculacao;
  final Function(EquipamentoComNome)? onSalvar;

  const ModalEquipamento({
    super.key,
    this.equipamento,
    this.uidTemporario,
    this.nomeEquipamento,
    this.status,
    this.modoVinculacao = false,
    this.apenaVisualizacao = false,
    this.onSalvar,
  });

  @override
  State<ModalEquipamento> createState() => _ModalEquipamentoState();
}

class _ModalEquipamentoState extends State<ModalEquipamento> {
  late bool _statusAtivo;

  late final TextEditingController nomeController = TextEditingController(
    text: widget.nomeEquipamento ?? '',
  );

  // Armazena os equipamentos completos (com UID)
  List<EquipamentoData> listaEquipamentos = [];
  EquipamentoData? equipamentoSelecionado;

  Future<void> carregarEquipamentos() async {
    final database = context.read<AppDatabase>();
    final equipamentos = await database.select(database.equipamento).get();
    setState(() {
      listaEquipamentos = equipamentos;
      
      // Se já tem um nome selecionado, encontra o equipamento correspondente
      if (widget.nomeEquipamento != null && widget.nomeEquipamento!.isNotEmpty) {
        equipamentoSelecionado = equipamentos.firstWhere(
          (e) => e.nomeEquipamento == widget.nomeEquipamento,
          orElse: () => null as EquipamentoData,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    carregarEquipamentos();

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
                      ? 'Equipamento'
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

            // Campo Nome - Autocomplete
            Autocomplete<EquipamentoData>(
              initialValue: TextEditingValue(text: widget.nomeEquipamento ?? ''),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return listaEquipamentos;
                }
                return listaEquipamentos.where((EquipamentoData option) {
                  return option.nomeEquipamento.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              displayStringForOption: (EquipamentoData option) =>
                  option.nomeEquipamento,
              onSelected: (EquipamentoData selecionado) {
                setState(() {
                  equipamentoSelecionado = selecionado;
                  nomeController.text = selecionado.nomeEquipamento;
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                // Sincroniza com o controller interno
                if (controller.text != nomeController.text) {
                  controller.text = nomeController.text;
                }
                
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !widget.apenaVisualizacao,
                  readOnly: widget.apenaVisualizacao,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    labelText: 'Nome do Equipamento',
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
                    nomeController.text = value;
                    // Se o texto mudou e não corresponde ao selecionado, limpa a seleção
                    if (equipamentoSelecionado != null &&
                        equipamentoSelecionado!.nomeEquipamento != value) {
                      setState(() {
                        equipamentoSelecionado = null;
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
                      if (equipamentoSelecionado == null) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text(
                        //       'Selecione um equipamento válido da lista.',
                        //     ),
                        //     duration: Duration(seconds: 2),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                        return;
                      }

                      final _uuid = Uuid();

                      final atualizado = EquipamentoComNome(
                        // Mantém o UID se já existir (edição), senão gera temp_ se for vinculação nova
                        uid: widget.uidTemporario ??
                            widget.equipamento?.uid ??
                            'temp_${_uuid.v4()}',
                        nomeEquipamento: equipamentoSelecionado!.nomeEquipamento,
                        status: _statusAtivo ? 'Ativo' : 'Inativo',
                        equipamentoUid: equipamentoSelecionado!.uid,
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