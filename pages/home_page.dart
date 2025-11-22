import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lotus_mobile/database/daos/equipamento_dao.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/database/tables/obra_contratados_table.dart';
import 'package:lotus_mobile/database/tables/obra_table.dart';
import 'package:lotus_mobile/database/tables/projeto_empresa_table.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anexo_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_contratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_gerenciadora_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_apontamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_equipamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_subcontratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_evolucao_servicos_dto.dart';
import 'package:lotus_mobile/dtos/equipamento_dto.dart';
import 'package:lotus_mobile/dtos/mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/obra_contratados_dto.dart';
import 'package:lotus_mobile/dtos/obra_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:lotus_mobile/dtos/projeto_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';
import 'package:lotus_mobile/dtos/projeto_participante_dto.dart';
import 'package:lotus_mobile/pages/login_page.dart';
import 'package:lotus_mobile/providers/auth_provider.dart';
import 'package:lotus_mobile/services/background_service.dart';
import 'package:lotus_mobile/services/contato_service.dart';
import 'package:lotus_mobile/services/diario_obra_consultar_service.dart';
import 'package:lotus_mobile/services/equipamento_service.dart';
import 'package:lotus_mobile/services/image_service.dart';
import 'package:lotus_mobile/services/mao_de_obra_service.dart';
import 'package:lotus_mobile/services/obra_service.dart';
import 'package:lotus_mobile/services/projeto_empresa_service.dart';
import 'package:lotus_mobile/services/projeto_service.dart';
import 'package:lotus_mobile/services/storage_service.dart';
import 'package:lotus_mobile/services/usuario_service.dart';
import 'package:lotus_mobile/widgets/bottom_action_bar.dart';
import 'package:lotus_mobile/widgets/custom_appbar.dart';
import 'package:lotus_mobile/widgets/modal_diario_obra.dart';
import 'package:lotus_mobile/widgets/modal_mao_de_obra.dart';
import 'package:provider/provider.dart';
import 'package:lotus_mobile/widgets/secao_com_botao.dart';
import 'package:lotus_mobile/main.dart';
import 'package:lotus_mobile/widgets/modal_equipamento.dart';
import 'package:lotus_mobile/widgets/modal_subcontratada.dart';
import 'package:lotus_mobile/widgets/modal_diario_obra.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:lotus_mobile/services/pdf_service.dart';
import 'package:lotus_mobile/widgets/modal_pdf_viewer.dart';

class EquipamentoComNome {
  final String uid;
  final String nomeEquipamento;
  final String status;
  final String equipamentoUid;
  final String dataHoraInclusao;

  EquipamentoComNome({
    required this.uid,
    required this.nomeEquipamento,
    required this.status,
    required this.equipamentoUid,
    required this.dataHoraInclusao,
  });

