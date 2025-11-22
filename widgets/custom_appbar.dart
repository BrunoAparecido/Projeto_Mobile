import 'package:flutter/material.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/dtos/usuario_dto.dart';
import 'package:lotus_mobile/pages/login_page.dart';
import 'package:lotus_mobile/providers/auth_provider.dart';
import 'package:lotus_mobile/widgets/custom_input_field.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class CustomAppbar extends StatefulWidget {
  final UsuarioData? user;
  final List<ProjetoData> projetos;
  final Future<void> Function(ProjetoData?)? onProjetoSelecionado;

  const CustomAppbar({
    super.key,
    required this.user,
    required this.projetos,
    this.onProjetoSelecionado,
  });

  @override
  State<CustomAppbar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppbar> {
  ProjetoData? projetoEscolhido;
  final TextEditingController _projetoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _projetoController.dispose();
    super.dispose();
  }

  void _buscarProjetos(BuildContext context) async {
    final TextEditingController projetoController = TextEditingController();
    bool carregando = false;

    showDialog(
      context: context,
      barrierDismissible: !carregando,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                insetPadding: const EdgeInsets.symmetric(
                  vertical: 210,
                  horizontal: 20,
                ),
                title: const Text("Selecione o Projeto"),
                content: carregando
                    ? SizedBox(
                        height: 80,
                        child: Center(
                          child: Image.asset(
                            'assets/images/loading-screen-spinner.gif',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      )
                    : CustomInputAutocomplete(
                        label: 'Projeto*',
                        controller: projetoController,
                        projetos: widget.projetos,
                        initialValue: projetoEscolhido,
                        onChanged: (valor) async {
                          if (valor != null) {
                            // Mostra spinner
                            setStateDialog(() => carregando = true);
                            setState(() {
                              projetoEscolhido = valor;
                            });

                            try {
                              await widget.onProjetoSelecionado?.call(valor);
                            } finally {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          }
                        },
                      ),
                actions: [
                  if (!carregando)
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: Builder(
      //   builder: (context) {
      //     return IconButton(
      //       icon: const Icon(Icons.menu),
      //       color: Colors.white,
      //       onPressed: () {
      //         Scaffold.of(context).openDrawer();
      //       },
      //     );
      //   },
      // ),
      leading: Image.asset(
        "assets/images/logotipo_lotusplan_branco_p_maior.png",
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            radius: 20,
            child: IconButton(
              onPressed: () => _buscarProjetos(context),
              icon: const Icon(Icons.search),
              color: Color.fromRGBO(53, 53, 53, 1),
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              projetoEscolhido == null
                  ? "SELECIONE UM PROJETO"
                  : "${projetoEscolhido!.codigo} - ${projetoEscolhido!.nomeProjeto}",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Boomer',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: true,
              maxLines: 2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF2C2E35),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton(
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                radius: 20,
                child: Icon(
                  Icons.person,
                  color: const Color.fromRGBO(53, 53, 53, 1),
                  size: 24,
                ),
              ),
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false, // Desabilita o clique no nome do usuário
                    child: Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: Text(
                        "${widget.user?.nome} ${widget.user?.ultimoNome}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(), // Linha separadora

                  PopupMenuItem<String>(
                    value: 'perfil',
                    child: Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: const Text('Perfil'),
                    ),
                  ),
                  const PopupMenuDivider(), // Linha separadora

                  PopupMenuItem<String>(
                    value: 'sair',
                    child: Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: const Text(
                        "Sair",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (value) async {
                if (value == 'perfil') {
                  // Navegar para perfil
                } else if (value == 'sair') {
                  await context.read<AuthProvider>().logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class CustomInputAutocomplete extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<ProjetoData> projetos;
  final void Function(ProjetoData?) onChanged;
  final ProjetoData? initialValue;

  const CustomInputAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.projetos,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<CustomInputAutocomplete> createState() =>
      _CustomInputAutocompleteState();
}

class _CustomInputAutocompleteState extends State<CustomInputAutocomplete> {
  late TextEditingController _controller;
  ProjetoData? _selecionado;
  late FocusNode _focusNode;
  bool estaVazio = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {});
      }
    });

    if (widget.initialValue != null) {
      _selecionado = widget.initialValue;
      _controller.text = widget.initialValue!.nomeProjeto;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomInputAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selecionado = widget.initialValue;
      _controller.text = widget.initialValue?.nomeProjeto ?? '';
      setState(() {
        estaVazio = false;
      });
    }
  }

  Future<List<ProjetoData>> _getSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return widget.projetos;
    }
    return widget.projetos.where((projeto) {
      return projeto.nomeProjeto.toLowerCase().contains(
            pattern.toLowerCase(),
          ) ||
          projeto.codigo.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<ProjetoData>(
          builder: (context, controller, focusNode) {
            _controller = controller;

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 236, 238, 238),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: estaVazio ? Colors.red : Colors.black54,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: estaVazio
                        ? Colors.red
                        : const Color.fromARGB(255, 15, 135, 233),
                  ),
                ),
                labelText: widget.label,
                labelStyle: TextStyle(
                  color: estaVazio ? Colors.red : Colors.black54,
                ),
                suffixIcon: const Icon(Icons.search, color: Color(0xFF2C2E35)),
              ),
              onChanged: (value) {
                if (_selecionado != null && _selecionado!.nomeProjeto != value) {
                  setState(() {
                    estaVazio = value.isEmpty;
                    _selecionado = null;
                    widget.onChanged(null);
                  });
                }
              },
              onTap: () {
                setState(() {
                  estaVazio = _controller.text.isEmpty;
                });
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
              onEditingComplete: () {
                if (_selecionado == null) {
                  _controller.clear();
                  widget.onChanged(null);
                }
              },
            );
          },
          suggestionsCallback: (pattern) async {
            return await _getSuggestions(pattern);
          },
          itemBuilder: (context, ProjetoData suggestion) {
            return ListTile(
              title: Text("${suggestion.codigo} - ${suggestion.nomeProjeto}"),
            );
          },
          onSelected: (ProjetoData suggestion) {
            _controller.text = "${suggestion.codigo} - ${suggestion.nomeProjeto}";

            setState(() {
              _selecionado = suggestion;
            });

            widget.onChanged(_selecionado);
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nenhum projeto encontrado"),
          ),
        )
      ],
    );
  }
}