  EquipamentoComNome copyWith({
    String? uid,
    String? nomeEquipamento,
    String? status,
    String? equipamentoUid,
    String? dataHoraInclusao,
  }) {
    return EquipamentoComNome(
      uid: uid ?? this.uid,
      nomeEquipamento: nomeEquipamento ?? this.nomeEquipamento,
      status: status ?? this.status,
      equipamentoUid: equipamentoUid ?? this.equipamentoUid,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class MaoDeObraComNome {
  final String uid;
  final String descricao;
  final String status;
  final int statusTipoMaoDeObraEnum;
  final String maoDeObraUid;
  final String dataHoraInclusao;

  MaoDeObraComNome({
    required this.uid,
    required this.descricao,
    required this.status,
    required this.statusTipoMaoDeObraEnum,
    required this.maoDeObraUid,
    required this.dataHoraInclusao,
  });

  MaoDeObraComNome copyWith({
    String? uid,
    String? descricao,
    String? status,
    int? statusTipoMaoDeObraEnum,
    String? maoDeObraUid,
    String? dataHoraInclusao,
  }) {
    return MaoDeObraComNome(
      uid: uid ?? this.uid,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      statusTipoMaoDeObraEnum:
          statusTipoMaoDeObraEnum ?? this.statusTipoMaoDeObraEnum,
      maoDeObraUid: maoDeObraUid ?? this.maoDeObraUid,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class HomePage extends StatefulWidget {
  UsuarioData user;

  HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? textoToken;
  bool _loading = true;
  UsuarioData? _user;
  ObraData? obraEscolhida;
  List<ProjetoData> _projetos = [];
  List<ProjetoEmpresaData> _projetoEmpresas = [];
  List<ObraData> _obras = [];
  List<ObraContratado> _contratados = [];
  List<DiarioObraConsultarData> _listaDiarioObraConsultar = [];
  List<DiarioObraConsultarSubcontratadaData>
  _listaDiarioObraConsultarSubcontratada = [];
  List<EquipamentoComNome> _listaDiarioObraConsultarEquipamento = [];
  List<MaoDeObraComNome> _listaDiarioObraConsultarMaoDeObra = [];
  TextEditingController obraController = TextEditingController();
  TextEditingController contratadoController = TextEditingController();
  ObraContratado? contratadoEscolhido;
  String? nomeContratadoEscolhido;
  bool _carregandoDiarioObra = false;
  late String dataInicioFormatada;
  late String dataTerminoFormatada;
  String? dataTerminoRealizadoFormatada;
  List<EquipamentoComNome> _equipamentosTemporarios = [];
  List<MaoDeObraComNome> _listaMaoDeObraTemporaria = [];
  List<SubcontratadaComNome> _listaSubcontratadaTemporaria = [];
  List<String> _subcontratadaRemovidasUids = [];
  List<DiarioObraComDados> _listaDiarioObra = [];
  List<DiarioObraData> _listaDiarioObraData = [];
  List<DiarioObraComDados> _listaDiarioObraTemporaria = [];
  bool _sincronizacaoPendente = false;
  StreamSubscription<SyncEvent>? _syncSubscription;
  ProjetoData? projetoEscolhido;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _setupSyncListener();
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  void _setupSyncListener() {
    final backgroundSync = BackgroundSyncService();

    _syncSubscription?.cancel();

    _syncSubscription = backgroundSync.syncStatusStream.listen((event) async {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        switch (event.status) {
          case SyncStatus.success:
            // Atualiza o status no banco
            if (event.diarioConsultarUid != null) {
              final database = context.read<AppDatabase>();
              final diarios =
                  await (database.select(database.diarioObra)..where(
                        (tbl) => tbl.diarioObraConsultarUid.equals(
                          event.diarioConsultarUid!,
                        ),
                      ))
                      .get();

              for (var diario in diarios) {
                await _atualizarStatusSincronizacao(diario.uid, 'sincronizado');
              }

              // Recarrega os dados
              if (contratadoEscolhido != null) {
                await _recarregarDadosContratado(contratadoEscolhido!);
              }
            }

            final snack = SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.message ?? 'Sincronização concluída com sucesso!',
                      style: TextStyle(fontFamily: 'Boomer'),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            );
            _showSnackBarWithRetry(snack);
            break;

          case SyncStatus.error:
            // Atualiza o status de erro no banco
            if (event.diarioConsultarUid != null) {
              final database = context.read<AppDatabase>();
              final diarios =
                  await (database.select(database.diarioObra)..where(
                        (tbl) => tbl.diarioObraConsultarUid.equals(
                          event.diarioConsultarUid!,
                        ),
                      ))
                      .get();

              for (var diario in diarios) {
                await _atualizarStatusSincronizacao(
                  diario.uid,
                  'erro',
                  mensagemErro: event.message,
                );
              }

              // Recarrega os dados
              if (contratadoEscolhido != null) {
                await _recarregarDadosContratado(contratadoEscolhido!);
              }
            }

            final snack = SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.message ?? 'Erro na sincronização',
                      style: TextStyle(fontFamily: 'Boomer'),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            );
            _showSnackBarWithRetry(snack);
            break;

          default:
            break;
        }
      });
    });
  }

  void _showSnackBarWithRetry(SnackBar snack) async {
    var messenger = rootScaffoldMessengerKey.currentState;

    int retryCount = 0;

    while (messenger == null && retryCount < 6) {
      await Future.delayed(const Duration(milliseconds: 10));
      messenger = rootScaffoldMessengerKey.currentState;
      retryCount++;
    }

    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: snack.content,
          backgroundColor: snack.backgroundColor,
          duration: snack.duration,
          behavior: snack.behavior,
        ),
      );
    }
  }

  Future<void> _onProjetoSelecionado(ProjetoData? projeto) async {
    if (projeto == null) return;

    final database = context.read<AppDatabase>();

    // Busca todas as obras do banco local que pertencem a este projeto
    final obras = await (database.select(
      database.obra,
    )..where((tbl) => tbl.projetoUid.equals(projeto.uid))).get();

    // Busca todos os contratados das obras filtradas
    final obraUids = obras.map((o) => o.uid).toList();

    final contratados = await (database.select(
      database.obraContratados,
    )..where((tbl) => tbl.obraUid.isIn(obraUids))).get();

    setState(() {
      projetoEscolhido = projeto;
      _obras = obras;
      _contratados = contratados;
      obraEscolhida = null;
      obraController.clear();
      contratadoEscolhido = null;
      contratadoController.clear();
      nomeContratadoEscolhido = null;
    });
  }

  Future<void> _gerarVisualizarPdf(DiarioObraComDados diario) async {
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/loading-screen-spinner.gif',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Verificando conexão...',
                style: TextStyle(fontFamily: 'Boomer', fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Verifica conexão com internet
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (!mounted) return;

      // Remove o loading de verificação
      Navigator.of(context).pop();

      if (!hasInternet) {
        _showSnackBarWithRetry(
          SnackBar(
            content: Text(
              'Sem conexão com a internet. Conecte-se para gerar o PDF.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      // Mostra loading de geração do PDF
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/loading-screen-spinner.gif',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gerando PDF...',
                  style: TextStyle(fontFamily: 'Boomer', fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );

      // Chama o serviço para gerar o PDF
      final pdfService = context.read<PdfService>();
      final pdfBytes = await pdfService.gerarPdfDiarioObra(diario.uid);

      if (!mounted) return;

      // Remove o loading de geração
      Navigator.of(context).pop();

      // Cria o nome do arquivo
      final nomeArquivo =
          obraEscolhida != null && nomeContratadoEscolhido != null
          ? '${obraEscolhida!.nomeObra}-$nomeContratadoEscolhido-Diario-${diario.numero}'
          : 'Diario-Obra-${diario.numero}';

      // Abre o modal com o PDF
      showDialog(
        context: context,
        builder: (context) =>
            ModalPdfViewer(pdfBytes: pdfBytes, nomeArquivo: nomeArquivo),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _atualizarStatusSincronizacao(
    String diarioUid,
    String status, {
    String? mensagemErro,
  }) async {
    final database = context.read<AppDatabase>();

    await database.customUpdate(
      'UPDATE diario_obra SET status_sincronizacao = ?, erro_sincronizacao = ? WHERE uid = ?',
      variables: [
        Variable.withString(status),
        Variable.withString(mensagemErro ?? ''),
        Variable.withString(diarioUid),
      ],
    );
  }

  Future<void> _enviarDadosParaBackend() async {
    if (contratadoEscolhido == null) {
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Selecione uma obra e contratado primeiro'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final database = context.read<AppDatabase>();

      final diarioConsultar =
          await (database.select(database.diarioObraConsultar)..where(
                (tbl) => tbl.obraContratadoUid.equals(contratadoEscolhido!.uid),
              ))
              .getSingleOrNull();

      if (diarioConsultar == null) {
        if (!mounted) return;
        _showSnackBarWithRetry(
          SnackBar(
            content: Text('Diario consultar não encontrado'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Agenda a sincronização em background
      final backgroundSync = BackgroundSyncService();
      await backgroundSync.scheduleSyncTask(diarioConsultar.uid);

      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text(
            'Sincronização iniciada! Você será notificado quando concluir.',
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.blue,
        ),
      );

      // Limpa as listas temporárias
      _resetarListasTemporarias();
    } catch (e) {
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Erro: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _carregarDados() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final projetoService = context.read<ProjetoService>();
      final projetoEmpresaService = context.read<ProjetoEmpresaService>();
      final equipamentoService = context.read<EquipamentoService>();
      final maoDeObraService = context.read<MaoDeObraService>();
      final database = context.read<AppDatabase>();
      final obraService = context.read<ObraService>();
      final diarioObraConsultarService = context
          .read<DiarioObraConsultarService>();
      final contatoService = context.read<ContatoService>();
      final imageService = context.read<ImageService>();

      final user = authProvider.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      setState(() {
        _user = user;
      });

      final parametros = [
        ParametroGetDto(
          atributoPesquisa: "nome",
          comparador: 6,
          valorPesquisa: "",
        ),
        ParametroGetDto(
          atributoPesquisa: "statusProjetoEnum",
          comparador: 0,
          valorPesquisa: "1",
        ),
      ];
      final parametrosContato = [
        ParametroGetDto(atributoPesquisa: "", comparador: 6, valorPesquisa: ""),
      ];
      final parametrosEquipamento = [
        ParametroGetDto(
          atributoPesquisa: "nomeEquipamento",
          comparador: 6,
          valorPesquisa: "",
        ),
      ];
      final parametrosMaoDeObra = [
        ParametroGetDto(
          atributoPesquisa: "descricao",
          comparador: 6,
          valorPesquisa: "",
        ),
      ];
      final parametrosObra = [
        ParametroGetDto(
          atributoPesquisa: "NomeObra",
          comparador: 6,
          valorPesquisa: "",
        ),
      ];
      final parametrosProjetoEmpresa = [
        ParametroGetDto(atributoPesquisa: "", comparador: 6, valorPesquisa: ""),
      ];

      final results = await Future.wait([
        projetoService.buscarPorUsuario(parametros, user.uid),
        contatoService.buscarTodos(parametrosContato),
        contatoService.buscarGrupoLotus(parametrosContato),
        equipamentoService.buscarEquipamento(parametrosEquipamento),
        maoDeObraService.buscarMaoDeObra(parametrosMaoDeObra),
        projetoEmpresaService.buscarProjetoEmpresa(parametrosProjetoEmpresa),
        obraService.buscarObra(parametrosObra),
      ]);

      final projetos = results[0] as List<ProjetoDto>;
      final contatos = results[1] as List<Contato>;
      final listaContatosGrupoLotus = results[2] as List<Contato>;
      final equipamentos = results[3] as List<EquipamentoDto>;
      final listaMaoDeObra = results[4] as List<MaoDeObraDto>;
      final listaProjetoEmpresa = results[5] as List<ProjetoEmpresaDto>;
      final obras = results[6] as List<ObraDto>;
      final listaDiarioObraConsultar = [];
      final List<String> guidsParaDownload = [];

      for (int i = 0; i < projetos.length; i += 3) {
        final chunk = projetos.skip(i).take(3).toList();

        for (final projeto in chunk) {
          try {
            final parametrosDiarioObra = [
              ParametroGetDto(
                atributoPesquisa: "projetoUid",
                comparador: 0,
                valorPesquisa: projeto.uid,
              ),
            ];

            final resultado = await diarioObraConsultarService
                .buscarDiarioPorProjetoUid(parametrosDiarioObra);

            listaDiarioObraConsultar.addAll(resultado);
          } catch (e) {
            print('Erro ao buscar diário do projeto ${projeto.uid}: $e');
          }
        }
      }

      print('Total de diários carregados: ${listaDiarioObraConsultar.length}');

      await database.transaction(() async {
        final List<ProjetoData> projetosDataList = [];
        for (ProjetoDto projeto in projetos) {
          final projetoExistente = await database.projetoDao.getByUid(
            projeto.uid,
          );
          if (projetoExistente == null) {
            await database.projetoDao.inserirProjeto(
              uid: projeto.uid,
              codigo: projeto.codigo,
              nomeProjeto: projeto.nome,
            );
          } else {
            await database.projetoDao.atualizarProjeto(
              uid: projeto.uid,
              codigo: projeto.codigo,
              nomeProjeto: projeto.nome,
            );
          }

          final projetoParticipantes = projeto.projetoParticipante;

          if (projetoParticipantes != null) {
            for (ProjetoParticipanteDto participante in projetoParticipantes) {
              final projetoParticipanteExistente = await database
                  .projetoParticipanteDao
                  .getByUid(participante.uid);

              if (projetoParticipanteExistente == null) {
                await database.projetoParticipanteDao
                    .inserirProjetoParticipante(
                      uid: participante.uid,
                      projetoUid: participante.projetoUid,
                      contatoUid: participante.contato!.uid,
                    );
              } else {
                await database.projetoParticipanteDao
                    .atualizarProjetoParticipante(
                      uid: participante.uid,
                      projetoUid: participante.projetoUid,
                      contatoUid: participante.contato!.uid,
                    );
              }
            }
          }

          final projetoData = ProjetoData(
            uid: projeto.uid,
            codigo: projeto.codigo,
            nomeProjeto: projeto.nome,
          );

          projetosDataList.add(projetoData);
        }

        for (Contato contato in contatos) {
          final contatoExistente = await database.contatoDao.getByUid(
            contato.uid,
          );

          bool grupoLotus = listaContatosGrupoLotus.any(
            (contatoGrupoLotus) => contatoGrupoLotus.uid == contato.uid,
          );

          if (contatoExistente == null) {
            await database.contatoDao.inserirContato(
              uid: contato.uid,
              pronomeEnum: contato.pronomeEnum,
              nome: contato.nome,
              ultimoNome: contato.ultimoNome,
              grupoLotus: grupoLotus,
            );
          } else {
            await database.contatoDao.atualizarContato(
              uid: contato.uid,
              pronomeEnum: contato.pronomeEnum,
              nome: contato.nome,
              ultimoNome: contato.ultimoNome,
              grupoLotus: grupoLotus,
            );
          }
        }

        final List<ProjetoEmpresaData> projetoEmpresaDataList = [];
        for (ProjetoEmpresaDto empresa in listaProjetoEmpresa) {
          final projetoEmpresaExistente = await database.projetoEmpresaDao
              .getByUid(empresa.uid);

          if (projetoEmpresaExistente == null) {
            await database.projetoEmpresaDao.inserirProjetoEmpresa(
              uid: empresa.uid,
              nomeFantasia: empresa.nomeFantasia,
              abreviacao: empresa.abreviacao,
            );
          } else {
            await database.projetoEmpresaDao.atualizarProjetoEmpresa(
              uid: empresa.uid,
              nomeFantasia: empresa.nomeFantasia,
              abreviacao: empresa.abreviacao,
            );
          }

          final projetoEmpresaData = ProjetoEmpresaData(
            uid: empresa.uid,
            nomeFantasia: empresa.nomeFantasia,
            abreviacao: empresa.abreviacao,
          );

          projetoEmpresaDataList.add(projetoEmpresaData);
        }

        for (EquipamentoDto equipamento in equipamentos) {
          final equipamentoExistente = await database.equipamentoDao.getByUid(
            equipamento.uid,
          );

          if (equipamentoExistente == null) {
            await database.equipamentoDao.inserirEquipamento(
              uid: equipamento.uid,
              nomeEquipamento: equipamento.nomeEquipamento,
            );
          } else {
            await database.equipamentoDao.atualizarEquipamento(
              uid: equipamento.uid,
              nomeEquipamento: equipamento.nomeEquipamento,
            );
          }
        }

        for (MaoDeObraDto maoDeObra in listaMaoDeObra) {
          final maoDeObraExistente = await database.maoDeObraDao.getByUid(
            maoDeObra.uid,
          );
          if (maoDeObraExistente == null) {
            await database.maoDeObraDao.inserirMaoDeObra(
              uid: maoDeObra.uid,
              descricao: maoDeObra.descricao,
              statusTipoMaoDeObraEnum: maoDeObra.statusTipoMaoDeObraEnum,
            );
          } else {
            await database.maoDeObraDao.atualizarMaoDeObra(
              uid: maoDeObra.uid,
              descricao: maoDeObra.descricao,
              statusTipoMaoDeObraEnum: maoDeObra.statusTipoMaoDeObraEnum,
            );
          }
        }

        final obras = await obraService.buscarObra(parametrosObra);

        for (ObraDto obra in obras) {
          final obraExistente = await database.obraDao.getByUid(obra.uid);

          if (obraExistente == null) {
            await database.obraDao.inserirObra(
              uid: obra.uid,
              nomeObra: obra.nomeObra,
              projetoUid: obra.projetoUid,
              contatoResponsavelUid: obra.contatoResponsavel!.uid,
            );
          } else {
            await database.obraDao.atualizarObra(
              uid: obra.uid,
              nomeObra: obra.nomeObra,
              projetoUid: obra.projetoUid,
              contatoResponsavelUid: obra.contatoResponsavel!.uid,
            );
          }

          final obraContratados = obra.obraContratados;
          if (obraContratados != null) {
            for (ObraContratadosDto contratadoDto in obraContratados) {
              final contratadoExistente = await database.obraContratadosDao
                  .getByUid(contratadoDto.uid);

              final dataTerminoRealizado =
                  contratadoDto.dataTerminoRealizado != null
                  ? DateTime.parse(contratadoDto.dataTerminoRealizado!)
                  : null;

              if (contratadoExistente == null) {
                await database.obraContratadosDao.inserirObraContratados(
                  uid: contratadoDto.uid,
                  projetoEmpresaUid: contratadoDto.projetoEmpresa!.uid,
                  obraUid: obra.uid,
                  escopo: contratadoDto.escopo,
                  dataInicio: DateTime.parse(contratadoDto.dataInicio),
                  prazo: contratadoDto.prazo,
                  aditivos: contratadoDto.aditivos,
                  dataTermino: DateTime.parse(contratadoDto.dataTermino),
                  dataTerminoRealizado: dataTerminoRealizado,
                );
              } else {
                await database.obraContratadosDao.atualizarObraContratados(
                  uid: contratadoDto.uid,
                  projetoEmpresaUid: contratadoDto.projetoEmpresa!.uid,
                  obraUid: obra.uid,
                  escopo: contratadoDto.escopo,
                  dataInicio: DateTime.parse(contratadoDto.dataInicio),
                  prazo: contratadoDto.prazo,
                  aditivos: contratadoDto.aditivos,
                  dataTermino: DateTime.parse(contratadoDto.dataTermino),
                  dataTerminoRealizado: dataTerminoRealizado,
                );
              }
            }
          }
        }

        final List<DiarioObraConsultarData> diarioObraConsultarDataList = [];
        final List<DiarioObraConsultarSubcontratadaData>
        diarioObraConsultarSubcontratadaDataList = [];
        final List<DiarioObraConsultarEquipamentoData>
        diarioObraConsultarEquipamentoDataList = [];
        final List<DiarioObraConsultarMaoDeObraData>
        diarioObraConsultarMaoDeObraDataList = [];

        for (DiarioObraConsultarDto diarioObraConsultar
            in listaDiarioObraConsultar) {
          final diarioObraConsultarExistente = await database
              .diarioObraConsultarDao
              .getByUid(diarioObraConsultar.uid);

          if (diarioObraConsultarExistente == null) {
            await database.diarioObraConsultarDao.inserirDiarioObraConsultar(
              uid: diarioObraConsultar.uid,
              obraUid: diarioObraConsultar.obra!.uid,
              obraContratadoUid: diarioObraConsultar.obraContratados!.uid,
              projetoUid: diarioObraConsultar.projeto!.uid,
            );
          } else {
            await database.diarioObraConsultarDao.atualizarDiarioObraConsultar(
              uid: diarioObraConsultar.uid,
              obraUid: diarioObraConsultar.obra!.uid,
              obraContratadoUid: diarioObraConsultar.obraContratados!.uid,
              projetoUid: diarioObraConsultar.projeto!.uid,
            );
          }

          final List<DiarioObraDto>? listaDiarioObra =
              diarioObraConsultar.diarioObra;
          if (listaDiarioObra != null) {
            for (DiarioObraDto diario in listaDiarioObra) {
              final diarioExistente = await database.diarioObraDao.getByUid(
                diario.uid,
              );

              if (diarioExistente == null) {
                await database.diarioObraDao.inserirDiarioObra(
                  uid: diario.uid,
                  diarioObraConsultarUid: diarioObraConsultar.uid,
                  usuarioResponsavelUid: diario.usuarioResponsavelUid,
                  numero: diario.numero,
                  data: DateTime.parse(diario.data),
                  sequencial: diario.sequencial,
                  obraContratadosUid: diario.obraContratadosUid,
                  periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
                  periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
                  periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
                  observacoesPeriodoTrabalhado:
                      diario.observacoesPeriodoTrabalhado,
                  condicoesMeteorologicasManhaEnum:
                      diario.condicoesMeteorologicasManhaEnum,
                  condicoesMeteorologicasTardeEnum:
                      diario.condicoesMeteorologicasTardeEnum,
                  condicoesMeteorologicasNoiteEnum:
                      diario.condicoesMeteorologicasNoiteEnum,
                  observacoesCondicoesMeteorologicas:
                      diario.observacoesCondicoesMeteorologicas,
                  aprovadoContratada: diario.aprovadoContratada ?? false,
                  assinadoContratada: diario.assinadoContratada ?? false,
                  assinadoContratante: diario.assinadoContratante ?? false,
                  dataHoraInclusao: diario.dataHoraInclusao,
                  statusObraEnum: diario.statusObraEnum,
                  statusSincronizacao: 'sincronizado',
                  erroSincronizacao: '',
                );
              } else {
                await database.diarioObraDao.atualizarDiarioObra(
                  uid: diario.uid,
                  diarioObraConsultarUid: diarioObraConsultar.uid,
                  usuarioResponsavelUid: diario.usuarioResponsavelUid,
                  numero: diario.numero,
                  data: DateTime.parse(diario.data),
                  sequencial: diario.sequencial,
                  obraContratadosUid: diario.obraContratadosUid,
                  periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
                  periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
                  periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
                  observacoesPeriodoTrabalhado:
                      diario.observacoesPeriodoTrabalhado,
                  condicoesMeteorologicasManhaEnum:
                      diario.condicoesMeteorologicasManhaEnum,
                  condicoesMeteorologicasTardeEnum:
                      diario.condicoesMeteorologicasTardeEnum,
                  condicoesMeteorologicasNoiteEnum:
                      diario.condicoesMeteorologicasNoiteEnum,
                  observacoesCondicoesMeteorologicas:
                      diario.observacoesCondicoesMeteorologicas,
                  aprovadoContratada: diario.aprovadoContratada ?? false,
                  assinadoContratada: diario.assinadoContratada ?? false,
                  assinadoContratante: diario.assinadoContratante ?? false,
                  dataHoraInclusao: diario.dataHoraInclusao,
                  statusObraEnum: diario.statusObraEnum,
                  statusSincronizacao: 'sincronizado',
                  erroSincronizacao: '',
                );
              }

              final List<DiarioObraEvolucaoServicosDto> listaEvolucaoServicos =
                  diario.diarioObraEvolucaoServicos;
              if (listaEvolucaoServicos.isNotEmpty) {
                for (DiarioObraEvolucaoServicosDto evolucao
                    in listaEvolucaoServicos) {
                  final evolucaoExistente = await database.diarioObraEvolucaoDao
                      .getByUid(evolucao.uid);

                  if (evolucaoExistente == null) {
                    await database.diarioObraEvolucaoDao
                        .inserirDiarioObraEvolucao(
                          uid: evolucao.uid,
                          obraUid: evolucao.obraUid,
                          diarioObraUid: diario.uid,
                          evolucao: evolucao.evolucao,
                          numero: evolucao.numero,
                          sequencial: evolucao.sequencial,
                          dataHoraInclusao: evolucao.dataHoraInclusao,
                        );
                  } else {
                    await database.diarioObraEvolucaoDao
                        .atualizarDiarioObraEvolucao(
                          uid: evolucao.uid,
                          obraUid: evolucao.obraUid,
                          diarioObraUid: diario.uid,
                          evolucao: evolucao.evolucao,
                          numero: evolucao.numero,
                          sequencial: evolucao.sequencial,
                          dataHoraInclusao: evolucao.dataHoraInclusao,
                        );
                  }
                }
              }

              final List<DiarioObraAnotacoesContratadaDto>
              listaAnotacoesContratada = diario.diarioObraAnotacoesContratada;
              if (listaAnotacoesContratada.isNotEmpty) {
                for (DiarioObraAnotacoesContratadaDto anotacao
                    in listaAnotacoesContratada) {
                  final anotacaoExistente = await database
                      .diarioObraAnotacoesContratadaDao
                      .getByUid(anotacao.uid);

                  if (anotacaoExistente == null) {
                    await database.diarioObraAnotacoesContratadaDao
                        .inserirDiarioObraAnotacoesContratada(
                          uid: anotacao.uid,
                          obraUid: anotacao.obraUid,
                          diarioObraUid: diario.uid,
                          anotacao: anotacao.anotacao,
                          data: DateTime.parse(anotacao.data),
                          dataHoraInclusao: anotacao.dataHoraInclusao,
                        );
                  } else {
                    await database.diarioObraAnotacoesContratadaDao
                        .atualizarDiarioObraAnotacoesContratada(
                          uid: anotacao.uid,
                          obraUid: anotacao.obraUid,
                          diarioObraUid: diario.uid,
                          anotacao: anotacao.anotacao,
                          data: DateTime.parse(anotacao.data),
                          dataHoraInclusao: anotacao.dataHoraInclusao,
                        );
                  }
                }
              }

              final List<DiarioObraAnotacoesGerenciadoraDto>
              listaAnotacoesGerenciadora =
                  diario.diarioObraAnotacoesGerenciadora;
              if (listaAnotacoesGerenciadora.isNotEmpty) {
                for (DiarioObraAnotacoesGerenciadoraDto anotacao
                    in listaAnotacoesGerenciadora) {
                  final anotacaoExistente = await database
                      .diarioObraAnotacoesGerenciadoraDao
                      .getByUid(anotacao.uid);
                  if (anotacaoExistente == null) {
                    await database.diarioObraAnotacoesGerenciadoraDao
                        .inserirDiarioObraAnotacoesGerenciadora(
                          uid: anotacao.uid,
                          obraUid: anotacao.obraUid,
                          diarioObraUid: diario.uid,
                          anotacao: anotacao.anotacao,
                          data: DateTime.parse(anotacao.data),
                          dataHoraInclusao: anotacao.dataHoraInclusao,
                        );
                  } else {
                    await database.diarioObraAnotacoesGerenciadoraDao
                        .atualizarDiarioObraAnotacoesGerenciadora(
                          uid: anotacao.uid,
                          obraUid: anotacao.obraUid,
                          diarioObraUid: diario.uid,
                          anotacao: anotacao.anotacao,
                          data: DateTime.parse(anotacao.data),
                          dataHoraInclusao: anotacao.dataHoraInclusao,
                        );
                  }
                }
              }

              final List<DiarioObraAnexoDto> listaDiarioObraAnexo =
                  diario.diarioObraAnexo;
              if (listaDiarioObraAnexo.isNotEmpty) {
                for (DiarioObraAnexoDto anexo in listaDiarioObraAnexo) {
                  final anexoExistente = await database.diarioObraAnexoDao
                      .getByUid(anexo.uid);

                  if (anexoExistente == null) {
                    await database.diarioObraAnexoDao.inserirDiarioObraAnexo(
                      uid: anexo.uid,
                      diarioObraUid: diario.uid,
                      descricao: anexo.descricao,
                      guidControleUpload: anexo.guidControleUpload,
                      uploadComplete: anexo.uploadComplete ?? true,
                    );

                    guidsParaDownload.add(anexo.uid);
                  } else {
                    await database.diarioObraAnexoDao.atualizarDiarioObraAnexo(
                      uid: anexo.uid,
                      diarioObraUid: diario.uid,
                      descricao: anexo.descricao,
                      guidControleUpload: anexo.guidControleUpload,
                      uploadComplete: anexo.uploadComplete ?? true,
                    );
                  }
                }
              }

              final List<DiarioObraApontamentoDto> listaDiarioObraApontamento =
                  diario.diarioObraApontamento;
              if (listaDiarioObraApontamento.isNotEmpty) {
                for (DiarioObraApontamentoDto apontamento
                    in listaDiarioObraApontamento) {
                  final apontamentoExistente = await database
                      .diarioObraApontamentoDao
                      .getByUid(apontamento.uid);

                  if (apontamentoExistente == null) {
                    await database.diarioObraApontamentoDao
                        .inserirDiarioObraApontamento(
                          uid: apontamento.uid,
                          diarioObraUid: diario.uid,
                          projetoEmpresaUid: apontamento.projetoEmpresaUid,
                          maoDeObraUid: apontamento.maoDeObraUid,
                          equipamentoUid: apontamento.equipamentoUid,
                          valorApontamento: apontamento.valorApontamento,
                          dataHoraInclusao: apontamento.dataHoraInclusao ?? '',
                        );
                  } else {
                    await database.diarioObraApontamentoDao
                        .atualizarDiarioObraApontamento(
                          uid: apontamento.uid,
                          diarioObraUid: diario.uid,
                          projetoEmpresaUid: apontamento.projetoEmpresaUid,
                          maoDeObraUid: apontamento.maoDeObraUid,
                          equipamentoUid: apontamento.equipamentoUid,
                          valorApontamento: apontamento.valorApontamento,
                          dataHoraInclusao: apontamento.dataHoraInclusao ?? '',
                        );
                  }
                }
              }
            }
          }

          final List<DiarioObraConsultarSubcontratadaDto>?
          listaDiarioObraConsultarSubcontratada =
              diarioObraConsultar.diarioObraConsultarSubcontratada;
          if (listaDiarioObraConsultarSubcontratada != null) {
            for (DiarioObraConsultarSubcontratadaDto diarioObraSubcontratada
                in listaDiarioObraConsultarSubcontratada) {
              final diarioObraConsultarSubcontratadaExistente = await database
                  .diarioObraConsultarSubcontratadaDao
                  .getByUid(diarioObraSubcontratada.uid);

              if (diarioObraConsultarSubcontratadaExistente == null) {
                await database.diarioObraConsultarSubcontratadaDao
                    .inserirDiarioObraConsultarSubcontratada(
                      uid: diarioObraSubcontratada.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      abreviacao: diarioObraSubcontratada.abreviacao,
                      nomeEmpresa: diarioObraSubcontratada.nomeEmpresa,
                      contatoPrincipal:
                          diarioObraSubcontratada.contatoPrincipal,
                      dataHoraInclusao:
                          diarioObraSubcontratada.dataHoraInclusao,
                    );
              } else {
                await database.diarioObraConsultarSubcontratadaDao
                    .inserirDiarioObraConsultarSubcontratada(
                      uid: diarioObraSubcontratada.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      abreviacao: diarioObraSubcontratada.abreviacao,
                      nomeEmpresa: diarioObraSubcontratada.nomeEmpresa,
                      contatoPrincipal:
                          diarioObraSubcontratada.contatoPrincipal,
                      dataHoraInclusao:
                          diarioObraSubcontratada.dataHoraInclusao,
                    );
              }

              final diarioObraConsultarSubcontratadaData =
                  DiarioObraConsultarSubcontratadaData(
                    uid: diarioObraSubcontratada.uid,
                    diarioObraConsultarUid: diarioObraConsultar.uid,
                    abreviacao: diarioObraSubcontratada.abreviacao,
                    nomeEmpresa: diarioObraSubcontratada.nomeEmpresa,
                    contatoPrincipal: diarioObraSubcontratada.contatoPrincipal,
                    dataHoraInclusao: diarioObraSubcontratada.dataHoraInclusao,
                  );

              diarioObraConsultarSubcontratadaDataList.add(
                diarioObraConsultarSubcontratadaData,
              );
            }
          }

          final List<DiarioObraConsultarEquipamentoDto>?
          listaDiarioObraConsultarEquipamento =
              diarioObraConsultar.diarioObraConsultarEquipamento;
          if (listaDiarioObraConsultarEquipamento != null) {
            for (DiarioObraConsultarEquipamentoDto diarioObraEquipamento
                in listaDiarioObraConsultarEquipamento) {
              final diarioObraConsultarEquipamentoExistente = await database
                  .diarioObraConsultarEquipamentoDao
                  .getByUid(diarioObraEquipamento.uid);

              if (diarioObraConsultarEquipamentoExistente == null) {
                await database.diarioObraConsultarEquipamentoDao
                    .inserirDiarioObraConsultarEquipamento(
                      uid: diarioObraEquipamento.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      equipamentoUid: diarioObraEquipamento.equipamento!.uid,
                      status: diarioObraEquipamento
                          .equipamento!
                          .statusEquipamentoEnumTexto,
                      dataHoraInclusao: diarioObraEquipamento.dataHoraInclusao,
                    );
              } else {
                await database.diarioObraConsultarEquipamentoDao
                    .atualizarDiarioObraConsultarEquipamento(
                      uid: diarioObraEquipamento.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      equipamentoUid: diarioObraEquipamento.equipamento!.uid,
                      status: diarioObraEquipamento
                          .equipamento!
                          .statusEquipamentoEnumTexto,
                      dataHoraInclusao: diarioObraEquipamento.dataHoraInclusao,
                    );
              }

              final diarioObraConsultarEquipamentoData =
                  DiarioObraConsultarEquipamentoData(
                    uid: diarioObraEquipamento.uid,
                    diarioObraConsultarUid: diarioObraConsultar.uid,
                    equipamentoUid: diarioObraEquipamento.equipamento!.uid,
                    status: diarioObraEquipamento
                        .equipamento!
                        .statusEquipamentoEnumTexto,
                    dataHoraInclusao: diarioObraEquipamento.dataHoraInclusao,
                  );

              diarioObraConsultarEquipamentoDataList.add(
                diarioObraConsultarEquipamentoData,
              );
            }
          }

          final List<DiarioObraConsultarMaoDeObraDto>?
          listaDiarioObraConsultarMaoDeObra =
              diarioObraConsultar.diarioObraConsultarMaoDeObra;
          if (listaDiarioObraConsultarMaoDeObra != null) {
            for (DiarioObraConsultarMaoDeObraDto diarioObraMaoDeObra
                in listaDiarioObraConsultarMaoDeObra) {
              final diarioObraConsultarMaoDeObraExistente = await database
                  .diarioObraConsultarMaoDeObraDao
                  .getByUid(diarioObraMaoDeObra.uid);

              if (diarioObraConsultarMaoDeObraExistente == null) {
                await database.diarioObraConsultarMaoDeObraDao
                    .inserirDiarioObraConsultarMaoDeObra(
                      uid: diarioObraMaoDeObra.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      maoDeObraUid: diarioObraMaoDeObra.maoDeObra!.uid,
                      status: diarioObraMaoDeObra
                          .maoDeObra!
                          .statusMaoDeObraEnumTexto,
                      dataHoraInclusao: diarioObraMaoDeObra.dataHoraInclusao,
                    );
              } else {
                await database.diarioObraConsultarMaoDeObraDao
                    .atualizarDiarioObraConsultarMaoDeObra(
                      uid: diarioObraMaoDeObra.uid,
                      diarioObraConsultarUid: diarioObraConsultar.uid,
                      maoDeObraUid: diarioObraMaoDeObra.maoDeObra!.uid,
                      status: diarioObraMaoDeObra
                          .maoDeObra!
                          .statusMaoDeObraEnumTexto,
                      dataHoraInclusao: diarioObraMaoDeObra.dataHoraInclusao,
                    );
              }

              final diarioObraConsultarMaoDeObraData =
                  DiarioObraConsultarMaoDeObraData(
                    uid: diarioObraMaoDeObra.uid,
                    diarioObraConsultarUid: diarioObraConsultar.uid,
                    maoDeObraUid: diarioObraMaoDeObra.maoDeObra!.uid,
                    status:
                        diarioObraMaoDeObra.maoDeObra!.statusMaoDeObraEnumTexto,
                    dataHoraInclusao: diarioObraMaoDeObra.dataHoraInclusao,
                  );

              diarioObraConsultarMaoDeObraDataList.add(
                diarioObraConsultarMaoDeObraData,
              );
            }
          }

          final diarioObraConsultarData = DiarioObraConsultarData(
            uid: diarioObraConsultar.uid,
            obraUid: diarioObraConsultar.obra!.uid,
            obraContratadoUid: diarioObraConsultar.obraContratados!.uid,
            projetoUid: diarioObraConsultar.projeto!.uid,
          );

          diarioObraConsultarDataList.add(diarioObraConsultarData);
        }

        setState(() {
          _listaDiarioObraConsultar = diarioObraConsultarDataList;
          _listaDiarioObraConsultarSubcontratada =
              diarioObraConsultarSubcontratadaDataList;
          _projetos = projetosDataList;
          _projetoEmpresas = projetoEmpresaDataList;
          _loading = false;
        });
      });
    } catch (e) {
      setState(() {
        print(e);
        _loading = false;
      });
    }
  }

  Future<void> _salvarDadosTemporarios() async {
    if (contratadoEscolhido == null) {
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Selecione uma obra e contratado primeiro'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool hasEquipamentoRepetido = false;

    final todosEquipamentos = [
      ..._listaDiarioObraConsultarEquipamento,
      ..._equipamentosTemporarios,
    ];
    final Set<String> uidsEquipamento = {};
    for (EquipamentoComNome equipamento in todosEquipamentos) {
      if (uidsEquipamento.contains(equipamento.equipamentoUid)) {
        hasEquipamentoRepetido = true;
        break;
      }
      uidsEquipamento.add(equipamento.equipamentoUid);
    }

    if (hasEquipamentoRepetido) {
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Não é permitido salvar dois equipamentos iguais.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool hasMaoDeObraRepetida = false;

    final todasMaosDeObra = [
      ..._listaDiarioObraConsultarMaoDeObra,
      ..._listaMaoDeObraTemporaria,
    ];
    final Set<String> uidsMaoDeObra = {};
    final Set<String> descricoes = {};
    for (MaoDeObraComNome maoDeObra in todasMaosDeObra) {
      if (maoDeObra.descricao == 'soldador'.toLowerCase() &&
          descricoes.contains('soldador'.toLowerCase())) {
        hasMaoDeObraRepetida = true;
        break;
      }
      if (uidsMaoDeObra.contains(maoDeObra.maoDeObraUid)) {
        hasMaoDeObraRepetida = true;
        break;
      }
      descricoes.add(maoDeObra.descricao);
      uidsMaoDeObra.add(maoDeObra.maoDeObraUid);
    }

    if (hasMaoDeObraRepetida) {
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Não é permitido salvar duas mãos de obra iguais.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final database = context.read<AppDatabase>();

      // Busca o DiarioObraConsultar relacionado ao contratado
      DiarioObraConsultarData? diarioConsultar =
          await (database.select(database.diarioObraConsultar)..where(
                (tbl) => tbl.obraContratadoUid.equals(contratadoEscolhido!.uid),
              ))
              .getSingleOrNull();

      if (diarioConsultar == null) {
        final uid = Uuid().v4();
        await database.diarioObraConsultarDao.inserirDiarioObraConsultar(
          uid: uid,
          obraUid: obraEscolhida!.uid,
          obraContratadoUid: contratadoEscolhido!.uid,
          projetoUid: projetoEscolhido!.uid,
        );
      }

      diarioConsultar =
          await (database.select(database.diarioObraConsultar)..where(
                (tbl) => tbl.obraContratadoUid.equals(contratadoEscolhido!.uid),
              ))
              .getSingleOrNull();

      await database.transaction(() async {
        final _uuid = Uuid();

        String _idFromTempSafe(String tempOrReal) {
          if (tempOrReal.startsWith('temp_')) {
            final candidate = tempOrReal.substring(5);
            final guidRegex = RegExp(
              r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
            );
            if (guidRegex.hasMatch(candidate)) return candidate;
            // se por algum motivo o sufixo não for GUID, gerar um novo GUID
            return _uuid.v4();
          }
          // se já for real (não começa com temp_) — opcional: garantir formato (ou gerar new)
          return tempOrReal;
        }

        // Mapa para traduzir temp UIDs -> novos UIDs reais
        final Map<String, String> tempToReal = {};
        // 1. SALVAR SUBCONTRATADAS

        // Remover subcontratadas marcadas para remoção
        for (String uid in _subcontratadaRemovidasUids) {
          await (database.delete(
            database.diarioObraConsultarSubcontratada,
          )..where((tbl) => tbl.uid.equals(uid))).go();
        }

        // Salvar novas e atualizar existentes
        for (var subcontratada in _listaSubcontratadaTemporaria) {
          if (subcontratada.uid.startsWith('temp_')) {
            // Nova subcontratada - gerar UID real
            final novoUid = _idFromTempSafe(subcontratada.uid);
            tempToReal[subcontratada.uid] = novoUid;
            await database.diarioObraConsultarSubcontratadaDao
                .inserirDiarioObraConsultarSubcontratada(
                  uid: novoUid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  abreviacao: subcontratada.abreviacao,
                  nomeEmpresa: subcontratada.nomeEmpresa,
                  contatoPrincipal: subcontratada.contatoPrincipal,
                  dataHoraInclusao: DateTime.now().toIso8601String(),
                );
          } else {
            // Atualizar existente
            await database.diarioObraConsultarSubcontratadaDao
                .atualizarDiarioObraConsultarSubcontratada(
                  uid: subcontratada.uid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  abreviacao: subcontratada.abreviacao,
                  nomeEmpresa: subcontratada.nomeEmpresa,
                  contatoPrincipal: subcontratada.contatoPrincipal,
                  dataHoraInclusao: subcontratada.dataHoraInclusao,
                );
          }
        }

        // 2. SALVAR EQUIPAMENTOS
        for (var equipamento in _equipamentosTemporarios) {
          if (equipamento.uid.startsWith('temp_')) {
            // Novo equipamento vinculado
            final novoUid = _idFromTempSafe(equipamento.uid);
            tempToReal[equipamento.uid] = novoUid;

            // Usa diretamente o equipamentoUid (que é o UID real do equipamento)
            await database.diarioObraConsultarEquipamentoDao
                .inserirDiarioObraConsultarEquipamento(
                  uid: novoUid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  equipamentoUid: equipamento.equipamentoUid, // ← MUDANÇA AQUI
                  status: equipamento.status,
                  dataHoraInclusao: DateTime.now().toIso8601String(),
                );
          } else {
            // Atualizar status do equipamento existente
            await database.diarioObraConsultarEquipamentoDao
                .atualizarDiarioObraConsultarEquipamento(
                  uid: equipamento.uid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  equipamentoUid: equipamento.equipamentoUid, // ← MUDANÇA AQUI
                  status: equipamento.status,
                  dataHoraInclusao: equipamento.dataHoraInclusao,
                );
          }
        }

        // 3. SALVAR MÃO DE OBRA
        for (var maoDeObra in _listaMaoDeObraTemporaria) {
          if (maoDeObra.uid.startsWith('temp_')) {
            final novoUid = _idFromTempSafe(maoDeObra.uid);
            tempToReal[maoDeObra.uid] = novoUid;

            await database.diarioObraConsultarMaoDeObraDao
                .inserirDiarioObraConsultarMaoDeObra(
                  uid: novoUid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  maoDeObraUid: maoDeObra.maoDeObraUid,
                  status: maoDeObra.status,
                  dataHoraInclusao: DateTime.now().toIso8601String(),
                );
          } else {
            await database.diarioObraConsultarMaoDeObraDao
                .atualizarDiarioObraConsultarMaoDeObra(
                  uid: maoDeObra.uid,
                  diarioObraConsultarUid: diarioConsultar!.uid,
                  maoDeObraUid: maoDeObra.maoDeObraUid,
                  status: maoDeObra.status,
                  dataHoraInclusao: maoDeObra.dataHoraInclusao,
                );
          }
        }

        // 4. SALVAR DIÁRIOS DE OBRA
        for (var diario in _listaDiarioObraTemporaria) {
          if (diario.uid.startsWith('temp_')) {
            // Novo diário
            final novoUidDiario = _idFromTempSafe(diario.uid);
            tempToReal[diario.uid] = novoUidDiario;

            await database.diarioObraDao.inserirDiarioObra(
              uid: novoUidDiario,
              usuarioResponsavelUid: diario.usuarioResponsavelUid,
              obraContratadosUid: contratadoEscolhido!.uid,
              diarioObraConsultarUid: diarioConsultar!.uid,
              statusObraEnum: diario.statusObraEnum,
              numero: null,
              data: diario.data,
              sequencial: null,
              aprovadoContratada: diario.aprovadoContratada ?? false,
              assinadoContratada: diario.assinadoContratada ?? false,
              assinadoContratante: diario.assinadoContratante ?? false,
              periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
              periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
              periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
              observacoesPeriodoTrabalhado: diario.observacoesPeriodoTrabalhado,
              condicoesMeteorologicasManhaEnum:
                  diario.condicoesMeteorologicasManhaEnum,
              condicoesMeteorologicasTardeEnum:
                  diario.condicoesMeteorologicasTardeEnum,
              condicoesMeteorologicasNoiteEnum:
                  diario.condicoesMeteorologicasNoiteEnum,
              observacoesCondicoesMeteorologicas:
                  diario.observacoesCondicoesMeteorologicas,
              dataHoraInclusao: DateTime.now().toIso8601String(),
              statusSincronizacao: 'pendente',
              erroSincronizacao: null,
            );

            await _atualizarStatusSincronizacao(
              novoUidDiario,
              'pendente',
              mensagemErro: null,
            );

            // Salvar evoluções
            for (var evolucao in diario.evolucoes) {
              final novoUidEvolucao = evolucao.uid.startsWith('temp_')
                  ? _idFromTempSafe(evolucao.uid)
                  : evolucao.uid;

              tempToReal[evolucao.uid] = novoUidEvolucao;

              await database.diarioObraEvolucaoDao.inserirDiarioObraEvolucao(
                uid: novoUidEvolucao,
                obraUid: obraEscolhida!.uid,
                diarioObraUid: novoUidDiario,
                evolucao: evolucao.evolucao,
                numero: int.tryParse(evolucao.numero) ?? 0,
                sequencial: evolucao.sequencial ?? 0,
                dataHoraInclusao: DateTime.now().toIso8601String(),
              );
            }

            // Salvar anotações da gerenciadora
            for (var anotacao in diario.anotacoesGerenciadora) {
              final novoUidAnotacao = anotacao.uid.startsWith('temp_')
                  ? _idFromTempSafe(anotacao.uid)
                  : anotacao.uid;

              tempToReal[anotacao.uid] = novoUidAnotacao;

              await database.diarioObraAnotacoesGerenciadoraDao
                  .inserirDiarioObraAnotacoesGerenciadora(
                    uid: novoUidAnotacao,
                    obraUid: obraEscolhida!.uid,
                    diarioObraUid: novoUidDiario,
                    anotacao: anotacao.anotacao,
                    data: anotacao.data,
                    dataHoraInclusao: DateTime.now().toIso8601String(),
                  );
            }

            // Salvar anotações da contratada
            for (var anotacao in diario.anotacoesContratada) {
              final novoUidAnotacao = anotacao.uid.startsWith('temp_')
                  ? _idFromTempSafe(anotacao.uid)
                  : anotacao.uid;

              tempToReal[anotacao.uid] = novoUidAnotacao;
              await database.diarioObraAnotacoesContratadaDao
                  .inserirDiarioObraAnotacoesContratada(
                    uid: novoUidAnotacao,
                    obraUid: obraEscolhida!.uid,
                    diarioObraUid: novoUidDiario,
                    anotacao: anotacao.anotacao,
                    data: anotacao.data,
                    dataHoraInclusao: DateTime.now().toIso8601String(),
                  );
            }

            // Salvar anexos
            for (var anexo in diario.anexos) {
              final novoUidAnexo = anexo.uid.startsWith('temp_')
                  ? _idFromTempSafe(anexo.uid)
                  : anexo.uid;

              tempToReal[anexo.uid] = novoUidAnexo;
              await database.diarioObraAnexoDao.inserirDiarioObraAnexo(
                uid: novoUidAnexo,
                diarioObraUid: novoUidDiario,
                descricao: anexo.descricao,
                guidControleUpload: anexo.guidControleUpload,
                uploadComplete: anexo.uploadComplete,
              );
            }

            // Salvar apontamentos
            for (var entry in diario.apontamentos.entries) {
              final key = entry.key;
              final valor = entry.value;

              // Se a chave não contiver um UID válido de subcontratada, apenas ignore o sufixo
              final parts = key.split('_');
              final rawItemUid = parts[0];
              final rawSubcontratadaUid = parts.length > 1
                  ? parts[1]
                  : 'contratada';

              final itemUidNormalizado =
                  tempToReal[rawItemUid] ??
                  (rawItemUid.startsWith('temp_')
                      ? _idFromTempSafe(rawItemUid)
                      : rawItemUid);

              final subcontratadaUidNormalizado =
                  (rawSubcontratadaUid != 'contratada')
                  ? (tempToReal[rawSubcontratadaUid] ??
                        (rawSubcontratadaUid.startsWith('temp_')
                            ? _idFromTempSafe(rawSubcontratadaUid)
                            : rawSubcontratadaUid))
                  : null;

              final novoUidApontamento = _uuid.v4();

              // Verifica se é equipamento ou mão de obra
              EquipamentoComNome? equipamento;
              MaoDeObraComNome? maoDeObra;
              try {
                equipamento = _listaDiarioObraConsultarEquipamento.firstWhere(
                  (e) => e.uid == rawItemUid || e.uid == itemUidNormalizado,
                );
              } catch (_) {
                equipamento = null;
              }

              try {
                maoDeObra = _listaDiarioObraConsultarMaoDeObra.firstWhere(
                  (m) => m.uid == rawItemUid || m.uid == itemUidNormalizado,
                );
              } catch (_) {
                maoDeObra = null;
              }

              String? equipamentoUidReal;
              String? maoDeObraUidReal;

              if (equipamento != null) {
                equipamentoUidReal = equipamento.equipamentoUid;
              } else if (maoDeObra != null) {
                maoDeObraUidReal = maoDeObra.maoDeObraUid;
              }

              if (equipamentoUidReal != null || maoDeObraUidReal != null) {
                await database.diarioObraApontamentoDao
                    .inserirDiarioObraApontamento(
                      uid: novoUidApontamento,
                      maoDeObraUid: maoDeObraUidReal,
                      diarioObraUid: novoUidDiario,
                      equipamentoUid: equipamentoUidReal,
                      valorApontamento: valor,
                      subcontratadaUid: subcontratadaUidNormalizado,
                      dataHoraInclusao: DateTime.now().toIso8601String(),
                    );
              }
            }
          } else {
            // Atualizar diário existente
            await database.diarioObraDao.atualizarDiarioObra(
              uid: diario.uid,
              usuarioResponsavelUid: diario.usuarioResponsavelUid,
              diarioObraConsultarUid: diarioConsultar!.uid,
              obraContratadosUid: contratadoEscolhido!.uid,
              statusObraEnum: diario.statusObraEnum,
              numero: diario.numero!,
              data: diario.data,
              sequencial: diario.sequencial,
              aprovadoContratada: diario.aprovadoContratada,
              assinadoContratada: diario.assinadoContratada,
              assinadoContratante: diario.assinadoContratante,
              periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
              periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
              periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
              observacoesPeriodoTrabalhado: diario.observacoesPeriodoTrabalhado,
              condicoesMeteorologicasManhaEnum:
                  diario.condicoesMeteorologicasManhaEnum,
              condicoesMeteorologicasTardeEnum:
                  diario.condicoesMeteorologicasTardeEnum,
              condicoesMeteorologicasNoiteEnum:
                  diario.condicoesMeteorologicasNoiteEnum,
              observacoesCondicoesMeteorologicas:
                  diario.observacoesCondicoesMeteorologicas,
              dataHoraInclusao: diario.dataHoraInclusao,
            );

            await _atualizarStatusSincronizacao(
              diario.uid,
              'pendente',
              mensagemErro: null,
            );

            await (database.delete(
              database.diarioObraEvolucao,
            )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).go();

            for (var evolucao in diario.evolucoes) {
              final novoUidEvolucao = DateTime.now().millisecondsSinceEpoch
                  .toString();
              await database.diarioObraEvolucaoDao.inserirDiarioObraEvolucao(
                uid: novoUidEvolucao,
                obraUid: obraEscolhida!.uid,
                diarioObraUid: diario.uid,
                evolucao: evolucao.evolucao,
                numero: int.tryParse(evolucao.numero) ?? 0,
                sequencial: evolucao.sequencial ?? 0,
                dataHoraInclusao: evolucao.dataHoraInclusao,
              );
            }

            await (database.delete(
              database.diarioObraAnotacoesGerenciadora,
            )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).go();

            for (var anotacao in diario.anotacoesGerenciadora) {
              final novoUidAnotacao = DateTime.now().millisecondsSinceEpoch
                  .toString();
              await database.diarioObraAnotacoesGerenciadoraDao
                  .inserirDiarioObraAnotacoesGerenciadora(
                    uid: novoUidAnotacao,
                    obraUid: obraEscolhida!.uid,
                    diarioObraUid: diario.uid,
                    anotacao: anotacao.anotacao,
                    data: anotacao.data,
                    dataHoraInclusao: anotacao.dataHoraInclusao,
                  );
            }

            await (database.delete(
              database.diarioObraAnotacoesContratada,
            )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).go();

            for (var anotacao in diario.anotacoesContratada) {
              final novoUidAnotacao = DateTime.now().millisecondsSinceEpoch
                  .toString();
              await database.diarioObraAnotacoesContratadaDao
                  .inserirDiarioObraAnotacoesContratada(
                    uid: novoUidAnotacao,
                    obraUid: obraEscolhida!.uid,
                    diarioObraUid: diario.uid,
                    anotacao: anotacao.anotacao,
                    data: anotacao.data,
                    dataHoraInclusao: anotacao.dataHoraInclusao,
                  );
            }

            await (database.delete(
              database.diarioObraAnexo,
            )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).go();

            for (var anexo in diario.anexos) {
              final novoUidAnexo = DateTime.now().millisecondsSinceEpoch
                  .toString();
              await database.diarioObraAnexoDao.inserirDiarioObraAnexo(
                uid: novoUidAnexo,
                diarioObraUid: diario.uid,
                descricao: anexo.descricao,
                guidControleUpload: anexo.guidControleUpload,
                uploadComplete: anexo.uploadComplete,
              );
            }

            await (database.delete(
              database.diarioObraApontamento,
            )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).go();

            // 6️⃣ Reinsere os apontamentos
            for (var entry in diario.apontamentos.entries) {
              final key = entry.key;
              final valor = entry.value;

              final parts = key.split('_');
              final itemUid = parts[0];
              final subcontratadaUid = parts.length > 1
                  ? parts[1]
                  : 'contratada';

              final novoUidApontamento = DateTime.now().millisecondsSinceEpoch
                  .toString();

              EquipamentoComNome? equipamento;
              MaoDeObraComNome? maoDeObra;

              try {
                equipamento = _listaDiarioObraConsultarEquipamento.firstWhere(
                  (e) => e.uid == itemUid,
                );
              } catch (_) {
                equipamento = null;
              }

              try {
                maoDeObra = _listaDiarioObraConsultarMaoDeObra.firstWhere(
                  (m) => m.uid == itemUid,
                );
              } catch (_) {
                maoDeObra = null;
              }

              String? equipamentoUidReal;
              String? maoDeObraUidReal;

              if (equipamento != null) {
                equipamentoUidReal = equipamento.equipamentoUid;
              } else if (maoDeObra != null) {
                maoDeObraUidReal = maoDeObra.maoDeObraUid;
              }

              if (equipamentoUidReal != null || maoDeObraUidReal != null) {
                await database.diarioObraApontamentoDao
                    .inserirDiarioObraApontamento(
                      uid: novoUidApontamento,
                      maoDeObraUid: maoDeObraUidReal,
                      diarioObraUid: diario.uid,
                      equipamentoUid: equipamentoUidReal,
                      valorApontamento: valor,
                      subcontratadaUid: subcontratadaUid != 'contratada'
                          ? subcontratadaUid
                          : null,
                      dataHoraInclusao: '',
                    );
              }
            }
          }
        }
      });

      if (contratadoEscolhido != null) {
        await _recarregarDadosContratado(contratadoEscolhido!);
      } else {
        final obraTexto = obraController.text;
        final contratadoTexto = contratadoController.text;
        await _carregarDados();

        obraController.text = obraTexto;
        contratadoController.text = contratadoTexto;
      }

      // Limpar listas temporárias após salvar
      _resetarListasTemporarias();

      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Dados salvos com sucesso!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erro ao salvar dados: $e');
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Erro ao salvar dados: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _recarregarDadosContratado(ObraContratado contratado) async {
    final database = context.read<AppDatabase>();

    final diarioConsultarRelacionado = await (database.select(
      database.diarioObraConsultar,
    )..where((tbl) => tbl.obraContratadoUid.equals(contratado.uid))).get();

    if (diarioConsultarRelacionado.isEmpty) return;

    final diarioConsultarUid = diarioConsultarRelacionado.first.uid;

    final diariosObra = await (database.select(
      database.diarioObra,
    )..where((tbl) => tbl.obraContratadosUid.equals(contratado.uid))).get();

    final List<DiarioObraComDados> diariosComDados = [];

    for (var diario in diariosObra) {
      // Buscar evoluções
      final evolucoes = await (database.select(
        database.diarioObraEvolucao,
      )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).get();

      final evolucoesComDados = evolucoes
          .map(
            (e) => EvolucaoServicoComDados(
              uid: e.uid,
              numero: e.numero.toString(),
              evolucao: e.evolucao,
              dataHoraInclusao: e.dataHoraInclusao,
              sequencial: e.sequencial,
            ),
          )
          .toList();

      // Buscar anotações gerenciadora
      final anotacoesGer = await (database.select(
        database.diarioObraAnotacoesGerenciadora,
      )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).get();

      final anotacoesGerComDados = anotacoesGer
          .map(
            (a) => AnotacaoGerenciadoraComDados(
              uid: a.uid,
              data: a.data,
              anotacao: a.anotacao,
              dataHoraInclusao: a.dataHoraInclusao,
            ),
          )
          .toList();

      // Buscar anotações contratada
      final anotacoesCont = await (database.select(
        database.diarioObraAnotacoesContratada,
      )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).get();

      final anotacoesContComDados = anotacoesCont
          .map(
            (a) => AnotacaoContratadaComDados(
              uid: a.uid,
              data: a.data,
              anotacao: a.anotacao,
              dataHoraInclusao: a.dataHoraInclusao,
            ),
          )
          .toList();

      // Buscar anexos
      final anexos = await (database.select(
        database.diarioObraAnexo,
      )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).get();

      final anexosComDados = anexos
          .map(
            (a) => AnexoComDados(
              uid: a.uid,
              descricao: a.descricao,
              guidControleUpload: a.guidControleUpload,
              uploadComplete: a.uploadComplete,
            ),
          )
          .toList();

      // Buscar apontamentos E CONVERTER PARA O FORMATO CORRETO
      final apontamentos = await (database.select(
        database.diarioObraApontamento,
      )..where((tbl) => tbl.diarioObraUid.equals(diario.uid))).get();

      final Map<String, int> apontamentosMap = {};
      for (var apontamento in apontamentos) {
        String? itemVinculoUid;
        String subcontratadaUid = apontamento.subcontratadaUid ?? 'contratada';

        if (apontamento.equipamentoUid != null) {
          // Buscar o UID do VÍNCULO (não o UID real do equipamento)
          try {
            final equipamentoVinculo = _listaDiarioObraConsultarEquipamento
                .firstWhere(
                  (e) => e.equipamentoUid == apontamento.equipamentoUid,
                );
            itemVinculoUid = equipamentoVinculo.uid;
          } catch (_) {}
        } else if (apontamento.maoDeObraUid != null) {
          // Buscar o UID do VÍNCULO (não o UID real da mão de obra)
          try {
            final maoDeObraVinculo = _listaDiarioObraConsultarMaoDeObra
                .firstWhere((m) => m.maoDeObraUid == apontamento.maoDeObraUid);
            itemVinculoUid = maoDeObraVinculo.uid;
          } catch (_) {}
        }

        if (itemVinculoUid != null) {
          final key = '${itemVinculoUid}_$subcontratadaUid';
          apontamentosMap[key] = apontamento.valorApontamento;
        }
      }

      // Criar o objeto completo
      diariosComDados.add(
        DiarioObraComDados(
          uid: diario.uid,
          usuarioResponsavelUid: diario.usuarioResponsavelUid,
          numero: diario.numero,
          data: diario.data,
          sequencial: diario.sequencial,
          statusObraEnum: diario.statusObraEnum,
          periodoTrabalhadoManhaEnum: diario.periodoTrabalhadoManhaEnum,
          periodoTrabalhadoTardeEnum: diario.periodoTrabalhadoTardeEnum,
          periodoTrabalhadoNoiteEnum: diario.periodoTrabalhadoNoiteEnum,
          observacoesPeriodoTrabalhado: diario.observacoesPeriodoTrabalhado,
          condicoesMeteorologicasManhaEnum:
              diario.condicoesMeteorologicasManhaEnum,
          condicoesMeteorologicasTardeEnum:
              diario.condicoesMeteorologicasTardeEnum,
          condicoesMeteorologicasNoiteEnum:
              diario.condicoesMeteorologicasNoiteEnum,
          observacoesCondicoesMeteorologicas:
              diario.observacoesCondicoesMeteorologicas,
          dataHoraInclusao: diario.dataHoraInclusao,
          statusSincronizacao: diario.statusSincronizacao,
          erroSincronizacao: diario.erroSincronizacao,
          // ADICIONAR OS DADOS RELACIONADOS
          evolucoes: evolucoesComDados,
          anotacoesGerenciadora: anotacoesGerComDados,
          anotacoesContratada: anotacoesContComDados,
          anexos: anexosComDados,
          apontamentos: apontamentosMap,
        ),
      );
    }

    final subcontratadas =
        await (database.select(database.diarioObraConsultarSubcontratada)
              ..where(
                (tbl) => tbl.diarioObraConsultarUid.equals(diarioConsultarUid),
              ))
            .get();

    final equipamentos =
        await (database.select(database.diarioObraConsultarEquipamento)..where(
              (tbl) => tbl.diarioObraConsultarUid.equals(diarioConsultarUid),
            ))
            .get();

    final maoDeObra =
        await (database.select(database.diarioObraConsultarMaoDeObra)..where(
              (tbl) => tbl.diarioObraConsultarUid.equals(diarioConsultarUid),
            ))
            .get();

    // Ordena: Não sincronizados primeiro, depois por prioridade de status
    diariosComDados.sort((a, b) {
      // prioridade por status de sincronização: erro (0) -> pendente (1) -> sincronizado (2)
      int prioridadeSync(String? s) {
        if (s == 'erro') return 0;
        if (s == 'pendente') return 1;
        return 2;
      }

      final psA = prioridadeSync(a.statusSincronizacao);
      final psB = prioridadeSync(b.statusSincronizacao);
      if (psA != psB) return psA.compareTo(psB);

      // depois a prioridade por statusObraEnum (mantendo lógica atual)
      int prioridadeObra(int? status) {
        if (status == 1) return 0; // maior prioridade
        if (status == 0) return 1;
        return 2;
      }

      final poA = prioridadeObra(a.statusObraEnum);
      final poB = prioridadeObra(b.statusObraEnum);
      if (poA != poB) return poA.compareTo(poB);

      // por fim número decrescente (mais recente primeiro)
      final numA = int.tryParse(a.numero ?? '') ?? 0;
      final numB = int.tryParse(b.numero ?? '') ?? 0;
      return numB.compareTo(numA);
    });

    final equipamentosComNome = await Future.wait(
      equipamentos.map((e) async {
        final equipamento = await (database.select(
          database.equipamento,
        )..where((tbl) => tbl.uid.equals(e.equipamentoUid!))).getSingleOrNull();
        return EquipamentoComNome(
          uid: e.uid,
          nomeEquipamento: equipamento?.nomeEquipamento ?? 'Desconhecido',
          status: e.status,
          equipamentoUid: e.equipamentoUid!,
          dataHoraInclusao: e.dataHoraInclusao,
        );
      }),
    );

    final maoDeObraComNome = await Future.wait(
      maoDeObra.map((m) async {
        final mao = await (database.select(
          database.maoDeObra,
        )..where((tbl) => tbl.uid.equals(m.maoDeObraUid!))).getSingleOrNull();
        return MaoDeObraComNome(
          uid: m.uid,
          descricao: mao?.descricao ?? 'Desconhecido',
          status: m.status,
          statusTipoMaoDeObraEnum: mao?.statusTipoMaoDeObraEnum ?? 0,
          maoDeObraUid: m.maoDeObraUid!,
          dataHoraInclusao: m.dataHoraInclusao,
        );
      }),
    );

    final obraTexto = obraController.text;
    final contratadoTexto = contratadoController.text;

    setState(() {
      _listaDiarioObraConsultarSubcontratada = subcontratadas;
      _listaDiarioObraConsultarEquipamento = equipamentosComNome;
      _listaDiarioObraConsultarMaoDeObra = maoDeObraComNome;
      _listaDiarioObra = diariosComDados;
    });

    obraController.text = obraTexto;
    contratadoController.text = contratadoTexto;
  }

  void _resetarListasTemporarias() {
    setState(() {
      _listaSubcontratadaTemporaria.clear();
      _subcontratadaRemovidasUids.clear();

      _equipamentosTemporarios.clear();

      _listaMaoDeObraTemporaria.clear();
      _listaDiarioObraTemporaria.clear();
    });
  }

  void _mostrarModalEquipamento({
    DiarioObraConsultarEquipamentoData? equipamento,
    String? uidTemporario,
    required String nomeEquipamento,
    required String status,
    required bool apenaVisualizacao,
    bool modoVinculacao = false,
    Function(EquipamentoComNome)? onSalvar,
  }) {
    showDialog(
      context: context,
      builder: (context) => ModalEquipamento(
        equipamento: equipamento,
        uidTemporario: uidTemporario,
        nomeEquipamento: nomeEquipamento,
        status: status,
        apenaVisualizacao: apenaVisualizacao,
        modoVinculacao: modoVinculacao,
        onSalvar: apenaVisualizacao ? null : onSalvar,
      ),
    ).then((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _salvarEquipamentoTemporario(EquipamentoComNome equipamento) {
    setState(() {
      final index = _equipamentosTemporarios.indexWhere(
        (e) => e.uid == equipamento.uid,
      );

      if (index != -1) {
        _equipamentosTemporarios[index] = equipamento;
      } else {
        _equipamentosTemporarios.add(equipamento);
      }
    });

    if (!mounted) return;
    _showSnackBarWithRetry(
      SnackBar(
        content: Text('Equipamento salvo temporariamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _vincularNovoEquipamento() {
    showDialog(
      context: context,
      builder: (context) => ModalEquipamento(
        modoVinculacao: true,
        onSalvar: (equipamentoAtualizado) {
          _salvarEquipamentoTemporario(equipamentoAtualizado);
          setState(() {
            final idx = _listaDiarioObraConsultarEquipamento.indexWhere(
              (e) => e.uid == equipamentoAtualizado.uid,
            );
            if (idx != -1) {
              _listaDiarioObraConsultarEquipamento[idx] = EquipamentoComNome(
                uid: _listaDiarioObraConsultarEquipamento[idx].uid,
                nomeEquipamento: equipamentoAtualizado.nomeEquipamento,
                status: equipamentoAtualizado.status,
                equipamentoUid:
                    _listaDiarioObraConsultarEquipamento[idx].equipamentoUid,
                dataHoraInclusao: equipamentoAtualizado.dataHoraInclusao,
              );
            }
          });
        },
      ),
    );
  }

  void _mostrarModalMaoDeObra({
    required DiarioObraConsultarMaoDeObraData? maoDeObra,
    String? uidTemporario,
    required String descricao,
    required String status,
    required bool apenaVisualizacao,
    required int statusTipoMaoDeObraEnum,
    bool modoVinculacao = false,
    Function(MaoDeObraComNome)? onSalvar,
  }) {
    showDialog(
      context: context,
      builder: (context) => ModalMaoDeObra(
        maoDeObra: maoDeObra,
        uidTemporario: uidTemporario,
        descricao: descricao,
        status: status,
        statusTipoMaoDeObraEnum: statusTipoMaoDeObraEnum,
        apenaVisualizacao: apenaVisualizacao,
        modoVinculacao: modoVinculacao,
        onSalvar: apenaVisualizacao ? null : onSalvar,
      ),
    ).then((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _salvarMaoDeObraTemporaria(MaoDeObraComNome maoDeObra) {
    setState(() {
      final index = _listaMaoDeObraTemporaria.indexWhere(
        (e) => e.uid == maoDeObra.uid,
      );

      if (index != -1) {
        _listaMaoDeObraTemporaria[index] = maoDeObra;
      } else {
        _listaMaoDeObraTemporaria.add(maoDeObra);
      }
    });

    _showSnackBarWithRetry(
      SnackBar(
        content: Text('Mão de obra salva temporariamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _vincularNovaMaoDeObra() {
    showDialog(
      context: context,
      builder: (context) => ModalMaoDeObra(
        modoVinculacao: true,
        onSalvar: (maoDeObraAtualizada) {
          _salvarMaoDeObraTemporaria(maoDeObraAtualizada);
          setState(() {
            final idx = _listaDiarioObraConsultarMaoDeObra.indexWhere(
              (e) => e.uid == maoDeObraAtualizada.uid,
            );

            if (idx != -1) {
              _listaDiarioObraConsultarMaoDeObra[idx] = MaoDeObraComNome(
                uid: _listaDiarioObraConsultarMaoDeObra[idx].uid,
                descricao: maoDeObraAtualizada.descricao,
                status: maoDeObraAtualizada.status,
                statusTipoMaoDeObraEnum:
                    maoDeObraAtualizada.statusTipoMaoDeObraEnum,
                maoDeObraUid:
                    _listaDiarioObraConsultarMaoDeObra[idx].maoDeObraUid,
                dataHoraInclusao: maoDeObraAtualizada.dataHoraInclusao,
              );
            }
          });
        },
      ),
    );
  }

  void _mostrarModalSubcontratada({
    required DiarioObraConsultarSubcontratadaData? subcontratada,
    String? uidTemporario,
    required String abreviacao,
    required String nomeEmpresa,
    required String contatoPrincipal,
    required bool apenaVisualizacao,
    bool modoVinculacao = false,
    Function(SubcontratadaComNome)? onSalvar,
  }) {
    showDialog(
      context: context,
      builder: (context) => ModalSubcontratada(
        subcontratada: subcontratada,
        uidTemporario: uidTemporario,
        abreviacao: abreviacao,
        nomeEmpresa: nomeEmpresa,
        contatoPrincipal: contatoPrincipal,
        apenaVisualizacao: apenaVisualizacao,
        modoVinculacao: modoVinculacao,
        onSalvar: apenaVisualizacao ? null : onSalvar,
      ),
    ).then((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _salvarSubcontratadaTemporaria(SubcontratadaComNome subcontratada) {
    setState(() {
      final index = _listaSubcontratadaTemporaria.indexWhere(
        (e) => e.uid == subcontratada.uid,
      );

      if (index != -1) {
        _listaSubcontratadaTemporaria[index] = subcontratada;
      } else {
        _listaSubcontratadaTemporaria.add(subcontratada);
      }
    });

    if (!mounted) return;
    _showSnackBarWithRetry(
      SnackBar(
        content: Text('Subcontratada salva temporariamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _vincularNovaSubcontratada() {
    showDialog(
      context: context,
      builder: (context) => ModalSubcontratada(
        modoVinculacao: true,
        onSalvar: (novaSubcontratada) {
          _salvarSubcontratadaTemporaria(novaSubcontratada);
        },
      ),
    );
  }

  void _removerSubcontratadaTemporaria(String uid) {
    setState(() {
      if (!_subcontratadaRemovidasUids.contains(uid)) {
        _subcontratadaRemovidasUids.add(uid);
      }

      _listaSubcontratadaTemporaria.removeWhere((e) => e.uid == uid);
    });

    if (!mounted) return;
    _showSnackBarWithRetry(
      SnackBar(
        content: Text('Subcontratada removida temporariamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _mostrarModalDiarioObra({
    DiarioObraData? diarioObra,
    UsuarioData? usuario,
    String? uidTemporario,
    String? numero,
    required DateTime data,
    required int periodoTrabalhadoManhaEnum,
    required int periodoTrabalhadoTardeEnum,
    required int periodoTrabalhadoNoiteEnum,
    required int condicoesMeteorologicasManhaEnum,
    required int condicoesMeteorologicasTardeEnum,
    required int condicoesMeteorologicasNoiteEnum,
    required int statusObraEnum,
    String? observacoesPeriodoTrabalhado,
    String? observacoesCondicoesMeteorologicas,
    required bool apenaVisualizacao,
    bool modoCriacao = false,
    Function(DiarioObraComDados)? onSalvar,
  }) async {
    final database = context.read<AppDatabase>();
    String nomeResponsavel = 'Não informado';
    int pronomeEnum = 0;

    if (obraEscolhida != null) {
      final contato =
          await (database.select(database.contato)..where(
                (tbl) => tbl.uid.equals(obraEscolhida!.contatoResponsavelUid!),
              ))
              .getSingleOrNull();

      if (contato != null) {
        nomeResponsavel = '${contato.nome} ${contato.ultimoNome}';
        pronomeEnum = contato.pronomeEnum;
      }
    }

    // ✅ LÓGICA SIMPLIFICADA: Busca os dados completos apenas uma vez
    DiarioObraComDados? diarioCompleto;

    if (!modoCriacao && (uidTemporario != null || diarioObra != null)) {
      final uidParaBuscar = uidTemporario ?? diarioObra?.uid;

      // 1. Primeiro tenta pegar dos temporários
      try {
        diarioCompleto = _listaDiarioObraTemporaria.firstWhere(
          (d) => d.uid == uidParaBuscar,
        );
        print('📝 Diário encontrado nos temporários: ${diarioCompleto.uid}');
      } catch (_) {
        // 2. Se não está nos temporários, busca na lista principal
        try {
          diarioCompleto = _listaDiarioObra.firstWhere(
            (d) => d.uid == uidParaBuscar,
          );
          print(
            '📝 Diário encontrado na lista principal: ${diarioCompleto.uid}',
          );
        } catch (_) {
          print('⚠️ Diário não encontrado em nenhuma lista: $uidParaBuscar');
        }
      }
    }

    // ✅ Usa os dados do diário completo (se existir), caso contrário null
    final evolucoes = diarioCompleto?.evolucoes;
    final anotacoesGerenciadora = diarioCompleto?.anotacoesGerenciadora;
    final anotacoesContratada = diarioCompleto?.anotacoesContratada;
    final anexos = diarioCompleto?.anexos;
    final apontamentos = diarioCompleto?.apontamentos;

    // 🔍 Debug - Mostra o que foi carregado
    if (diarioCompleto != null) {
      print('✅ Dados carregados para o diário ${diarioCompleto.uid}:');
      print('   - Evoluções: ${evolucoes?.length ?? 0}');
      print(
        '   - Anotações Gerenciadora: ${anotacoesGerenciadora?.length ?? 0}',
      );
      print('   - Anotações Contratada: ${anotacoesContratada?.length ?? 0}');
      print('   - Anexos: ${anexos?.length ?? 0}');
      print('   - Apontamentos: ${apontamentos?.length ?? 0}');
    } else {
      print(
        '⚠️ Nenhum dado completo carregado - modo criação ou diário não encontrado',
      );
    }

    showDialog(
      context: context,
      builder: (context) => ModalDiarioObra(
        diarioObra: diarioObra,
        usuario: usuario,
        uidTemporario: uidTemporario,
        numero: numero,
        data: data,
        periodoTrabalhadoManhaEnum: periodoTrabalhadoManhaEnum,
        periodoTrabalhadoTardeEnum: periodoTrabalhadoTardeEnum,
        periodoTrabalhadoNoiteEnum: periodoTrabalhadoNoiteEnum,
        condicoesMeteorologicasManhaEnum: condicoesMeteorologicasManhaEnum,
        condicoesMeteorologicasTardeEnum: condicoesMeteorologicasTardeEnum,
        condicoesMeteorologicasNoiteEnum: condicoesMeteorologicasNoiteEnum,
        statusObraEnum: statusObraEnum,
        observacoesPeriodoTrabalhado: observacoesPeriodoTrabalhado,
        observacoesCondicoesMeteorologicas: observacoesCondicoesMeteorologicas,
        apenaVisualizacao: apenaVisualizacao,
        modoCriacao: modoCriacao,
        onSalvar: apenaVisualizacao ? null : onSalvar,
        evolucoesIniciais: evolucoes,
        anotacoesGerenciadoraIniciais: anotacoesGerenciadora,
        anotacoesContratadaIniciais: anotacoesContratada,
        anexosIniciais: anexos,
        apontamentosIniciais: apontamentos,
        listaEquipamentos: _listaDiarioObraConsultarEquipamento,
        listaMaoDeObra: _listaDiarioObraConsultarMaoDeObra,
        listaSubcontratada: _listaDiarioObraConsultarSubcontratada,
        nomeObra: obraEscolhida!.nomeObra,
        nomeContratado: nomeContratadoEscolhido ?? '',
        nomeResponsavel: nomeResponsavel,
        pronomeEnum: pronomeEnum,
      ),
    ).then((result) {
      FocusScope.of(context).unfocus();
      if (result != null && result is DiarioObraComDados) {
        _salvarDiarioObraTemporario(result);
      }
    });
  }

  void _salvarDiarioObraTemporario(DiarioObraComDados diario) {
    setState(() {
      final index = _listaDiarioObraTemporaria.indexWhere(
        (e) => e.uid == diario.uid,
      );

      final diarioComStatus = diario.copyWith(
        statusSincronizacao: 'pendente',
        erroSincronizacao: null,
      );

      if (index != -1) {
        _listaDiarioObraTemporaria[index] = diario;
      } else {
        _listaDiarioObraTemporaria.add(diario);
      }
    });

    if (!mounted) return;
    _showSnackBarWithRetry(
      SnackBar(
        content: Text('Diário de Obra salvo temporariamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _criarNovoDiarioObra() async {
    if (contratadoEscolhido == null) {
      if (!mounted) return;
      _showSnackBarWithRetry(
        SnackBar(
          content: Text('Selecione uma obra e contratado primeiro'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calcula o próximo número de diário
    final database = context.read<AppDatabase>();
    final diariosExistentes =
        await (database.select(database.diarioObra)..where(
              (tbl) => tbl.obraContratadosUid.equals(contratadoEscolhido!.uid),
            ))
            .get();

    int proximoNumero = 1;
    if (diariosExistentes.isNotEmpty) {
      final numeros = diariosExistentes
          .map((d) => int.tryParse(d.numero ?? '') ?? 0)
          .where((n) => n > 0)
          .toList();

      if (numeros.isNotEmpty) {
        final maiorNumero = numeros.reduce((a, b) => a > b ? a : b);
        proximoNumero = maiorNumero + 1;
      }
    }

    // Considera também os diários temporários
    if (_listaDiarioObraTemporaria.isNotEmpty) {
      final numerosTemp = _listaDiarioObraTemporaria
          .map((d) => int.tryParse(d.numero!) ?? 0)
          .where((n) => n > 0)
          .toList();

      if (numerosTemp.isNotEmpty) {
        final maiorNumeroTemp = numerosTemp.reduce((a, b) => a > b ? a : b);
        if (maiorNumeroTemp >= proximoNumero) {
          proximoNumero = maiorNumeroTemp + 1;
        }
      }
    }

    _mostrarModalDiarioObra(
      usuario: _user,
      numero: null,
      data: DateTime.now(),
      periodoTrabalhadoManhaEnum: 0,
      periodoTrabalhadoTardeEnum: 0,
      periodoTrabalhadoNoiteEnum: 0,
      condicoesMeteorologicasManhaEnum: 0,
      condicoesMeteorologicasTardeEnum: 0,
      condicoesMeteorologicasNoiteEnum: 0,
      statusObraEnum: 0,
      apenaVisualizacao: false,
      modoCriacao: true,
      onSalvar: (novoDiario) {
        _salvarDiarioObraTemporario(novoDiario);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C2E35),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Aguarde\nCarregando dados...",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Boomer',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                'assets/images/loading-screen-spinner.gif',
                width: 80,
                height: 80,
              ),
            ],
          ),
        ),
      );
    }
    // drawer: Drawer(
    //   child: ListView(
    //     padding: EdgeInsets.zero,
    //     children: <Widget>[
    //       SizedBox(
    //         height: 200,
    //         child: DrawerHeader(
    //           decoration: BoxDecoration(
    //             color: const Color.fromRGBO(53, 53, 53, 1),
    //           ),
    //           child: Image.asset(
    //             "assets/images/logotipo_lotusplan_branco_p_maior.png",
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ),
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 238, 238),
      appBar: _user != null && _projetos.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: CustomAppbar(
                user: _user!,
                projetos: _projetos,
                onProjetoSelecionado: _onProjetoSelecionado,
              ),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Cadastro de Diário de Obras",
                  style: TextStyle(
                    color: Color(0xFF2C2E35),
                    fontFamily: 'Boomer',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: ObraInputAutocomplete(
                          label: 'Obra*',
                          controller: obraController,
                          obras: _obras,
                          onChanged: (valor) async {
                            setState(() {
                              obraEscolhida = valor;
                              contratadoController.clear();
                              contratadoEscolhido = null;
                              nomeContratadoEscolhido = null;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 250,
                        child: CustomInputAutocomplete(
                          label: 'Contratados*',
                          controller: contratadoController,
                          contratados: _contratados,
                          obraEscolhida: obraEscolhida,
                          listaProjetoEmpresa: _projetoEmpresas,
                          onEmpresaChanged: (empresa) async {
                            print(
                              'empresa escolhida: ${empresa?.nomeFantasia}',
                            );
                          },
                          onContratadoSelecionado: (contratado) async {
                            if (contratado == null) return;

                            _resetarListasTemporarias();

                            setState(() {
                              _carregandoDiarioObra = true;
                              contratadoEscolhido = contratado;

                              final empresa = _projetoEmpresas.firstWhere(
                                (e) => e.uid == contratado.projetoEmpresaUid,
                                orElse: () => ProjetoEmpresaData(
                                  uid: '',
                                  nomeFantasia: 'Não informado',
                                  abreviacao: '',
                                ),
                              );

                              nomeContratadoEscolhido = empresa.nomeFantasia;

                              dataInicioFormatada =
                                  "${contratadoEscolhido!.dataInicio.day.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataInicio.month.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataInicio.year}";
                              dataTerminoFormatada =
                                  "${contratadoEscolhido!.dataTermino.day.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataTermino.month.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataTermino.year}";
                              dataTerminoRealizadoFormatada =
                                  "${contratadoEscolhido!.dataTerminoRealizado?.day.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataTerminoRealizado?.month.toString().padLeft(2, '0')}/"
                                  "${contratadoEscolhido!.dataTerminoRealizado?.year}";
                            });

                            try {
                              final database = context.read<AppDatabase>();

                              final diarioConsultarRelacionado =
                                  await (database.select(
                                        database.diarioObraConsultar,
                                      )..where(
                                        (tbl) => tbl.obraContratadoUid.equals(
                                          contratadoEscolhido!.uid,
                                        ),
                                      ))
                                      .get();

                              if (diarioConsultarRelacionado.isEmpty) {
                                setState(() {
                                  _listaDiarioObraConsultarSubcontratada = [];
                                  _listaDiarioObraConsultarEquipamento = [];
                                  _listaDiarioObraConsultarMaoDeObra = [];
                                  _listaDiarioObra = [];
                                });
                                return;
                              }

                              final diarioConsultarUid =
                                  diarioConsultarRelacionado.first.uid;

                              final diariosObra =
                                  await (database.select(database.diarioObra)
                                        ..where(
                                          (tbl) => tbl.obraContratadosUid
                                              .equals(contratadoEscolhido!.uid),
                                        ))
                                      .get();

                              final subcontratadas =
                                  await (database.select(
                                        database
                                            .diarioObraConsultarSubcontratada,
                                      )..where(
                                        (tbl) => tbl.diarioObraConsultarUid
                                            .equals(diarioConsultarUid),
                                      ))
                                      .get();

                              final equipamentos =
                                  await (database.select(
                                        database.diarioObraConsultarEquipamento,
                                      )..where(
                                        (tbl) => tbl.diarioObraConsultarUid
                                            .equals(diarioConsultarUid),
                                      ))
                                      .get();

                              final maoDeObra =
                                  await (database.select(
                                        database.diarioObraConsultarMaoDeObra,
                                      )..where(
                                        (tbl) => tbl.diarioObraConsultarUid
                                            .equals(diarioConsultarUid),
                                      ))
                                      .get();

                              final List<DiarioObraComDados> diariosComDados =
                                  [];

                              for (var diario in diariosObra) {
                                // Buscar evoluções
                                final evolucoes =
                                    await (database.select(
                                          database.diarioObraEvolucao,
                                        )..where(
                                          (tbl) => tbl.diarioObraUid.equals(
                                            diario.uid,
                                          ),
                                        ))
                                        .get();

                                final evolucoesComDados = evolucoes
                                    .map(
                                      (e) => EvolucaoServicoComDados(
                                        uid: e.uid,
                                        numero: e.numero.toString(),
                                        evolucao: e.evolucao,
                                        dataHoraInclusao: e.dataHoraInclusao,
                                        sequencial: e.sequencial,
                                      ),
                                    )
                                    .toList();

                                // Buscar anotações gerenciadora
                                final anotacoesGer =
                                    await (database.select(
                                          database
                                              .diarioObraAnotacoesGerenciadora,
                                        )..where(
                                          (tbl) => tbl.diarioObraUid.equals(
                                            diario.uid,
                                          ),
                                        ))
                                        .get();

                                final anotacoesGerComDados = anotacoesGer
                                    .map(
                                      (a) => AnotacaoGerenciadoraComDados(
                                        uid: a.uid,
                                        data: a.data,
                                        anotacao: a.anotacao,
                                        dataHoraInclusao: a.dataHoraInclusao,
                                      ),
                                    )
                                    .toList();

                                // Buscar anotações contratada
                                final anotacoesCont =
                                    await (database.select(
                                          database
                                              .diarioObraAnotacoesContratada,
                                        )..where(
                                          (tbl) => tbl.diarioObraUid.equals(
                                            diario.uid,
                                          ),
                                        ))
                                        .get();

                                final anotacoesContComDados = anotacoesCont
                                    .map(
                                      (a) => AnotacaoContratadaComDados(
                                        uid: a.uid,
                                        data: a.data,
                                        anotacao: a.anotacao,
                                        dataHoraInclusao: a.dataHoraInclusao,
                                      ),
                                    )
                                    .toList();

                                // Buscar anexos
                                final anexos =
                                    await (database.select(
                                          database.diarioObraAnexo,
                                        )..where(
                                          (tbl) => tbl.diarioObraUid.equals(
                                            diario.uid,
                                          ),
                                        ))
                                        .get();

                                final anexosComDados = anexos
                                    .map(
                                      (a) => AnexoComDados(
                                        uid: a.uid,
                                        descricao: a.descricao,
                                        guidControleUpload:
                                            a.guidControleUpload,
                                        uploadComplete: a.uploadComplete,
                                      ),
                                    )
                                    .toList();

                                // Buscar apontamentos E CONVERTER PARA O FORMATO CORRETO
                                final apontamentos =
                                    await (database.select(
                                          database.diarioObraApontamento,
                                        )..where(
                                          (tbl) => tbl.diarioObraUid.equals(
                                            diario.uid,
                                          ),
                                        ))
                                        .get();

                                final Map<String, int> apontamentosMap = {};
                                for (var apontamento in apontamentos) {
                                  String? itemVinculoUid;
                                  String subcontratadaUid =
                                      apontamento.subcontratadaUid ??
                                      'contratada';

                                  if (apontamento.equipamentoUid != null) {
                                    // Buscar o UID do VÍNCULO (não o UID real do equipamento)
                                    try {
                                      final equipamentoVinculo =
                                          _listaDiarioObraConsultarEquipamento
                                              .firstWhere(
                                                (e) =>
                                                    e.equipamentoUid ==
                                                    apontamento.equipamentoUid,
                                              );
                                      itemVinculoUid = equipamentoVinculo.uid;
                                    } catch (_) {}
                                  } else if (apontamento.maoDeObraUid != null) {
                                    // Buscar o UID do VÍNCULO (não o UID real da mão de obra)
                                    try {
                                      final maoDeObraVinculo =
                                          _listaDiarioObraConsultarMaoDeObra
                                              .firstWhere(
                                                (m) =>
                                                    m.maoDeObraUid ==
                                                    apontamento.maoDeObraUid,
                                              );
                                      itemVinculoUid = maoDeObraVinculo.uid;
                                    } catch (_) {}
                                  }

                                  if (itemVinculoUid != null) {
                                    final key =
                                        '${itemVinculoUid}_$subcontratadaUid';
                                    apontamentosMap[key] =
                                        apontamento.valorApontamento;
                                  }
                                }

                                // Criar o objeto completo
                                diariosComDados.add(
                                  DiarioObraComDados(
                                    uid: diario.uid,
                                    usuarioResponsavelUid:
                                        diario.usuarioResponsavelUid,
                                    numero: diario.numero,
                                    data: diario.data,
                                    sequencial: diario.sequencial,
                                    statusObraEnum: diario.statusObraEnum,
                                    periodoTrabalhadoManhaEnum:
                                        diario.periodoTrabalhadoManhaEnum,
                                    periodoTrabalhadoTardeEnum:
                                        diario.periodoTrabalhadoTardeEnum,
                                    periodoTrabalhadoNoiteEnum:
                                        diario.periodoTrabalhadoNoiteEnum,
                                    observacoesPeriodoTrabalhado:
                                        diario.observacoesPeriodoTrabalhado,
                                    condicoesMeteorologicasManhaEnum:
                                        diario.condicoesMeteorologicasManhaEnum,
                                    condicoesMeteorologicasTardeEnum:
                                        diario.condicoesMeteorologicasTardeEnum,
                                    condicoesMeteorologicasNoiteEnum:
                                        diario.condicoesMeteorologicasNoiteEnum,
                                    observacoesCondicoesMeteorologicas: diario
                                        .observacoesCondicoesMeteorologicas,
                                    dataHoraInclusao: diario.dataHoraInclusao,
                                    statusSincronizacao:
                                        diario.statusSincronizacao,
                                    erroSincronizacao: diario.erroSincronizacao,
                                    // ADICIONAR OS DADOS RELACIONADOS
                                    evolucoes: evolucoesComDados,
                                    anotacoesGerenciadora: anotacoesGerComDados,
                                    anotacoesContratada: anotacoesContComDados,
                                    anexos: anexosComDados,
                                    apontamentos: apontamentosMap,
                                  ),
                                );
                              }

                              diariosComDados.sort((a, b) {
                                // prioridade por status de sincronização: erro (0) -> pendente (1) -> sincronizado (2)
                                int prioridadeSync(String? s) {
                                  if (s == 'erro') return 0;
                                  if (s == 'pendente') return 1;
                                  return 2;
                                }

                                final psA = prioridadeSync(
                                  a.statusSincronizacao,
                                );
                                final psB = prioridadeSync(
                                  b.statusSincronizacao,
                                );
                                if (psA != psB) return psA.compareTo(psB);

                                // depois a prioridade por statusObraEnum (mantendo lógica atual)
                                int prioridadeObra(int? status) {
                                  if (status == 1) return 0; // maior prioridade
                                  if (status == 0) return 1;
                                  return 2;
                                }

                                final poA = prioridadeObra(a.statusObraEnum);
                                final poB = prioridadeObra(b.statusObraEnum);
                                if (poA != poB) return poA.compareTo(poB);

                                // por fim número decrescente (mais recente primeiro)
                                final numA = int.tryParse(a.numero ?? '') ?? 0;
                                final numB = int.tryParse(b.numero ?? '') ?? 0;
                                return numB.compareTo(numA);
                              });

                              final equipamentosComNome = await Future.wait(
                                equipamentos.map((e) async {
                                  final equipamento =
                                      await (database.select(
                                            database.equipamento,
                                          )..where(
                                            (tbl) => tbl.uid.equals(
                                              e.equipamentoUid!,
                                            ),
                                          ))
                                          .getSingleOrNull();

                                  return EquipamentoComNome(
                                    uid: e.uid,
                                    nomeEquipamento:
                                        equipamento?.nomeEquipamento ??
                                        'Desconhecido',
                                    status: e.status,
                                    equipamentoUid: e.equipamentoUid!,
                                    dataHoraInclusao: e.dataHoraInclusao,
                                  );
                                }),
                              );

                              for (var e in equipamentos) {
                                print(
                                  "→ diário: ${e.diarioObraConsultarUid}, equipamentoUid: ${e.equipamentoUid}",
                                );
                                final eq =
                                    await (database.select(
                                          database.equipamento,
                                        )..where(
                                          (tbl) =>
                                              tbl.uid.equals(e.equipamentoUid!),
                                        ))
                                        .getSingleOrNull();
                                print(
                                  "  nomeEquipamento encontrado: ${eq?.nomeEquipamento}",
                                );
                              }

                              final maoDeObraComNome = await Future.wait(
                                maoDeObra.map((m) async {
                                  final mao =
                                      await (database.select(
                                            database.maoDeObra,
                                          )..where(
                                            (tbl) =>
                                                tbl.uid.equals(m.maoDeObraUid!),
                                          ))
                                          .getSingleOrNull();

                                  return MaoDeObraComNome(
                                    uid: m.uid,
                                    descricao: mao?.descricao ?? 'Desconhecido',
                                    status: m.status,
                                    statusTipoMaoDeObraEnum:
                                        mao?.statusTipoMaoDeObraEnum ?? 0,
                                    maoDeObraUid: m.maoDeObraUid!,
                                    dataHoraInclusao: m.dataHoraInclusao,
                                  );
                                }),
                              );

                              setState(() {
                                _listaDiarioObraConsultarSubcontratada =
                                    subcontratadas;
                                _listaDiarioObraConsultarEquipamento =
                                    equipamentosComNome;
                                _listaDiarioObraConsultarMaoDeObra =
                                    maoDeObraComNome;
                                _listaDiarioObra = diariosComDados;
                              });
                            } finally {
                              _carregandoDiarioObra = false;
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        child: contratadoEscolhido != null
                            ? Text(
                                "\nEscopo: ${contratadoEscolhido!.escopo}\n\nInicio: $dataInicioFormatada\nPrazo: ${contratadoEscolhido!.prazo} dias\nAditivo: ${contratadoEscolhido!.aditivos} dias\nTérmino Previsto: $dataTerminoFormatada\n\nTérmino Real: ${dataTerminoRealizadoFormatada == "null/null/null" ? "" : dataTerminoRealizadoFormatada}\n",
                                style: TextStyle(
                                  fontFamily: 'Boomer',
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              )
                            : Text(""),
                      ),
                      if (_listaDiarioObraConsultarEquipamento.isEmpty &&
                          _listaDiarioObraConsultarMaoDeObra.isEmpty) ...[
                        Text(
                          "Diário de Obras",
                          style: TextStyle(
                            color: Color(0xFF2C2E35),
                            fontFamily: 'Boomer',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else ...[
                        SecaoComBotao(
                          titulo: "Diário de Obras",
                          textoBotao: "Criar",
                          onPressed: () {
                            _criarNovoDiarioObra();
                          },
                          visivel: contratadoEscolhido != null,
                        ),
                      ],
                      // Tabela: Diário de Obra
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFDFDF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.40),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3.0),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2.5),
                          },
                          children: [
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Número',
                                        style: TextStyle(
                                          color: Color(0xFF81868D),
                                          fontSize: 12,
                                          fontFamily: 'Boomer',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Data',
                                        style: TextStyle(
                                          color: Color(0xFF81868D),
                                          fontSize: 12,
                                          fontFamily: 'Boomer',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Status',
                                        style: TextStyle(
                                          color: Color(0xFF81868D),
                                          fontSize: 12,
                                          fontFamily: 'Boomer',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Detalhes',
                                        style: TextStyle(
                                          color: Color(0xFF81868D),
                                          fontSize: 12,
                                          fontFamily: 'Boomer',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              decoration: BoxDecoration(
                                color: Color(0xFFDFDFDF),
                              ),
                            ),
                            if (contratadoEscolhido != null)
                              ...() {
                                // Combina itens originais com novos criados/editados
                                final itensOriginais = _listaDiarioObra.map((
                                  original,
                                ) {
                                  return _listaDiarioObraTemporaria.firstWhere(
                                    (e) => e.uid == original.uid,
                                    orElse: () => original,
                                  );
                                }).toList();

                                // Adiciona novos criados (UIDs temporários)
                                final novosCriados = _listaDiarioObraTemporaria
                                    .where(
                                      (temp) => temp.uid.startsWith('temp_'),
                                    )
                                    .toList();

                                final todosItens = [
                                  ...itensOriginais,
                                  ...novosCriados,
                                ];

                                // Ordena: Aprovados primeiro, depois Edição
                                todosItens.sort((a, b) {
                                  // 🔥 PRIORIDADE 1: Status de sincronização
                                  // erro (0) -> pendente (1) -> sincronizado (2)
                                  int prioridadeSync(String? s) {
                                    if (s == 'erro') return 0;
                                    if (s == 'pendente') return 1;
                                    return 2; // sincronizado ou null
                                  }

                                  final psA = prioridadeSync(
                                    a.statusSincronizacao,
                                  );
                                  final psB = prioridadeSync(
                                    b.statusSincronizacao,
                                  );

                                  if (psA != psB) return psA.compareTo(psB);

                                  // 🔥 PRIORIDADE 2: Status da obra (Aprovado, Edição, etc)
                                  // Aprovado (1) = 0, Edição (0) = 1, outros = 2
                                  int prioridadeObra(int? status) {
                                    if (status == 1) return 0;
                                    if (status == 0) return 1;
                                    return 2;
                                  }

                                  final poA = prioridadeObra(a.statusObraEnum);
                                  final poB = prioridadeObra(b.statusObraEnum);

                                  if (poA != poB) return poA.compareTo(poB);

                                  // 🔥 PRIORIDADE 3: Número decrescente (mais recente primeiro)
                                  final numA =
                                      int.tryParse(a.numero ?? '') ?? 0;
                                  final numB =
                                      int.tryParse(b.numero ?? '') ?? 0;
                                  return numB.compareTo(numA);
                                });

                                return List.generate(todosItens.length, (
                                  index,
                                ) {
                                  final diario = todosItens[index];
                                  final isEven = index % 2 == 0;
                                  final isTemporario = diario.uid.startsWith(
                                    'temp_',
                                  );

                                  // Formata a data
                                  final dataFormatada =
                                      "${diario.data.day.toString().padLeft(2, '0')}/"
                                      "${diario.data.month.toString().padLeft(2, '0')}/"
                                      "${diario.data.year}";

                                  // Status texto
                                  String statusTexto;
                                  switch (diario.statusObraEnum) {
                                    case 0:
                                      statusTexto = 'Edição';
                                      break;
                                    case 1:
                                      statusTexto = 'Aprovado';
                                      break;
                                    case 2:
                                      statusTexto = 'Validado';
                                      break;
                                    default:
                                      statusTexto = 'Desconhecido';
                                  }

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: () {
                                        // Prioridade 1: Erro de sincronização = vermelho mais escuro
                                        if (diario.statusSincronizacao ==
                                            'erro') {
                                          return Colors.red.shade100;
                                        }
                                        // Prioridade 2: Pendente de sincronização = vermelho claro
                                        if (diario.statusSincronizacao ==
                                            'pendente') {
                                          return Colors.red.shade50;
                                        }
                                        // Sincronizado = cor normal (alternada)
                                        return isEven
                                            ? const Color(0xFFF7F7F7)
                                            : Colors.white;
                                      }(),
                                    ),
                                    children: [
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                diario.numero ?? 'Pendente',
                                                style: TextStyle(
                                                  color: diario.numero == null
                                                      ? Colors.orange
                                                      : Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Boomer',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              dataFormatada,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Boomer',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Center(
                                            child: Text(
                                              statusTexto,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Boomer',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: SizedBox(
                                          width: 85,
                                          height: 55,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Botão PDF
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (diario.numero !=
                                                        "Pendente") {
                                                      _gerarVisualizarPdf(
                                                        diario,
                                                      );
                                                    } else {
                                                      _showSnackBarWithRetry(
                                                        SnackBar(
                                                          content: Text(
                                                            'Não é possível gerar o PDF para um diário pendente.',
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                seconds: 4,
                                                              ),
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: const Tooltip(
                                                    message: 'Gerar PDF',
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        4,
                                                      ),
                                                      child: Icon(
                                                        Icons.picture_as_pdf,
                                                        size: 18,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Botão Editar (só para status Edição)
                                              if (diario.statusObraEnum == 0)
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (isTemporario) {
                                                        // Diário temporário criado
                                                        _mostrarModalDiarioObra(
                                                          uidTemporario:
                                                              diario.uid,
                                                          usuario: _user,
                                                          numero:
                                                              diario.numero!,
                                                          data: diario.data,
                                                          periodoTrabalhadoManhaEnum:
                                                              diario
                                                                  .periodoTrabalhadoManhaEnum,
                                                          periodoTrabalhadoTardeEnum:
                                                              diario
                                                                  .periodoTrabalhadoTardeEnum,
                                                          periodoTrabalhadoNoiteEnum:
                                                              diario
                                                                  .periodoTrabalhadoNoiteEnum,
                                                          condicoesMeteorologicasManhaEnum:
                                                              diario
                                                                  .condicoesMeteorologicasManhaEnum,
                                                          condicoesMeteorologicasTardeEnum:
                                                              diario
                                                                  .condicoesMeteorologicasTardeEnum,
                                                          condicoesMeteorologicasNoiteEnum:
                                                              diario
                                                                  .condicoesMeteorologicasNoiteEnum,
                                                          statusObraEnum: diario
                                                              .statusObraEnum,
                                                          observacoesPeriodoTrabalhado:
                                                              diario
                                                                  .observacoesPeriodoTrabalhado,
                                                          observacoesCondicoesMeteorologicas:
                                                              diario
                                                                  .observacoesCondicoesMeteorologicas,
                                                          apenaVisualizacao:
                                                              false,
                                                          modoCriacao: false,
                                                          onSalvar: (diarioAtualizado) {
                                                            _salvarDiarioObraTemporario(
                                                              diarioAtualizado,
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        // Diário existente no banco
                                                        final database = context
                                                            .read<
                                                              AppDatabase
                                                            >();
                                                        final diarioCompleto =
                                                            await (database.select(
                                                                  database
                                                                      .diarioObra,
                                                                )..where(
                                                                  (tbl) => tbl
                                                                      .uid
                                                                      .equals(
                                                                        diario
                                                                            .uid,
                                                                      ),
                                                                ))
                                                                .getSingleOrNull();

                                                        if (diarioCompleto !=
                                                            null) {
                                                          final displayed =
                                                              _listaDiarioObraTemporaria
                                                                  .firstWhere(
                                                                    (e) =>
                                                                        e.uid ==
                                                                        diario
                                                                            .uid,
                                                                    orElse: () =>
                                                                        diario,
                                                                  );

                                                          _mostrarModalDiarioObra(
                                                            diarioObra:
                                                                diarioCompleto,
                                                            usuario: _user,
                                                            numero: displayed
                                                                .numero!,
                                                            data:
                                                                displayed.data,
                                                            periodoTrabalhadoManhaEnum:
                                                                displayed
                                                                    .periodoTrabalhadoManhaEnum,
                                                            periodoTrabalhadoTardeEnum:
                                                                displayed
                                                                    .periodoTrabalhadoTardeEnum,
                                                            periodoTrabalhadoNoiteEnum:
                                                                displayed
                                                                    .periodoTrabalhadoNoiteEnum,
                                                            condicoesMeteorologicasManhaEnum:
                                                                displayed
                                                                    .condicoesMeteorologicasManhaEnum,
                                                            condicoesMeteorologicasTardeEnum:
                                                                displayed
                                                                    .condicoesMeteorologicasTardeEnum,
                                                            condicoesMeteorologicasNoiteEnum:
                                                                displayed
                                                                    .condicoesMeteorologicasNoiteEnum,
                                                            statusObraEnum:
                                                                displayed
                                                                    .statusObraEnum,
                                                            observacoesPeriodoTrabalhado:
                                                                displayed
                                                                    .observacoesPeriodoTrabalhado,
                                                            observacoesCondicoesMeteorologicas:
                                                                displayed
                                                                    .observacoesCondicoesMeteorologicas,
                                                            apenaVisualizacao:
                                                                false,
                                                            onSalvar: (diarioAtualizado) {
                                                              _salvarDiarioObraTemporario(
                                                                diarioAtualizado,
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    child: const Tooltip(
                                                      message: 'Editar',
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          2,
                                                        ),
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 18,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              // Botão Visualizar
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (isTemporario) {
                                                      // Diário temporário - não existe no banco
                                                      _mostrarModalDiarioObra(
                                                        uidTemporario:
                                                            diario.uid,
                                                        usuario: _user,
                                                        numero: diario.numero!,
                                                        data: diario.data,
                                                        periodoTrabalhadoManhaEnum:
                                                            diario
                                                                .periodoTrabalhadoManhaEnum,
                                                        periodoTrabalhadoTardeEnum:
                                                            diario
                                                                .periodoTrabalhadoTardeEnum,
                                                        periodoTrabalhadoNoiteEnum:
                                                            diario
                                                                .periodoTrabalhadoNoiteEnum,
                                                        condicoesMeteorologicasManhaEnum:
                                                            diario
                                                                .condicoesMeteorologicasManhaEnum,
                                                        condicoesMeteorologicasTardeEnum:
                                                            diario
                                                                .condicoesMeteorologicasTardeEnum,
                                                        condicoesMeteorologicasNoiteEnum:
                                                            diario
                                                                .condicoesMeteorologicasNoiteEnum,
                                                        statusObraEnum: diario
                                                            .statusObraEnum,
                                                        observacoesPeriodoTrabalhado:
                                                            diario
                                                                .observacoesPeriodoTrabalhado,
                                                        observacoesCondicoesMeteorologicas:
                                                            diario
                                                                .observacoesCondicoesMeteorologicas,
                                                        apenaVisualizacao: true,
                                                        modoCriacao: false,
                                                      );
                                                    } else {
                                                      // Diário existente no banco - busca DiarioObraData completo
                                                      final database = context
                                                          .read<AppDatabase>();
                                                      final diarioCompleto =
                                                          await (database.select(
                                                                database
                                                                    .diarioObra,
                                                              )..where(
                                                                (tbl) => tbl.uid
                                                                    .equals(
                                                                      diario
                                                                          .uid,
                                                                    ),
                                                              ))
                                                              .getSingleOrNull();

                                                      if (diarioCompleto !=
                                                          null) {
                                                        _mostrarModalDiarioObra(
                                                          diarioObra:
                                                              diarioCompleto,
                                                          usuario: _user,
                                                          numero:
                                                              diario.numero!,
                                                          data: diario.data,
                                                          periodoTrabalhadoManhaEnum:
                                                              diario
                                                                  .periodoTrabalhadoManhaEnum,
                                                          periodoTrabalhadoTardeEnum:
                                                              diario
                                                                  .periodoTrabalhadoTardeEnum,
                                                          periodoTrabalhadoNoiteEnum:
                                                              diario
                                                                  .periodoTrabalhadoNoiteEnum,
                                                          condicoesMeteorologicasManhaEnum:
                                                              diario
                                                                  .condicoesMeteorologicasManhaEnum,
                                                          condicoesMeteorologicasTardeEnum:
                                                              diario
                                                                  .condicoesMeteorologicasTardeEnum,
                                                          condicoesMeteorologicasNoiteEnum:
                                                              diario
                                                                  .condicoesMeteorologicasNoiteEnum,
                                                          statusObraEnum: diario
                                                              .statusObraEnum,
                                                          observacoesPeriodoTrabalhado:
                                                              diario
                                                                  .observacoesPeriodoTrabalhado,
                                                          observacoesCondicoesMeteorologicas:
                                                              diario
                                                                  .observacoesCondicoesMeteorologicas,
                                                          apenaVisualizacao:
                                                              true,
                                                        );
                                                      }
                                                    }
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: const Tooltip(
                                                    message: 'Visualizar',
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        4,
                                                      ),
                                                      child: Icon(
                                                        Icons.search,
                                                        size: 18,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      SecaoComBotao(
                        titulo: "Subcontratada",
                        textoBotao: "Vincular",
                        onPressed: () {
                          _vincularNovaSubcontratada();
                        },
                        visivel: contratadoEscolhido != null,
                      ),
                      // Tabela: Subcontratada
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFDFDF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.40),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3.0),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(3),
                            3: FixedColumnWidth(75),
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFFDFDFDF),
                              ),
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: _HeaderCell('Abreviação'),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: _HeaderCell('Contato Principal'),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: _HeaderCell('Nome Empresa'),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: _HeaderCell('Detalhes'),
                                ),
                              ],
                            ),
                            if (contratadoEscolhido != null)
                              ...() {
                                // Combina itens originais com novos vinculados
                                final itensOriginais =
                                    _listaDiarioObraConsultarSubcontratada
                                        .where(
                                          (original) =>
                                              !_subcontratadaRemovidasUids
                                                  .contains(original.uid),
                                        )
                                        .map((original) {
                                          // Prioriza versão editada se existir
                                          return _listaSubcontratadaTemporaria
                                              .firstWhere(
                                                (e) => e.uid == original.uid,
                                                orElse: () =>
                                                    SubcontratadaComNome(
                                                      uid: original.uid,
                                                      abreviacao:
                                                          original.abreviacao,
                                                      nomeEmpresa:
                                                          original.nomeEmpresa,
                                                      contatoPrincipal: original
                                                          .contatoPrincipal,
                                                      dataHoraInclusao: original
                                                          .dataHoraInclusao,
                                                    ),
                                              );
                                        })
                                        .toList();

                                // Adiciona novos vinculados (UIDs temporários)
                                final novosVinculados =
                                    _listaSubcontratadaTemporaria
                                        .where(
                                          (temp) =>
                                              temp.uid.startsWith('temp_'),
                                        )
                                        .toList();

                                final todosItens = [
                                  ...itensOriginais,
                                  ...novosVinculados,
                                ];

                                return List.generate(todosItens.length, (
                                  index,
                                ) {
                                  final item = todosItens[index];
                                  final isEven = index % 2 == 0;
                                  final isTemporario = item.uid.startsWith(
                                    'temp_',
                                  );

                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isEven
                                          ? const Color(0xFFF7F7F7)
                                          : Colors.white,
                                    ),
                                    children: [
                                      _BodyCell(item.abreviacao),
                                      _BodyCell(item.contatoPrincipal),
                                      _BodyCell(item.nomeEmpresa),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: SizedBox(
                                          width: 85,
                                          height: 55,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Botão Remover
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                              ),
                                                          title: const Text(
                                                            'Confirmar Remoção',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Boomer',
                                                            ),
                                                          ),
                                                          content: Text(
                                                            'Deseja remover "${item.nomeEmpresa}"?\n\nA remoção será temporária até salvar definitivamente.',
                                                            style:
                                                                const TextStyle(
                                                                  fontFamily:
                                                                      'Boomer',
                                                                ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              style: TextButton.styleFrom(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(),
                                                              child: const Text(
                                                                'Cancelar',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Boomer',
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                if (isTemporario) {
                                                                  // Remove diretamente da lista temporária
                                                                  setState(() {
                                                                    _listaSubcontratadaTemporaria.removeWhere(
                                                                      (e) =>
                                                                          e.uid ==
                                                                          item.uid,
                                                                    );
                                                                  });
                                                                } else {
                                                                  _removerSubcontratadaTemporaria(
                                                                    item.uid,
                                                                  );
                                                                }
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                              child: const Text(
                                                                'Remover',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Boomer',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: const Tooltip(
                                                    message: 'Remover',
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        2,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Botão Editar
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    _mostrarModalSubcontratada(
                                                      subcontratada:
                                                          isTemporario
                                                          ? null
                                                          : _listaDiarioObraConsultarSubcontratada
                                                                .firstWhere(
                                                                  (e) =>
                                                                      e.uid ==
                                                                      item.uid,
                                                                ),
                                                      uidTemporario:
                                                          isTemporario
                                                          ? item.uid
                                                          : null,
                                                      abreviacao:
                                                          item.abreviacao,
                                                      nomeEmpresa:
                                                          item.nomeEmpresa,
                                                      contatoPrincipal:
                                                          item.contatoPrincipal,
                                                      apenaVisualizacao: false,
                                                      modoVinculacao:
                                                          isTemporario,
                                                      onSalvar: (subcontratadaAtualizada) {
                                                        _salvarSubcontratadaTemporaria(
                                                          subcontratadaAtualizada,
                                                        );
                                                      },
                                                    );
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: const Tooltip(
                                                    message: 'Editar',
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        2,
                                                      ),
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Botão Visualizar
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    _mostrarModalSubcontratada(
                                                      subcontratada:
                                                          isTemporario
                                                          ? null
                                                          : _listaDiarioObraConsultarSubcontratada
                                                                .firstWhere(
                                                                  (e) =>
                                                                      e.uid ==
                                                                      item.uid,
                                                                ),
                                                      abreviacao:
                                                          item.abreviacao,
                                                      nomeEmpresa:
                                                          item.nomeEmpresa,
                                                      contatoPrincipal:
                                                          item.contatoPrincipal,
                                                      apenaVisualizacao: true,
                                                      onSalvar: null,
                                                    );
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: const Tooltip(
                                                    message: 'Visualizar',
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        2,
                                                      ),
                                                      child: Icon(
                                                        Icons.search,
                                                        size: 18,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      SecaoComBotao(
                        titulo: "Equipamento",
                        textoBotao: "Vincular",
                        onPressed: () {
                          _vincularNovoEquipamento();
                        },
                        visivel: contratadoEscolhido != null,
                      ),
                      // Tabela: Equipamento
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFDFDF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.40),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3.0),
                        child: Table(
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFFDFDFDF),
                              ),
                              children: [
                                _HeaderCell('Equipamento'),
                                _HeaderCell('Detalhes'),
                              ],
                            ),
                            ...() {
                              final itensOriginais =
                                  _listaDiarioObraConsultarEquipamento.map((
                                    original,
                                  ) {
                                    return _equipamentosTemporarios.firstWhere(
                                      (e) => e.uid == original.uid,
                                      orElse: () => EquipamentoComNome(
                                        uid: original.uid,
                                        nomeEquipamento:
                                            original.nomeEquipamento,
                                        status: original.status,
                                        equipamentoUid: original.equipamentoUid,
                                        dataHoraInclusao:
                                            original.dataHoraInclusao,
                                      ),
                                    );
                                  }).toList();

                              final novosVinculados = _equipamentosTemporarios
                                  .where((temp) => temp.uid.startsWith('temp_'))
                                  .toList();

                              final todosItens = [
                                ...itensOriginais,
                                ...novosVinculados,
                              ];

                              return List.generate(todosItens.length, (index) {
                                final item = todosItens[index];
                                final isEven = index % 2 == 0;
                                final isTemporario = item.uid.startsWith(
                                  'temp_',
                                );

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: isEven
                                        ? const Color(0xFFF7F7F7)
                                        : Colors.white,
                                  ),
                                  children: [
                                    _BodyCell(item.nomeEquipamento),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 55,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Botão Editar
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  if (isTemporario) {
                                                    // É um equipamento novo (temporário), então não existe no banco
                                                    _mostrarModalEquipamento(
                                                      equipamento: null,
                                                      uidTemporario: item.uid,
                                                      nomeEquipamento:
                                                          item.nomeEquipamento,
                                                      status: item.status,
                                                      apenaVisualizacao: false,
                                                      modoVinculacao: true,
                                                      onSalvar: (equipamentoAtualizado) {
                                                        _salvarEquipamentoTemporario(
                                                          equipamentoAtualizado,
                                                        );
                                                        setState(() {
                                                          final idx =
                                                              _listaDiarioObraConsultarEquipamento
                                                                  .indexWhere(
                                                                    (e) =>
                                                                        e.uid ==
                                                                        equipamentoAtualizado
                                                                            .uid,
                                                                  );
                                                          if (idx != -1) {
                                                            _listaDiarioObraConsultarEquipamento[idx] = EquipamentoComNome(
                                                              uid:
                                                                  _listaDiarioObraConsultarEquipamento[idx]
                                                                      .uid,
                                                              nomeEquipamento:
                                                                  equipamentoAtualizado
                                                                      .nomeEquipamento,
                                                              status:
                                                                  equipamentoAtualizado
                                                                      .status,
                                                              equipamentoUid:
                                                                  _listaDiarioObraConsultarEquipamento[idx]
                                                                      .equipamentoUid,
                                                              dataHoraInclusao:
                                                                  equipamentoAtualizado
                                                                      .dataHoraInclusao,
                                                            );
                                                          }
                                                        });
                                                      },
                                                    );
                                                  } else {
                                                    // Equipamento existente no banco
                                                    final database = context
                                                        .read<AppDatabase>();
                                                    final equipamentoCompleto =
                                                        await (database.select(
                                                              database
                                                                  .diarioObraConsultarEquipamento,
                                                            )..where(
                                                              (tbl) => tbl.uid
                                                                  .equals(
                                                                    item.uid,
                                                                  ),
                                                            ))
                                                            .getSingleOrNull();

                                                    if (equipamentoCompleto !=
                                                        null) {
                                                      final displayed =
                                                          _equipamentosTemporarios
                                                              .firstWhere(
                                                                (e) =>
                                                                    e.uid ==
                                                                    item.uid,
                                                                orElse: () =>
                                                                    item,
                                                              );

                                                      _mostrarModalEquipamento(
                                                        equipamento:
                                                            equipamentoCompleto,
                                                        nomeEquipamento:
                                                            displayed
                                                                .nomeEquipamento,
                                                        status:
                                                            displayed.status,
                                                        apenaVisualizacao:
                                                            false,
                                                        modoVinculacao: false,
                                                        onSalvar: (equipamentoAtualizado) {
                                                          _salvarEquipamentoTemporario(
                                                            equipamentoAtualizado,
                                                          );
                                                          setState(() {
                                                            final idx = _listaDiarioObraConsultarEquipamento
                                                                .indexWhere(
                                                                  (e) =>
                                                                      e.uid ==
                                                                      equipamentoAtualizado
                                                                          .uid,
                                                                );
                                                            if (idx != -1) {
                                                              _listaDiarioObraConsultarEquipamento[idx] = EquipamentoComNome(
                                                                uid:
                                                                    _listaDiarioObraConsultarEquipamento[idx]
                                                                        .uid,
                                                                nomeEquipamento:
                                                                    equipamentoAtualizado
                                                                        .nomeEquipamento,
                                                                status:
                                                                    equipamentoAtualizado
                                                                        .status,
                                                                equipamentoUid:
                                                                    _listaDiarioObraConsultarEquipamento[idx]
                                                                        .equipamentoUid,
                                                                dataHoraInclusao:
                                                                    equipamentoAtualizado
                                                                        .dataHoraInclusao,
                                                              );
                                                            }
                                                          });
                                                        },
                                                      );
                                                    }
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: const Tooltip(
                                                  message: 'Editar',
                                                  child: Padding(
                                                    padding: EdgeInsets.all(2),
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 18,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            // Botão Visualizar
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  if (isTemporario) {
                                                    _mostrarModalEquipamento(
                                                      equipamento: null,
                                                      uidTemporario: item.uid,
                                                      nomeEquipamento:
                                                          item.nomeEquipamento,
                                                      status: item.status,
                                                      apenaVisualizacao: true,
                                                      modoVinculacao: true,
                                                      onSalvar: null,
                                                    );
                                                  } else {
                                                    final database = context
                                                        .read<AppDatabase>();
                                                    final equipamentoCompleto =
                                                        await (database.select(
                                                              database
                                                                  .diarioObraConsultarEquipamento,
                                                            )..where(
                                                              (tbl) => tbl.uid
                                                                  .equals(
                                                                    item.uid,
                                                                  ),
                                                            ))
                                                            .getSingleOrNull();

                                                    if (equipamentoCompleto !=
                                                        null) {
                                                      final displayed =
                                                          _equipamentosTemporarios
                                                              .firstWhere(
                                                                (e) =>
                                                                    e.uid ==
                                                                    item.uid,
                                                                orElse: () =>
                                                                    item,
                                                              );

                                                      _mostrarModalEquipamento(
                                                        equipamento:
                                                            equipamentoCompleto,
                                                        nomeEquipamento:
                                                            displayed
                                                                .nomeEquipamento,
                                                        status:
                                                            displayed.status,
                                                        apenaVisualizacao: true,
                                                        modoVinculacao: false,
                                                        onSalvar: null,
                                                      );
                                                    }
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: const Tooltip(
                                                  message: 'Visualizar',
                                                  child: Padding(
                                                    padding: EdgeInsets.all(2),
                                                    child: Icon(
                                                      Icons.search,
                                                      size: 18,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                            }(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      SecaoComBotao(
                        titulo: "Mão de Obra",
                        textoBotao: "Vincular",
                        onPressed: () {
                          _vincularNovaMaoDeObra();
                        },
                        visivel: contratadoEscolhido != null,
                      ),
                      // Tabela: Mao de Obra
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFDFDF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.40),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3.0),
                        child: Table(
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFFDFDFDF),
                              ),
                              children: [
                                _HeaderCell('Mão de Obra'),
                                _HeaderCell('Detalhes'),
                              ],
                            ),
                            ...(() {
                              final itensOriginais =
                                  _listaDiarioObraConsultarMaoDeObra.map((
                                    original,
                                  ) {
                                    return _listaMaoDeObraTemporaria.firstWhere(
                                      (e) => e.uid == original.uid,
                                      orElse: () => MaoDeObraComNome(
                                        uid: original.uid,
                                        descricao: original.descricao,
                                        status: original.status,
                                        statusTipoMaoDeObraEnum:
                                            original.statusTipoMaoDeObraEnum,
                                        maoDeObraUid: original.maoDeObraUid,
                                        dataHoraInclusao:
                                            original.dataHoraInclusao,
                                      ),
                                    );
                                  }).toList();

                              final novosVinculados = _listaMaoDeObraTemporaria
                                  .where((temp) => temp.uid.startsWith('temp_'))
                                  .toList();

                              final todosItens = [
                                ...itensOriginais,
                                ...novosVinculados,
                              ];
                              return List.generate(todosItens.length, (index) {
                                final item = todosItens[index];
                                final isEven = index % 2 == 0;
                                final isTemporario = item.uid.startsWith(
                                  'temp_',
                                );

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: isEven
                                        ? const Color(0xFFF7F7F7)
                                        : Colors.white,
                                  ),
                                  children: [
                                    _BodyCell(item.descricao),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                if (isTemporario) {
                                                  _mostrarModalMaoDeObra(
                                                    maoDeObra: null,
                                                    uidTemporario: item.uid,
                                                    descricao: item.descricao,
                                                    status: item.status,
                                                    modoVinculacao: true,
                                                    apenaVisualizacao: false,
                                                    statusTipoMaoDeObraEnum: item
                                                        .statusTipoMaoDeObraEnum,
                                                    onSalvar: (maoDeObraAtualizada) {
                                                      _salvarMaoDeObraTemporaria(
                                                        maoDeObraAtualizada,
                                                      );
                                                      setState(() {
                                                        final idx =
                                                            _listaDiarioObraConsultarMaoDeObra
                                                                .indexWhere(
                                                                  (e) =>
                                                                      e.uid ==
                                                                      maoDeObraAtualizada
                                                                          .uid,
                                                                );

                                                        if (idx != -1) {
                                                          _listaDiarioObraConsultarMaoDeObra[idx] = MaoDeObraComNome(
                                                            uid:
                                                                _listaDiarioObraConsultarMaoDeObra[idx]
                                                                    .uid,
                                                            descricao:
                                                                maoDeObraAtualizada
                                                                    .descricao,
                                                            status:
                                                                maoDeObraAtualizada
                                                                    .status,
                                                            statusTipoMaoDeObraEnum:
                                                                maoDeObraAtualizada
                                                                    .statusTipoMaoDeObraEnum,
                                                            maoDeObraUid:
                                                                _listaDiarioObraConsultarMaoDeObra[idx]
                                                                    .maoDeObraUid,
                                                            dataHoraInclusao:
                                                                maoDeObraAtualizada
                                                                    .dataHoraInclusao,
                                                          );
                                                        }
                                                      });
                                                    },
                                                  );
                                                } else {
                                                  final database = context
                                                      .read<AppDatabase>();
                                                  final maoDeObraCompleta =
                                                      await (database.select(
                                                            database
                                                                .diarioObraConsultarMaoDeObra,
                                                          )..where(
                                                            (tbl) =>
                                                                tbl.uid.equals(
                                                                  item.uid,
                                                                ),
                                                          ))
                                                          .getSingleOrNull();

                                                  if (maoDeObraCompleta !=
                                                      null) {
                                                    final displayed =
                                                        _listaMaoDeObraTemporaria
                                                            .firstWhere(
                                                              (e) =>
                                                                  e.uid ==
                                                                  item.uid,
                                                              orElse: () =>
                                                                  item,
                                                            );

                                                    _mostrarModalMaoDeObra(
                                                      maoDeObra:
                                                          maoDeObraCompleta,
                                                      descricao:
                                                          displayed.descricao,
                                                      status: displayed.status,
                                                      apenaVisualizacao: false,
                                                      modoVinculacao: false,
                                                      statusTipoMaoDeObraEnum:
                                                          displayed
                                                              .statusTipoMaoDeObraEnum,
                                                      onSalvar: (maoDeObraAtualizada) {
                                                        _salvarMaoDeObraTemporaria(
                                                          maoDeObraAtualizada,
                                                        );
                                                        setState(() {
                                                          final idx =
                                                              _listaDiarioObraConsultarMaoDeObra
                                                                  .indexWhere(
                                                                    (e) =>
                                                                        e.uid ==
                                                                        maoDeObraAtualizada
                                                                            .uid,
                                                                  );

                                                          if (idx != -1) {
                                                            _listaDiarioObraConsultarMaoDeObra[idx] = MaoDeObraComNome(
                                                              uid:
                                                                  _listaDiarioObraConsultarMaoDeObra[idx]
                                                                      .uid,
                                                              descricao:
                                                                  maoDeObraAtualizada
                                                                      .descricao,
                                                              status:
                                                                  maoDeObraAtualizada
                                                                      .status,
                                                              statusTipoMaoDeObraEnum:
                                                                  maoDeObraAtualizada
                                                                      .statusTipoMaoDeObraEnum,
                                                              maoDeObraUid:
                                                                  _listaDiarioObraConsultarMaoDeObra[idx]
                                                                      .maoDeObraUid,
                                                              dataHoraInclusao:
                                                                  maoDeObraAtualizada
                                                                      .dataHoraInclusao,
                                                            );
                                                          }
                                                        });
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                              tooltip: 'Editar',
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                if (isTemporario) {
                                                  _mostrarModalMaoDeObra(
                                                    maoDeObra: null,
                                                    uidTemporario: item.uid,
                                                    descricao: item.descricao,
                                                    status: item.status,
                                                    statusTipoMaoDeObraEnum: item
                                                        .statusTipoMaoDeObraEnum,
                                                    apenaVisualizacao: true,
                                                    modoVinculacao: true,
                                                    onSalvar: null,
                                                  );
                                                } else {
                                                  final database = context
                                                      .read<AppDatabase>();
                                                  final maoDeObraCompleta =
                                                      await (database.select(
                                                            database
                                                                .diarioObraConsultarMaoDeObra,
                                                          )..where(
                                                            (tbl) =>
                                                                tbl.uid.equals(
                                                                  item.uid,
                                                                ),
                                                          ))
                                                          .getSingleOrNull();

                                                  if (maoDeObraCompleta !=
                                                      null) {
                                                    final displayed =
                                                        _listaMaoDeObraTemporaria
                                                            .firstWhere(
                                                              (e) =>
                                                                  e.uid ==
                                                                  item.uid,
                                                              orElse: () =>
                                                                  item,
                                                            );

                                                    _mostrarModalMaoDeObra(
                                                      maoDeObra:
                                                          maoDeObraCompleta,
                                                      descricao:
                                                          displayed.descricao,
                                                      status: displayed.status,
                                                      statusTipoMaoDeObraEnum:
                                                          displayed
                                                              .statusTipoMaoDeObraEnum,
                                                      apenaVisualizacao: true,
                                                      modoVinculacao: false,
                                                      onSalvar: null,
                                                    );
                                                  }
                                                }
                                              },
                                              tooltip: 'Visualizar',
                                              icon: const Icon(
                                                Icons.search,
                                                size: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                            })(),
                          ],
                        ),
                      ),
                      if (_loading)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Image.asset(
                              "assets/images/loading-screen-spinner.gif",
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_carregandoDiarioObra || _sincronizacaoPendente)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/loading-screen-spinner.gif",
                            width: 80,
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _sincronizacaoPendente
                                ? "Sincronizando dados..."
                                : "Carregando diário...",
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Boomer',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        onCancelar: () {
          _resetarListasTemporarias();
          setState(() {
            contratadoController.clear();
            obraController.clear();
            contratadoEscolhido = null;
            obraEscolhida = null;
          });
          if (!mounted) return;
          _showSnackBarWithRetry(
            SnackBar(
              content: Text('Alterações descartadas'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        },
        onSalvar: _salvarDadosTemporarios,
        onEnviarDados: _enviarDadosParaBackend,
      ),
    );
  }
}

class ObraInputAutocomplete extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<ObraData> obras;
  final void Function(ObraData?) onChanged;

  const ObraInputAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.obras,
    required this.onChanged,
  });

  @override
  State<ObraInputAutocomplete> createState() => _ObraInputAutocompleteState();
}

class _ObraInputAutocompleteState extends State<ObraInputAutocomplete> {
  late TextEditingController _controller;
  ObraData? _selecionado;
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
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<ObraData>> _getSuggestions(String pattern) async {
    if (widget.obras.isEmpty) return [];

    if (_selecionado != null && pattern == _selecionado!.nomeObra) {
      // Retorna a obra selecionada primeiro, depois as outras
      final outrasObras = widget.obras
          .where((obra) => obra.uid != _selecionado!.uid)
          .toList();
      return [_selecionado!, ...outrasObras];
    }

    // Se está digitando, filtra normalmente
    if (pattern.isEmpty) {
      // Se tem obra selecionada, coloca ela primeiro
      if (_selecionado != null) {
        final outrasObras = widget.obras
            .where((obra) => obra.uid != _selecionado!.uid)
            .toList();
        return [_selecionado!, ...outrasObras];
      }
      return widget.obras;
    }

    return widget.obras.where((obra) {
      return obra.nomeObra.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<ObraData>(
          builder: (context, controller, focusNode) {
            _controller = controller; // Mantém referência se precisar fora

            return TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo Obrigatório';
                }
                return null;
              },
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
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
                if (_selecionado != null && _selecionado!.nomeObra != value) {
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
          hideOnEmpty: false,

          suggestionsCallback: (pattern) => _getSuggestions(pattern),

          itemBuilder: (context, ObraData suggestion) {
            final bool isSelected = _selecionado?.uid == suggestion.uid;

            return Container(
              decoration: BoxDecoration(
                border: isSelected && _focusNode.hasFocus
                    ? Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: ListTile(
                title: Text(
                  suggestion.nomeObra,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue, size: 20)
                    : null,
              ),
            );
          },

          onSelected: (ObraData suggestion) {
            _controller.text = suggestion.nomeObra;

            setState(() {
              _selecionado = suggestion;
            });

            widget.onChanged(_selecionado);
          },

          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nenhuma obra encontrada para este projeto"),
          ),
        ),
      ],
    );
  }
}

class CustomInputAutocomplete extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<ObraContratado> contratados;
  final ObraData? obraEscolhida;
  final List<ProjetoEmpresaData> listaProjetoEmpresa;
  final void Function(ProjetoEmpresaData?) onEmpresaChanged;
  final void Function(ObraContratado?) onContratadoSelecionado;

  const CustomInputAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.contratados,
    required this.obraEscolhida,
    required this.listaProjetoEmpresa,
    required this.onEmpresaChanged,
    required this.onContratadoSelecionado,
  });

  @override
  State<CustomInputAutocomplete> createState() =>
      _CustomInputAutocompleteState();
}

class _CustomInputAutocompleteState extends State<CustomInputAutocomplete> {
  late TextEditingController _controller;
  ProjetoEmpresaData? _empresaSelecionada;
  late FocusNode _focusNode;
  bool estaVazio = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(CustomInputAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se a obra mudou, reseta o campo
    if (oldWidget.obraEscolhida?.uid != widget.obraEscolhida?.uid) {
      _controller.clear();
      setState(() {
        _empresaSelecionada = null;
        estaVazio = false;
      });
      widget.onEmpresaChanged(null);
      widget.onContratadoSelecionado(null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<ProjetoEmpresaData>> _getSuggestions(String pattern) async {
    if (widget.obraEscolhida == null) return [];
    if (widget.contratados.isEmpty || widget.listaProjetoEmpresa.isEmpty) {
      return [];
    }

    final obraContratados = widget.contratados.where((contratado) {
      return contratado.obraUid?.toLowerCase() ==
          widget.obraEscolhida!.uid.toLowerCase();
    }).toList();

    final projetoEmpresaUids = obraContratados
        .map((contratado) => contratado.projetoEmpresaUid?.toLowerCase())
        .where((uid) => uid != null)
        .toSet();

    final mostrarTodas =
        _empresaSelecionada != null &&
        pattern == _empresaSelecionada!.nomeFantasia;

    final empresasFiltradas = widget.listaProjetoEmpresa.where((empresa) {
      final correspondeUid = projetoEmpresaUids.contains(
        empresa.uid.toLowerCase(),
      );

      if (mostrarTodas) {
        return correspondeUid;
      }

      final correspondeNome = empresa.nomeFantasia.toLowerCase().contains(
        pattern.toLowerCase(),
      );
      return correspondeUid && correspondeNome;
    }).toList();

    if (_empresaSelecionada != null) {
      final empresaSelecionadaNaLista = empresasFiltradas.any(
        (empresa) => empresa.uid == _empresaSelecionada!.uid,
      );

      if (empresaSelecionadaNaLista) {
        final outrasEmpresas = empresasFiltradas
            .where((empresa) => empresa.uid != _empresaSelecionada!.uid)
            .toList();

        return [_empresaSelecionada!, ...outrasEmpresas];
      }
    }

    return empresasFiltradas;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<ProjetoEmpresaData>(
          suggestionsCallback: (pattern) => _getSuggestions(pattern),
          builder: (context, controller, focusNode) {
            _controller = controller;
            _focusNode = focusNode;

            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
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
                suffixIcon: GestureDetector(
                  onTap: () {
                    if (focusNode.hasFocus) {
                      // Fecha o teclado e as sugestões
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: const Icon(Icons.search, color: Color(0xFF2C2E35)),
                ),
              ),
              onChanged: (valor) {
                if (_empresaSelecionada != null &&
                    _empresaSelecionada!.nomeFantasia != valor) {
                  setState(() {
                    estaVazio = valor.isEmpty;
                    _empresaSelecionada = null;
                    widget.onEmpresaChanged(null);
                    widget.onContratadoSelecionado(null);
                  });
                }
              },
              onEditingComplete: () {
                if (_empresaSelecionada == null) {
                  _controller.clear();
                  widget.onEmpresaChanged(null);
                  widget.onContratadoSelecionado(null);
                }
                _focusNode.unfocus();
              },
            );
          },
          itemBuilder: (context, ProjetoEmpresaData suggestion) {
            final bool isSelected = _empresaSelecionada?.uid == suggestion.uid;

            return ListTile(
              title: Text(
                suggestion.nomeFantasia,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue, size: 20)
                  : null,
            );
          },
          hideOnEmpty: false,
          onSelected: (ProjetoEmpresaData suggestion) {
            _controller.text = suggestion.nomeFantasia;
            setState(() {
              _empresaSelecionada = suggestion;
            });

            widget.onEmpresaChanged(suggestion);

            final contratado = widget.contratados.firstWhere(
              (c) =>
                  c.obraUid?.toLowerCase() ==
                      widget.obraEscolhida?.uid.toLowerCase() &&
                  c.projetoEmpresaUid?.toLowerCase() ==
                      suggestion.uid.toLowerCase(),
              orElse: () => null as ObraContratado,
            );

            widget.onContratadoSelecionado(
              contratado is ObraContratado ? contratado : null,
            );

            FocusScope.of(context).unfocus();
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nenhum contratado encontrado para esta obra"),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF81868D),
          fontSize: 12,
          fontFamily: 'Boomer',
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _BodyCell extends StatelessWidget {
  final String text;
  final double height;
  final bool isActionCell;

  const _BodyCell(
    this.text, {
    this.isActionCell = false,
    this.height = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: isActionCell ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Boomer',
        ),
        textAlign: isActionCell ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
