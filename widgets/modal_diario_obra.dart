import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotus_mobile/database/database.dart';
import 'package:lotus_mobile/pages/home_page.dart';
import 'package:lotus_mobile/services/image_service.dart';
import 'package:lotus_mobile/widgets/modal_subcontratada.dart';
import 'package:lotus_mobile/widgets/status_switch_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Classe para armazenar um apontamento individual na matriz
class ApontamentoItem {
  final String maoDeObraOuEquipamentoUid;
  final String subcontratadaUid;
  double valor;

  ApontamentoItem({
    required this.maoDeObraOuEquipamentoUid,
    required this.subcontratadaUid,
    required this.valor,
  });

  String get key => '${maoDeObraOuEquipamentoUid}_$subcontratadaUid';
}

enum TipoApontamento { maoDeObra, equipamento }

class ItemApontamento {
  final String uid;
  final String descricao;
  final int? statusTipoMaoDeObraEnum;
  final TipoApontamento tipo;

  ItemApontamento({
    required this.uid,
    required this.descricao,
    this.statusTipoMaoDeObraEnum,
    required this.tipo,
  });
}

class SubcontratadaInfo {
  final String uid;
  final String abreviacao;

  SubcontratadaInfo({required this.uid, required this.abreviacao});
}

// Classes de dados temporários
class DiarioObraComDados {
  final String uid;
  final String? usuarioResponsavelUid;
  final String? numero;
  final DateTime data;
  final int? sequencial;
  final bool? aprovadoContratada;
  final bool? assinadoContratada;
  final bool? assinadoContratante;
  final String dataHoraInclusao;
  final int statusObraEnum;
  final int periodoTrabalhadoManhaEnum;
  final int periodoTrabalhadoTardeEnum;
  final int periodoTrabalhadoNoiteEnum;
  final int condicoesMeteorologicasManhaEnum;
  final int condicoesMeteorologicasTardeEnum;
  final int condicoesMeteorologicasNoiteEnum;
  final String? observacoesPeriodoTrabalhado;
  final String? observacoesCondicoesMeteorologicas;
  final List<EvolucaoServicoComDados> evolucoes;
  final List<AnotacaoGerenciadoraComDados> anotacoesGerenciadora;
  final List<AnotacaoContratadaComDados> anotacoesContratada;
  final List<AnexoComDados> anexos;
  final Map<String, int> apontamentos;
  final String statusSincronizacao;
  final String? erroSincronizacao;

  DiarioObraComDados({
    required this.uid,
    this.usuarioResponsavelUid,
    required this.numero,
    required this.data,
    this.sequencial,
    this.aprovadoContratada,
    this.assinadoContratada,
    this.assinadoContratante,
    required this.dataHoraInclusao,
    required this.statusObraEnum,
    required this.periodoTrabalhadoManhaEnum,
    required this.periodoTrabalhadoTardeEnum,
    required this.periodoTrabalhadoNoiteEnum,
    required this.condicoesMeteorologicasManhaEnum,
    required this.condicoesMeteorologicasTardeEnum,
    required this.condicoesMeteorologicasNoiteEnum,
    this.observacoesPeriodoTrabalhado,
    this.observacoesCondicoesMeteorologicas,
    List<EvolucaoServicoComDados>? evolucoes,
    List<AnotacaoGerenciadoraComDados>? anotacoesGerenciadora,
    List<AnotacaoContratadaComDados>? anotacoesContratada,
    List<AnexoComDados>? anexos,
    Map<String, int>? apontamentos,
    required this.statusSincronizacao,
    this.erroSincronizacao,
  }) : evolucoes = evolucoes ?? [],
       anotacoesGerenciadora = anotacoesGerenciadora ?? [],
       anotacoesContratada = anotacoesContratada ?? [],
       anexos = anexos ?? [],
       apontamentos = apontamentos ?? {};

  DiarioObraComDados copyWith({
    String? uid,
    String? usuarioResponsavelUid,
    String? numero,
    DateTime? data,
    int? sequencial,
    bool? aprovadoContratada,
    bool? assinadoContratada,
    bool? assinadoContratante,
    String? dataHoraInclusao,
    int? statusObraEnum,
    int? periodoTrabalhadoManhaEnum,
    int? periodoTrabalhadoTardeEnum,
    int? periodoTrabalhadoNoiteEnum,
    int? condicoesMeteorologicasManhaEnum,
    int? condicoesMeteorologicasTardeEnum,
    int? condicoesMeteorologicasNoiteEnum,
    String? observacoesPeriodoTrabalhado,
    String? observacoesCondicoesMeteorologicas,
    List<EvolucaoServicoComDados>? evolucoes,
    List<AnotacaoGerenciadoraComDados>? anotacoesGerenciadora,
    List<AnotacaoContratadaComDados>? anotacoesContratada,
    List<AnexoComDados>? anexos,
    Map<String, int>? apontamentos,
    String? statusSincronizacao,
    String? erroSincronizacao,
  }) {
    return DiarioObraComDados(
      uid: uid ?? this.uid,
      usuarioResponsavelUid:
          usuarioResponsavelUid ?? this.usuarioResponsavelUid,
      numero: numero ?? this.numero,
      data: data ?? this.data,
      sequencial: sequencial ?? this.sequencial,
      aprovadoContratada: aprovadoContratada ?? this.aprovadoContratada,
      assinadoContratada: assinadoContratada ?? this.assinadoContratada,
      assinadoContratante: assinadoContratante ?? this.assinadoContratante,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
      statusObraEnum: statusObraEnum ?? this.statusObraEnum,
      periodoTrabalhadoManhaEnum:
          periodoTrabalhadoManhaEnum ?? this.periodoTrabalhadoManhaEnum,
      periodoTrabalhadoTardeEnum:
          periodoTrabalhadoTardeEnum ?? this.periodoTrabalhadoTardeEnum,
      periodoTrabalhadoNoiteEnum:
          periodoTrabalhadoNoiteEnum ?? this.periodoTrabalhadoNoiteEnum,
      condicoesMeteorologicasManhaEnum:
          condicoesMeteorologicasManhaEnum ??
          this.condicoesMeteorologicasManhaEnum,
      condicoesMeteorologicasTardeEnum:
          condicoesMeteorologicasTardeEnum ??
          this.condicoesMeteorologicasTardeEnum,
      condicoesMeteorologicasNoiteEnum:
          condicoesMeteorologicasNoiteEnum ??
          this.condicoesMeteorologicasNoiteEnum,
      observacoesPeriodoTrabalhado:
          observacoesPeriodoTrabalhado ?? this.observacoesPeriodoTrabalhado,
      observacoesCondicoesMeteorologicas:
          observacoesCondicoesMeteorologicas ??
          this.observacoesCondicoesMeteorologicas,
      evolucoes: evolucoes ?? this.evolucoes,
      anotacoesGerenciadora:
          anotacoesGerenciadora ?? this.anotacoesGerenciadora,
      anotacoesContratada: anotacoesContratada ?? this.anotacoesContratada,
      anexos: anexos ?? this.anexos,
      apontamentos: apontamentos ?? this.apontamentos,
      statusSincronizacao: statusSincronizacao ?? this.statusSincronizacao,
      erroSincronizacao: erroSincronizacao ?? this.erroSincronizacao,
    );
  }
}

class EvolucaoServicoComDados {
  final String uid;
  final String numero;
  final String evolucao;
  final String dataHoraInclusao;
  final int? sequencial;

  EvolucaoServicoComDados({
    required this.uid,
    required this.numero,
    required this.evolucao,
    required this.dataHoraInclusao,
    this.sequencial,
  });

  EvolucaoServicoComDados copyWith({
    String? uid,
    String? numero,
    String? evolucao,
    String? dataHoraInclusao,
    int? sequencial,
  }) {
    return EvolucaoServicoComDados(
      uid: uid ?? this.uid,
      numero: numero ?? this.numero,
      evolucao: evolucao ?? this.evolucao,
      sequencial: sequencial ?? this.sequencial,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class AnotacaoGerenciadoraComDados {
  final String uid;
  final DateTime data;
  final String anotacao;
  final String dataHoraInclusao;

  AnotacaoGerenciadoraComDados({
    required this.uid,
    required this.data,
    required this.anotacao,
    required this.dataHoraInclusao,
  });

  AnotacaoGerenciadoraComDados copyWith({
    String? uid,
    DateTime? data,
    String? anotacao,
    String? dataHoraInclusao,
  }) {
    return AnotacaoGerenciadoraComDados(
      uid: uid ?? this.uid,
      data: data ?? this.data,
      anotacao: anotacao ?? this.anotacao,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class AnotacaoContratadaComDados {
  final String uid;
  final DateTime data;
  final String anotacao;
  final String dataHoraInclusao;

  AnotacaoContratadaComDados({
    required this.uid,
    required this.data,
    required this.anotacao,
    required this.dataHoraInclusao,
  });

  AnotacaoContratadaComDados copyWith({
    String? uid,
    DateTime? data,
    String? anotacao,
    String? dataHoraInclusao,
  }) {
    return AnotacaoContratadaComDados(
      uid: uid ?? this.uid,
      data: data ?? this.data,
      anotacao: anotacao ?? this.anotacao,
      dataHoraInclusao: dataHoraInclusao ?? this.dataHoraInclusao,
    );
  }
}

class AnexoComDados {
  final String uid;
  final String descricao;
  final String guidControleUpload;
  final bool uploadComplete;

  AnexoComDados({
    required this.uid,
    required this.descricao,
    required this.guidControleUpload,
    required this.uploadComplete,
  });

  AnexoComDados copyWith({
    String? uid,
    String? descricao,
    String? guidControleUpload,
    bool? uploadComplete,
  }) {
    return AnexoComDados(
      uid: uid ?? this.uid,
      descricao: descricao ?? this.descricao,
      guidControleUpload: guidControleUpload ?? this.guidControleUpload,
      uploadComplete: uploadComplete ?? this.uploadComplete,
    );
  }
}

class ApontamentoComDados {
  final String uid;
  final String? maoDeObraUid;
  final String? equipamentoUid;
  final double valorApontamento;
  final String descricao;

  ApontamentoComDados({
    required this.uid,
    this.maoDeObraUid,
    this.equipamentoUid,
    required this.valorApontamento,
    required this.descricao,
  });

  ApontamentoComDados copyWith({
    String? uid,
    String? maoDeObraUid,
    String? equipamentoUid,
    double? valorApontamento,
    String? descricao,
  }) {
    return ApontamentoComDados(
      uid: uid ?? this.uid,
      maoDeObraUid: maoDeObraUid ?? this.maoDeObraUid,
      equipamentoUid: equipamentoUid ?? this.equipamentoUid,
      valorApontamento: valorApontamento ?? this.valorApontamento,
      descricao: descricao ?? this.descricao,
    );
  }
}

// Modal principal
class ModalDiarioObra extends StatefulWidget {
  final DiarioObraData? diarioObra;
  final UsuarioData? usuario;
  final String? uidTemporario;
  final String? numero;
  final DateTime? data;
  final int periodoTrabalhadoManhaEnum;
  final int periodoTrabalhadoTardeEnum;
  final int periodoTrabalhadoNoiteEnum;
  final int condicoesMeteorologicasManhaEnum;
  final int condicoesMeteorologicasTardeEnum;
  final int condicoesMeteorologicasNoiteEnum;
  final int statusObraEnum;
  final String? observacoesPeriodoTrabalhado;
  final String? observacoesCondicoesMeteorologicas;
  final bool apenaVisualizacao;
  final bool modoCriacao;
  final List<EvolucaoServicoComDados>? evolucoesIniciais;
  final List<AnotacaoGerenciadoraComDados>? anotacoesGerenciadoraIniciais;
  final List<AnotacaoContratadaComDados>? anotacoesContratadaIniciais;
  final List<AnexoComDados>? anexosIniciais;
  final Map<String, int>? apontamentosIniciais;
  final Function(DiarioObraComDados)? onSalvar;
  final List<EquipamentoComNome> listaEquipamentos;
  final List<MaoDeObraComNome> listaMaoDeObra;
  final List<DiarioObraConsultarSubcontratadaData> listaSubcontratada;
  final String nomeObra;
  final String nomeContratado;
  final String nomeResponsavel;
  final int pronomeEnum;

  const ModalDiarioObra({
    super.key,
    this.usuario,
    this.diarioObra,
    this.uidTemporario,
    required this.numero,
    this.data,
    this.periodoTrabalhadoManhaEnum = 0,
    this.periodoTrabalhadoTardeEnum = 0,
    this.periodoTrabalhadoNoiteEnum = 0,
    this.condicoesMeteorologicasManhaEnum = 0,
    this.condicoesMeteorologicasTardeEnum = 0,
    this.condicoesMeteorologicasNoiteEnum = 0,
    this.statusObraEnum = 0,
    this.observacoesPeriodoTrabalhado,
    this.observacoesCondicoesMeteorologicas,
    this.apenaVisualizacao = false,
    this.modoCriacao = false,
    this.evolucoesIniciais,
    this.anotacoesGerenciadoraIniciais,
    this.anotacoesContratadaIniciais,
    this.anexosIniciais,
    this.apontamentosIniciais,
    this.onSalvar,
    required this.listaEquipamentos,
    required this.listaMaoDeObra,
    required this.listaSubcontratada,
    required this.nomeObra,
    required this.nomeContratado,
    required this.nomeResponsavel,
    required this.pronomeEnum,
  });

  @override
  State<ModalDiarioObra> createState() => _ModalDiarioObraState();
}

class _ModalDiarioObraState extends State<ModalDiarioObra> {
  late final TextEditingController numeroController;
  late final TextEditingController dataController;
  late final TextEditingController observPeriodoController;
  late final TextEditingController observCondicoesController;

  late int statusSelecionado;

  final List<String> periodos = ['Trabalhado', 'Paralisado', 'Não Útil'];
  final List<String> condicoes = [
    'Bom',
    'Chuvoso Parcial',
    'Chuvoso Total',
    'Chuvoso com Paralisação',
    'Paralisação por Chuva no Dia Anterior',
  ];

  final List<String> pronomes = [
    'Arq.',
    'Dom.',
    'Dr.',
    'Dra.',
    'Eng.',
    'Frei.',
    'Ir.',
    'Irmã.',
    'Pe.',
    'Pref.',
    'Prof.',
    'Sr.',
    'Sra.',
    'Srta.',
    'Tec.',
  ];

  late String periodoManhaSelecionado;
  late String periodoTardeSelecionado;
  late String periodoNoiteSelecionado;

  late String condicaoManhaSelecionado;
  late String condicaoTardeSelecionado;
  late String condicaoNoiteSelecionado;
  late String pronomeTexto;
  late DateTime dataSelecionada;
  String msgError = '';

  // Listas temporárias
  List<EvolucaoServicoComDados> _evolucoesTemporarias = [];
  List<AnotacaoGerenciadoraComDados> _anotacoesGerenciadoraTemporarias = [];
  List<AnotacaoContratadaComDados> _anotacoesContratadaTemporarias = [];
  List<AnexoComDados> _anexosTemporarios = [];
  Map<String, int> _apontamentosMap = {};

  @override
  void initState() {
    super.initState();

    final numeroFormatado = widget.numero != null
        ? int.tryParse(widget.numero ?? '')?.toString().padLeft(5, '0') ??
              widget.numero
        : '';

    numeroController = TextEditingController(
      text: widget.numero ?? 'Aguardando sincronização',
    );
    dataSelecionada = widget.data ?? DateTime.now();
    dataController = TextEditingController(
      text:
          "${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}",
    );
    observPeriodoController = TextEditingController(
      text: widget.observacoesPeriodoTrabalhado ?? '',
    );
    observCondicoesController = TextEditingController(
      text: widget.observacoesCondicoesMeteorologicas ?? '',
    );

    statusSelecionado = widget.statusObraEnum;

    periodoManhaSelecionado = periodos.elementAt(
      widget.periodoTrabalhadoManhaEnum,
    );
    periodoTardeSelecionado = periodos.elementAt(
      widget.periodoTrabalhadoTardeEnum,
    );
    periodoNoiteSelecionado = periodos.elementAt(
      widget.periodoTrabalhadoNoiteEnum,
    );

    condicaoManhaSelecionado = condicoes.elementAt(
      widget.condicoesMeteorologicasManhaEnum,
    );
    condicaoTardeSelecionado = condicoes.elementAt(
      widget.condicoesMeteorologicasTardeEnum,
    );
    condicaoNoiteSelecionado = condicoes.elementAt(
      widget.condicoesMeteorologicasNoiteEnum,
    );

    if (widget.modoCriacao) {
      periodoManhaSelecionado = '';
      periodoTardeSelecionado = '';
      periodoNoiteSelecionado = '';
      condicaoManhaSelecionado = '';
      condicaoTardeSelecionado = '';
      condicaoNoiteSelecionado = '';
    } else {
      periodoManhaSelecionado =
          widget.periodoTrabalhadoManhaEnum >= 0 &&
              widget.periodoTrabalhadoManhaEnum < periodos.length
          ? periodos[widget.periodoTrabalhadoManhaEnum]
          : periodos[0];

      periodoTardeSelecionado =
          widget.periodoTrabalhadoTardeEnum >= 0 &&
              widget.periodoTrabalhadoTardeEnum < periodos.length
          ? periodos[widget.periodoTrabalhadoTardeEnum]
          : periodos[0];

      periodoNoiteSelecionado =
          widget.periodoTrabalhadoNoiteEnum >= 0 &&
              widget.periodoTrabalhadoNoiteEnum < periodos.length
          ? periodos[widget.periodoTrabalhadoNoiteEnum]
          : periodos[0];

      condicaoManhaSelecionado =
          widget.condicoesMeteorologicasManhaEnum >= 0 &&
              widget.condicoesMeteorologicasManhaEnum < condicoes.length
          ? condicoes[widget.condicoesMeteorologicasManhaEnum]
          : periodos[0];

      condicaoTardeSelecionado =
          widget.condicoesMeteorologicasTardeEnum >= 0 &&
              widget.condicoesMeteorologicasTardeEnum < condicoes.length
          ? condicoes[widget.condicoesMeteorologicasTardeEnum]
          : periodos[0];

      condicaoNoiteSelecionado =
          widget.condicoesMeteorologicasNoiteEnum >= 0 &&
              widget.condicoesMeteorologicasNoiteEnum < condicoes.length
          ? condicoes[widget.condicoesMeteorologicasNoiteEnum]
          : periodos[0];
    }

    pronomeTexto = pronomes.elementAt(widget.pronomeEnum);

    final temDadosTemporarios =
        (widget.evolucoesIniciais != null &&
            widget.evolucoesIniciais!.isNotEmpty) ||
        (widget.anotacoesGerenciadoraIniciais != null &&
            widget.anotacoesGerenciadoraIniciais!.isNotEmpty) ||
        (widget.anotacoesContratadaIniciais != null &&
            widget.anotacoesContratadaIniciais!.isNotEmpty) ||
        (widget.anexosIniciais != null && widget.anexosIniciais!.isNotEmpty) ||
        (widget.apontamentosIniciais != null &&
            widget.apontamentosIniciais!.isNotEmpty);

    if (temDadosTemporarios) {
      _evolucoesTemporarias = widget.evolucoesIniciais ?? [];
      _anotacoesGerenciadoraTemporarias =
          widget.anotacoesGerenciadoraIniciais ?? [];
      _anotacoesContratadaTemporarias =
          widget.anotacoesContratadaIniciais ?? [];
      _anexosTemporarios = widget.anexosIniciais ?? [];
      _apontamentosMap = widget.apontamentosIniciais ?? {};
    } else if (widget.diarioObra != null && !widget.modoCriacao) {
      _evolucoesTemporarias = [];
      _anotacoesGerenciadoraTemporarias = [];
      _anotacoesContratadaTemporarias = [];
      _anexosTemporarios = [];
      _apontamentosMap = {};

      _carregarDadosExistentes();
    } else {
      _evolucoesTemporarias = [];
      _anotacoesGerenciadoraTemporarias = [];
      _anotacoesContratadaTemporarias = [];
      _anexosTemporarios = [];
      _apontamentosMap = {};
    }
  }

  Future<void> _carregarDadosExistentes() async {
    if (widget.diarioObra == null) return;

    try {
      final database = context.read<AppDatabase>();
      final diarioUid = widget.diarioObra!.uid;

      final evolucoes = await (database.select(
        database.diarioObraEvolucao,
      )..where((tbl) => tbl.diarioObraUid.equals(diarioUid))).get();

      final evolucoesCarregadas = evolucoes.map((e) {
        return EvolucaoServicoComDados(
          uid: e.uid,
          numero: e.numero.toString(),
          evolucao: e.evolucao,
          dataHoraInclusao: e.dataHoraInclusao,
          sequencial: e.sequencial,
        );
      }).toList();

      final anotacoesGerenciadora = await (database.select(
        database.diarioObraAnotacoesGerenciadora,
      )..where((tbl) => tbl.diarioObraUid.equals(diarioUid))).get();

      final anotacoesGerenciadoraCarregadas = anotacoesGerenciadora.map((a) {
        return AnotacaoGerenciadoraComDados(
          uid: a.uid,
          data: a.data,
          anotacao: a.anotacao,
          dataHoraInclusao: a.dataHoraInclusao,
        );
      }).toList();

      final anotacoesContratada = await (database.select(
        database.diarioObraAnotacoesContratada,
      )..where((tbl) => tbl.diarioObraUid.equals(diarioUid))).get();

      final anotacoesContratadaCarregadas = anotacoesContratada.map((a) {
        return AnotacaoContratadaComDados(
          uid: a.uid,
          data: a.data,
          anotacao: a.anotacao,
          dataHoraInclusao: a.dataHoraInclusao,
        );
      }).toList();

      final anexos = await (database.select(
        database.diarioObraAnexo,
      )..where((tbl) => tbl.diarioObraUid.equals(diarioUid))).get();

      final anexosCarregados = anexos.map((a) {
        return AnexoComDados(
          uid: a.uid,
          descricao: a.descricao,
          guidControleUpload: a.guidControleUpload,
          uploadComplete: a.uploadComplete,
        );
      }).toList();

      await _carregarApontamentosExistentes();

      setState(() {
        _evolucoesTemporarias = evolucoesCarregadas;
        _anotacoesGerenciadoraTemporarias = anotacoesGerenciadoraCarregadas;
        _anotacoesContratadaTemporarias = anotacoesContratadaCarregadas;
        _anexosTemporarios = anexosCarregados;
      });
    } catch (e) {
      print('Erro ao carregar apontamentos: $e');
    }
  }

  Future<void> _carregarApontamentosExistentes() async {
    if (widget.diarioObra == null) return;

    try {
      final database = context.read<AppDatabase>();

      // Busca todos os apontamentos do diário
      final apontamentos =
          await (database.select(database.diarioObraApontamento)..where(
                (tbl) => tbl.diarioObraUid.equals(widget.diarioObra!.uid),
              ))
              .get();

      print('🔍 Carregando apontamentos do diário ${widget.diarioObra!.uid}');
      print('   Total de apontamentos encontrados: ${apontamentos.length}');

      final Map<String, int> apontamentosCarregados = {};

      for (var apontamento in apontamentos) {
        String? itemVinculoUid;
        String subcontratadaUid = 'contratada';

        if (apontamento.equipamentoUid != null) {
          // Busca o equipamento vinculado na lista atual
          EquipamentoComNome? equipamentoVinculo;
          try {
            equipamentoVinculo = widget.listaEquipamentos.firstWhere(
              (e) => e.equipamentoUid == apontamento.equipamentoUid,
            );
          } catch (_) {
            equipamentoVinculo == null;
          }

          if (equipamentoVinculo != null) {
            itemVinculoUid = equipamentoVinculo.uid;
            print(
              '   ✓ Equipamento encontrado: ${equipamentoVinculo.nomeEquipamento}',
            );
            print('     - UID do vínculo: ${equipamentoVinculo.uid}');
            print('     - UID real: ${equipamentoVinculo.equipamentoUid}');
          } else {
            print(
              '   ✗ Equipamento não encontrado para UID: ${apontamento.equipamentoUid}',
            );
          }
        } else if (apontamento.maoDeObraUid != null) {
          MaoDeObraComNome? maoDeObraVinculo;

          try {
            maoDeObraVinculo = widget.listaMaoDeObra.firstWhere(
              (m) => m.maoDeObraUid == apontamento.maoDeObraUid,
            );
          } catch (_) {
            maoDeObraVinculo = null;
          }

          if (maoDeObraVinculo != null) {
            itemVinculoUid = maoDeObraVinculo.uid;
            print('   ✓ Mão de obra encontrada: ${maoDeObraVinculo.descricao}');
            print('     - UID do vínculo: ${maoDeObraVinculo.uid}');
            print('     - UID real: ${maoDeObraVinculo.maoDeObraUid}');
          } else {
            print(
              '   ✗ Mão de obra não encontrada para UID: ${apontamento.maoDeObraUid}',
            );
          }
        }

        if (apontamento.subcontratadaUid != null) {
          subcontratadaUid = apontamento.subcontratadaUid!;
        }

        if (itemVinculoUid != null) {
          final key = '${itemVinculoUid}_$subcontratadaUid';
          apontamentosCarregados[key] = apontamento.valorApontamento;
          print(
            '   → Adicionado apontamento: $key = ${apontamento.valorApontamento}',
          );
        }
      }

      setState(() {
        _apontamentosMap = apontamentosCarregados;
      });
    } catch (e) {
      print('❌ Erro ao carregar apontamentos: $e');
    }
  }

  // No método de salvar, incluir apontamentos
  void _salvarDiario() {
    final _uuid = Uuid();

    if (periodoManhaSelecionado == '' ||
        periodoTardeSelecionado == '' ||
        periodoNoiteSelecionado == '' ||
        condicaoManhaSelecionado == '' ||
        condicaoTardeSelecionado == '' ||
        condicaoNoiteSelecionado == '') {
      setState(() {
        msgError = 'Preencha os campos obrigatórios(*) para continuar.';
      });
      return;
    }

    final diarioAtualizado = DiarioObraComDados(
      uid: widget.modoCriacao
          ? 'temp_${_uuid.v4()}'
          : (widget.uidTemporario ?? widget.diarioObra!.uid),
      usuarioResponsavelUid: widget.diarioObra?.usuarioResponsavelUid,
      numero: widget.numero,
      data: dataSelecionada,
      sequencial: widget.diarioObra?.sequencial,
      aprovadoContratada: widget.diarioObra?.aprovadoContratada ?? false,
      assinadoContratada: widget.diarioObra?.assinadoContratada ?? false,
      assinadoContratante: widget.diarioObra?.assinadoContratante ?? false,
      dataHoraInclusao: DateTime.now().toIso8601String(),
      statusObraEnum: statusSelecionado,
      periodoTrabalhadoManhaEnum: periodos.indexOf(periodoManhaSelecionado),
      periodoTrabalhadoTardeEnum: periodos.indexOf(periodoTardeSelecionado),
      periodoTrabalhadoNoiteEnum: periodos.indexOf(periodoNoiteSelecionado),
      condicoesMeteorologicasManhaEnum: condicoes.indexOf(
        condicaoManhaSelecionado,
      ),
      condicoesMeteorologicasTardeEnum: condicoes.indexOf(
        condicaoTardeSelecionado,
      ),
      condicoesMeteorologicasNoiteEnum: condicoes.indexOf(
        condicaoNoiteSelecionado,
      ),
      observacoesPeriodoTrabalhado: observPeriodoController.text.trim().isEmpty
          ? null
          : observPeriodoController.text.trim(),
      observacoesCondicoesMeteorologicas:
          observCondicoesController.text.trim().isEmpty
          ? null
          : observCondicoesController.text.trim(),
      evolucoes: _evolucoesTemporarias,
      anotacoesGerenciadora: _anotacoesGerenciadoraTemporarias,
      anotacoesContratada: _anotacoesContratadaTemporarias,
      anexos: _anexosTemporarios,
      apontamentos: Map.from(_apontamentosMap),
      statusSincronizacao: 'pendente',
    );

    Navigator.pop(context, diarioAtualizado);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    numeroController.dispose();
    dataController.dispose();
    observPeriodoController.dispose();
    observCondicoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? erroSincronizacao = widget.diarioObra?.erroSincronizacao;
    final bool temErro =
        erroSincronizacao != null && erroSincronizacao.isNotEmpty;
    final bool temDadosTemporarios =
        _evolucoesTemporarias.isNotEmpty ||
        _anotacoesGerenciadoraTemporarias.isNotEmpty ||
        _anotacoesContratadaTemporarias.isNotEmpty ||
        _anexosTemporarios.isNotEmpty ||
        _apontamentosMap.isNotEmpty;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                const Text(
                  'Diário de Obra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Boomer',
                    color: Color(0xFF2C2E35),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (temErro || temDadosTemporarios) ...[
              if (erroSincronizacao != null && erroSincronizacao.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Erro na sincronização: $erroSincronizacao',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],

            if (msgError != '') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  msgError,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontFamily: 'Boomer',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Obra: ${widget.nomeObra}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Boomer',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Contratada: ${widget.nomeContratado}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Boomer',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Responsável: ${pronomeTexto.toUpperCase()} ${widget.nomeResponsavel}",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Boomer',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Campos básicos
                    _buildCamposBasicos(),
                    const SizedBox(height: 24),

                    // Períodos Trabalhados
                    _buildPeriodosTrabalhados(),
                    const SizedBox(height: 24),

                    // Condições Meteorológicas
                    _buildCondicoesMeteorologicas(),
                    const SizedBox(height: 35),

                    // Evolução dos Serviços
                    _buildSecaoEvolucaoServicos(),
                    const SizedBox(height: 35),

                    // Anotação da Gerenciadora
                    _buildSecaoAnotacaoGerenciadora(),
                    const SizedBox(height: 35),

                    // Anotação da Contratada
                    _buildSecaoAnotacaoContratada(),
                    const SizedBox(height: 35),

                    // Anexos
                    _buildSecaoAnexos(),
                    const SizedBox(height: 35),

                    // Apontamentos
                    _buildSecaoApontamentos(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botões
            _buildBotoes(),
          ],
        ),
      ),
    );
  }

  Widget _buildCamposBasicos() {
    Future<void> _selecionarData() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        locale: Locale('pt', 'BR'),
        initialDate: dataSelecionada,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color.fromARGB(255, 15, 135, 233),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != dataSelecionada) {
        setState(() {
          dataSelecionada = picked;
          dataController.text =
              "${picked.day.toString().padLeft(2, '0')}/"
              "${picked.month.toString().padLeft(2, '0')}/"
              "${picked.year}";
        });
      }
    }

    return Column(
      children: [
        TextField(
          controller: numeroController,
          enabled: false,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Número',
            labelStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Boomer',
            ),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: dataController,
          enabled: !widget.apenaVisualizacao,
          readOnly: true,
          onTap: widget.apenaVisualizacao ? null : _selecionarData,
          decoration: InputDecoration(
            labelText: 'Data',
            labelStyle: TextStyle(
              color: widget.apenaVisualizacao ? Colors.grey : Colors.black54,
              fontFamily: 'Boomer',
            ),
            filled: true,
            fillColor: widget.apenaVisualizacao
                ? Colors.grey.shade200
                : const Color.fromARGB(255, 236, 238, 238),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            suffixIcon: widget.apenaVisualizacao
                ? null
                : const Icon(Icons.calendar_today, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        StatusSwitch(
          apenasVisualizacao: widget.apenaVisualizacao,
          aprovadoInicial: statusSelecionado == 1,
        ),
      ],
    );
  }

  Widget _buildPeriodosTrabalhados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Períodos Trabalhados',
          style: TextStyle(
            fontFamily: 'Boomer',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2E35),
          ),
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('periodo_manha_$periodoManhaSelecionado'),
          label: 'Manhã*',
          valorInicial: periodoManhaSelecionado,
          opcoes: periodos,
          onSelecionar: (v) => setState(() => periodoManhaSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('periodo_tarde_$periodoTardeSelecionado'),
          label: 'Tarde*',
          valorInicial: periodoTardeSelecionado,
          opcoes: periodos,
          onSelecionar: (v) => setState(() => periodoTardeSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('periodo_noite_$periodoNoiteSelecionado'),
          label: 'Noite*',
          valorInicial: periodoNoiteSelecionado,
          opcoes: periodos,
          onSelecionar: (v) => setState(() => periodoNoiteSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: observPeriodoController,
          enabled: !widget.apenaVisualizacao,
          readOnly: widget.apenaVisualizacao,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Observações (Período Trabalhado)',
            labelStyle: TextStyle(
              color: widget.apenaVisualizacao ? Colors.grey : Colors.black54,
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
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 135, 233)),
            ),
          ),
          onTap: () {
            if (!widget.apenaVisualizacao) {
              observPeriodoController.selection = TextSelection.fromPosition(
                TextPosition(offset: observPeriodoController.text.length),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCondicoesMeteorologicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condições Meteorológicas',
          style: TextStyle(
            fontFamily: 'Boomer',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2E35),
          ),
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('condicao_manha_$condicaoManhaSelecionado'),
          label: 'Manhã*',
          valorInicial: condicaoManhaSelecionado,
          opcoes: condicoes,
          onSelecionar: (v) => setState(() => condicaoManhaSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('condicao_tarde_$condicaoTardeSelecionado'),
          label: 'Tarde*',
          valorInicial: condicaoTardeSelecionado,
          opcoes: condicoes,
          onSelecionar: (v) => setState(() => condicaoTardeSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 12),
        AutocompleteCustomizado(
          key: ValueKey('condicao_noite_$condicaoNoiteSelecionado'),
          label: 'Noite*',
          valorInicial: condicaoNoiteSelecionado,
          opcoes: condicoes,
          onSelecionar: (v) => setState(() => condicaoNoiteSelecionado = v),
          somenteLeitura: widget.apenaVisualizacao,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: observCondicoesController,
          enabled: !widget.apenaVisualizacao,
          readOnly: widget.apenaVisualizacao,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Observações (Condições Meteorológicas)',
            labelStyle: TextStyle(
              color: widget.apenaVisualizacao ? Colors.grey : Colors.black54,
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
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 135, 233)),
            ),
          ),
          onTap: () {
            if (!widget.apenaVisualizacao) {
              observCondicoesController.selection = TextSelection.fromPosition(
                TextPosition(offset: observCondicoesController.text.length),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSecaoEvolucaoServicos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SecaoComBotao(
          titulo: "Evolução dos Serviços",
          textoBotao: "Adicionar",
          onPressed: widget.apenaVisualizacao
              ? null
              : () {
                  _mostrarModalEvolucaoServico(modoCriacao: true);
                },
        ),
        _buildTabelaEvolucaoServicos(),
      ],
    );
  }

  Widget _buildTabelaEvolucaoServicos() {
    return Container(
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
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(5),
          2: FixedColumnWidth(85),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFDFDFDF)),
            children: [
              _HeaderCell('Número'),
              _HeaderCell('Evolução'),
              _HeaderCell('Detalhes'),
            ],
          ),
          ..._evolucoesTemporarias.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEven = index % 2 == 0;
            final numeroFormatado =
                int.tryParse(item.numero)?.toString().padLeft(5, '0') ??
                item.numero;

            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
              ),
              children: [
                _BodyCell(numeroFormatado),
                _BodyCell(item.evolucao),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.apenaVisualizacao)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _mostrarModalEvolucaoServico(
                              evolucao: item,
                              modoCriacao: false,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            child: const Tooltip(
                              message: 'Editar',
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _mostrarModalEvolucaoServico(
                            evolucao: item,
                            apenaVisualizacao: true,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          child: const Tooltip(
                            message: 'Visualizar',
                            child: Padding(
                              padding: EdgeInsets.all(4),
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
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecaoAnotacaoGerenciadora() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SecaoComBotao(
          titulo: "Anotação da Gerenciadora",
          textoBotao: "Adicionar",
          onPressed: widget.apenaVisualizacao || (!widget.usuario!.grupoLotus)
              ? null
              : () {
                  _mostrarModalAnotacaoGerenciadora(modoCriacao: true);
                },
        ),
        _buildTabelaAnotacaoGerenciadora(),
      ],
    );
  }

  Widget _buildTabelaAnotacaoGerenciadora() {
    return Container(
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
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(6),
          1: FlexColumnWidth(4),
          2: FixedColumnWidth(85),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFDFDFDF)),
            children: [
              _HeaderCell('Data'),
              _HeaderCell('Anotação'),
              _HeaderCell('Detalhes'),
            ],
          ),
          ..._anotacoesGerenciadoraTemporarias.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEven = index % 2 == 0;
            final dataFormatada =
                "${item.data.day.toString().padLeft(2, '0')}/"
                "${item.data.month.toString().padLeft(2, '0')}/"
                "${item.data.year}";

            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
              ),
              children: [
                _BodyCell(dataFormatada),
                _BodyCell(item.anotacao),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.apenaVisualizacao)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _mostrarModalAnotacaoGerenciadora(
                              anotacao: item,
                              modoCriacao: false,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            child: const Tooltip(
                              message: 'Editar',
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _mostrarModalAnotacaoGerenciadora(
                            anotacao: item,
                            apenaVisualizacao: true,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          child: const Tooltip(
                            message: 'Visualizar',
                            child: Padding(
                              padding: EdgeInsets.all(4),
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
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecaoAnotacaoContratada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SecaoComBotao(
          titulo: "Anotação da Contratada",
          textoBotao: "Adicionar",
          onPressed: widget.apenaVisualizacao || widget.usuario!.grupoLotus
              ? null
              : () {
                  _mostrarModalAnotacaoContratada(modoCriacao: true);
                },
        ),
        _buildTabelaAnotacaoContratada(),
      ],
    );
  }

  Widget _buildTabelaAnotacaoContratada() {
    return Container(
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
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(6),
          1: FlexColumnWidth(4),
          2: FixedColumnWidth(85),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFDFDFDF)),
            children: [
              _HeaderCell('Data'),
              _HeaderCell('Anotação'),
              _HeaderCell('Detalhes'),
            ],
          ),
          ..._anotacoesContratadaTemporarias.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEven = index % 2 == 0;
            final dataFormatada =
                "${item.data.day.toString().padLeft(2, '0')}/"
                "${item.data.month.toString().padLeft(2, '0')}/"
                "${item.data.year}";

            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
              ),
              children: [
                _BodyCell(dataFormatada),
                _BodyCell(item.anotacao),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.apenaVisualizacao)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _mostrarModalAnotacaoContratada(
                              anotacao: item,
                              modoCriacao: false,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            child: const Tooltip(
                              message: 'Editar',
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _mostrarModalAnotacaoContratada(
                            anotacao: item,
                            apenaVisualizacao: true,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          child: const Tooltip(
                            message: 'Visualizar',
                            child: Padding(
                              padding: EdgeInsets.all(4),
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
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecaoAnexos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SecaoComBotao(
          titulo: "Imagens",
          textoBotao: "Adicionar",
          onPressed: widget.apenaVisualizacao
              ? null
              : () {
                  _mostrarModalAnexo(modoCriacao: true);
                },
        ),
        _buildTabelaAnexos(),
      ],
    );
  }

  Widget _buildTabelaAnexos() {
    final Map<String, AnexoComDados> byKey = {};
    for (final item in _anexosTemporarios) {
      final key =
          item.guidControleUpload ??
          item.uid ??
          item.descricao ??
          item.hashCode.toString();
      if (!byKey.containsKey(key)) {
        byKey[key] = item;
      } else {
        final existing = byKey[key]!;
        final existingIsTemp = existing.uid?.startsWith('temp_') ?? false;
        final newIsTemp = item.uid?.startsWith('temp_') ?? false;

        if (existingIsTemp && !newIsTemp) {
          byKey[key] = item;
        }
      }
    }

    final List<AnexoComDados> anexosParaMostrar = byKey.values.toList();

    final List<TableRow> rows = anexosParaMostrar.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isEven = index % 2 == 0;

      return TableRow(
        decoration: BoxDecoration(
          color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
        ),
        children: [
          _BodyCell(item.descricao),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.apenaVisualizacao)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _mostrarModalAnexo(anexo: item, modoCriacao: false),
                      borderRadius: BorderRadius.circular(4),
                      child: const Tooltip(
                        message: 'Editar',
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _mostrarModalAnexo(
                      anexo: item,
                      apenaVisualizacao: true,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    child: const Tooltip(
                      message: 'Visualizar',
                      child: Padding(
                        padding: EdgeInsets.all(4),
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
        ],
      );
    }).toList();
    return Container(
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
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(5), 1: FixedColumnWidth(85)},
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFDFDFDF)),
            children: [_HeaderCell('Descrição'), _HeaderCell('Detalhes')],
          ),
          ...rows,
          // ..._anexosTemporarios.asMap().entries.map((entry) {
          //   final index = entry.key;
          //   final item = entry.value;
          //   final isEven = index % 2 == 0;

          //   return TableRow(
          //     decoration: BoxDecoration(
          //       color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
          //     ),
          //     children: [
          //       _BodyCell(item.descricao),
          //       TableCell(
          //         verticalAlignment: TableCellVerticalAlignment.middle,
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             if (!widget.apenaVisualizacao)
          //               Material(
          //                 color: Colors.transparent,
          //                 child: InkWell(
          //                   onTap: () => _mostrarModalAnexo(
          //                     anexo: item,
          //                     modoCriacao: false,
          //                   ),
          //                   borderRadius: BorderRadius.circular(4),
          //                   child: const Tooltip(
          //                     message: 'Editar',
          //                     child: Padding(
          //                       padding: EdgeInsets.all(4),
          //                       child: Icon(
          //                         Icons.edit,
          //                         size: 18,
          //                         color: Colors.black87,
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             Material(
          //               color: Colors.transparent,
          //               child: InkWell(
          //                 onTap: () => _mostrarModalAnexo(
          //                   anexo: item,
          //                   apenaVisualizacao: true,
          //                 ),
          //                 borderRadius: BorderRadius.circular(4),
          //                 child: const Tooltip(
          //                   message: 'Visualizar',
          //                   child: Padding(
          //                     padding: EdgeInsets.all(4),
          //                     child: Icon(
          //                       Icons.search,
          //                       size: 18,
          //                       color: Colors.black87,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   );
          // }),
        ],
      ),
    );
  }

  Widget _buildSecaoApontamentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apontamentos',
          style: TextStyle(
            fontFamily: 'Boomer',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2E35),
          ),
        ),
        const SizedBox(height: 16),
        _buildTabelaApontamentos(),
      ],
    );
  }

  Widget _buildTabelaApontamentos() {
    // Combina listas de equipamentos e mão de obra (vindas do contexto superior)
    final List<ItemApontamento> itensLinhas = [
      // Adiciona equipamentos
      ...widget.listaEquipamentos.map(
        (e) => ItemApontamento(
          uid: e.uid,
          descricao: e.nomeEquipamento,
          tipo: TipoApontamento.equipamento,
        ),
      ),
      // Adiciona mão de obra
      ...widget.listaMaoDeObra.map(
        (m) => ItemApontamento(
          uid: m.uid,
          descricao: m.descricao,
          statusTipoMaoDeObraEnum: m.statusTipoMaoDeObraEnum,
          tipo: TipoApontamento.maoDeObra,
        ),
      ),
    ];

    final List<SubcontratadaInfo> subcontratadas = [
      SubcontratadaInfo(uid: 'contratada', abreviacao: widget.nomeContratado),
      ...widget.listaSubcontratada.map(
        (s) => SubcontratadaInfo(uid: s.uid, abreviacao: s.abreviacao),
      ),
    ];

    if (itensLinhas.isEmpty || subcontratadas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            'Adicione Equipamentos, Mão de Obra e Subcontratadas para registrar apontamentos',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: 'Boomer',
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    const double firstColumnWidth = 120;
    const double otherColumnWidth = 72;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDFDFDF),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              offset: const Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header da tabela
            _buildHeaderApontamentos(
              subcontratadas,
              firstColumnWidth,
              otherColumnWidth,
            ),
            // Seção: Mão de Obra Direta
            if (itensLinhas.any(
              (i) =>
                  i.tipo == TipoApontamento.maoDeObra &&
                  i.statusTipoMaoDeObraEnum?.compareTo(0) == 0,
            ))
              _buildSecaoApontamento(
                titulo: 'Mão de Obra\nDireta',
                itens: itensLinhas
                    .where(
                      (i) =>
                          i.tipo == TipoApontamento.maoDeObra &&
                          i.statusTipoMaoDeObraEnum?.compareTo(0) == 0,
                    )
                    .toList(),
                subcontratadas: subcontratadas,
                firstColumnWidth: firstColumnWidth,
                otherColumnWidth: otherColumnWidth,
              ),
            // Seção: Mão de Obra Indireta
            if (itensLinhas.any(
              (i) =>
                  i.tipo == TipoApontamento.maoDeObra &&
                  i.statusTipoMaoDeObraEnum?.compareTo(0) == 1,
            ))
              _buildSecaoApontamento(
                titulo: 'Mão de Obra\nIndireta',
                itens: itensLinhas
                    .where(
                      (i) =>
                          i.tipo == TipoApontamento.maoDeObra &&
                          i.statusTipoMaoDeObraEnum?.compareTo(0) == 1,
                    )
                    .toList(),
                subcontratadas: subcontratadas,
                firstColumnWidth: firstColumnWidth,
                otherColumnWidth: otherColumnWidth,
              ),
            // Seção: Equipamentos
            if (itensLinhas.any((i) => i.tipo == TipoApontamento.equipamento))
              _buildSecaoApontamento(
                titulo: 'Equipamentos',
                itens: itensLinhas
                    .where((i) => i.tipo == TipoApontamento.equipamento)
                    .toList(),
                subcontratadas: subcontratadas,
                firstColumnWidth: firstColumnWidth,
                otherColumnWidth: otherColumnWidth,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderApontamentos(
    List<SubcontratadaInfo> subcontratadas,
    double firstColumnWidth,
    double otherColumnWidth,
  ) {
    return Container(
      color: const Color(0xFFDFDFDF),
      child: Row(
        children: [
          // Primeira coluna vazia (para os nomes das linhas)
          Container(
            width: firstColumnWidth,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            child: const Text(
              'Apontamentos',
              style: TextStyle(
                color: Color(0xFF81868D),
                fontSize: 12,
                fontFamily: 'Boomer',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Colunas das subcontratadas
          ...subcontratadas.map(
            (sub) => Container(
              width: otherColumnWidth,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade400),
                  bottom: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              child: Text(
                sub.abreviacao,
                style: const TextStyle(
                  color: Color(0xFF81868D),
                  fontSize: 11,
                  fontFamily: 'Boomer',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Coluna Total
          Container(
            width: otherColumnWidth,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
            ),
            child: const Text(
              'Total',
              style: TextStyle(
                color: Color(0xFF81868D),
                fontSize: 12,
                fontFamily: 'Boomer',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoApontamento({
    required String titulo,
    required List<ItemApontamento> itens,
    required List<SubcontratadaInfo> subcontratadas,
    double firstColumnWidth = 120,
    double otherColumnWidth = 84,
  }) {
    return IntrinsicWidth(
      child: Column(
        children: [
          // Header da seção
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: const Color(0xFFB3D9FF),
            child: Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF2C2E35),
                fontSize: 13,
                fontFamily: 'Boomer',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Linhas dos itens
          ...itens.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEven = index % 2 == 0;

            return Container(
              color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
              child: Row(
                children: [
                  Container(
                    width: firstColumnWidth,
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Text(
                      item.descricao,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Boomer',
                      ),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Campos de entrada para cada subcontratada
                  ...subcontratadas.map((sub) {
                    final key = '${item.uid}_${sub.uid}';
                    final valorAtual = _apontamentosMap[key] ?? 0.0;

                    return Container(
                      width: otherColumnWidth,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      child: Container(
                        color: isEven ? const Color(0xFFF7F7F7) : Colors.white,
                        child: TextField(
                          controller: TextEditingController(
                            text: valorAtual == 0
                                ? '0'
                                : valorAtual.toStringAsFixed(0),
                          ),
                          enabled: !widget.apenaVisualizacao,
                          readOnly: widget.apenaVisualizacao,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Boomer',
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _apontamentosMap[key] = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  // Total da linha
                  Container(
                    width: otherColumnWidth,
                    height: 45,
                    alignment: Alignment.center,
                    child: Text(
                      _calcularTotalLinha(
                        item.uid,
                        subcontratadas,
                      ).toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Boomer',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Linha de total da seção
          Container(
            color: const Color(0xFFE5E5E5),
            child: Row(
              children: [
                Container(
                  width: firstColumnWidth,
                  height: 40,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade400),
                      top: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  child: const Text(
                    'Total',
                    style: TextStyle(
                      color: Color(0xFF2C2E35),
                      fontSize: 13,
                      fontFamily: 'Boomer',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...subcontratadas.map(
                  (sub) => Container(
                    width: otherColumnWidth,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade400),
                        top: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Text(
                      _calcularTotalColuna(sub.uid, itens).toStringAsFixed(0),
                      style: const TextStyle(
                        color: Color(0xFF2C2E35),
                        fontSize: 13,
                        fontFamily: 'Boomer',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: otherColumnWidth,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  child: Text(
                    _calcularTotalGeral(
                      itens,
                      subcontratadas,
                    ).toStringAsFixed(0),
                    style: const TextStyle(
                      color: Color(0xFF2C2E35),
                      fontSize: 13,
                      fontFamily: 'Boomer',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcularTotalLinha(
    String itemUid,
    List<SubcontratadaInfo> subcontratadas,
  ) {
    double total = 0;
    for (var sub in subcontratadas) {
      final key = '${itemUid}_${sub.uid}';
      total += _apontamentosMap[key] ?? 0.0;
    }
    return total;
  }

  double _calcularTotalColuna(
    String subcontratadaUid,
    List<ItemApontamento> itens,
  ) {
    double total = 0;
    for (var item in itens) {
      final key = '${item.uid}_$subcontratadaUid';
      total += _apontamentosMap[key] ?? 0.0;
    }
    return total;
  }

  double _calcularTotalGeral(
    List<ItemApontamento> itens,
    List<SubcontratadaInfo> subcontratadas,
  ) {
    double total = 0;
    for (var item in itens) {
      for (var sub in subcontratadas) {
        final key = '${item.uid}_${sub.uid}';
        total += _apontamentosMap[key] ?? 0.0;
      }
    }
    return total;
  }

  Widget _buildBotoes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        if (!widget.apenaVisualizacao)
          ElevatedButton(
            onPressed: _salvarDiario,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }

  Widget _buildAutocompleteCampo({
    required String label,
    required String? valorInicial,
    required List<String> opcoes,
    required Function(String) onSelecionar,
    required bool somenteLeitura,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: valorInicial ?? ''),
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return opcoes;
        return opcoes
            .where(
              (option) =>
                  option.toLowerCase().contains(value.text.toLowerCase()),
            )
            .toList();
      },
      onSelected: somenteLeitura ? null : (v) => onSelecionar(v),
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        textController.text = valorInicial ?? '';
        return TextField(
          controller: textController,
          focusNode: focusNode,
          enabled: !somenteLeitura,
          readOnly: somenteLeitura,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: somenteLeitura ? Colors.grey : Colors.black54,
              fontFamily: 'Boomer',
            ),
            filled: true,
            fillColor: somenteLeitura
                ? Colors.grey.shade200
                : const Color.fromARGB(255, 236, 238, 238),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 135, 233)),
            ),
          ),
          onTap: () {
            if (!somenteLeitura) {
              textController.selection = TextSelection.fromPosition(
                TextPosition(offset: textController.text.length),
              );
            }
          },
        );
      },
    );
  }

  // Métodos para mostrar modais
  void _mostrarModalEvolucaoServico({
    EvolucaoServicoComDados? evolucao,
    bool apenaVisualizacao = false,
    bool modoCriacao = false,
  }) {
    String proximoNumero = '00001';

    if (modoCriacao) {
      int maiorNumero = 0;

      for (var e in _evolucoesTemporarias) {
        final num = int.tryParse(e.numero) ?? 0;

        if (num > maiorNumero) {
          maiorNumero = num;
        }
      }

      proximoNumero = (maiorNumero + 1).toString().padLeft(5, '0');
    }

    showDialog(
      context: context,
      builder: (context) => _ModalEvolucaoServico(
        evolucao: evolucao,
        nomeObra: widget.nomeObra,
        nomeContratado: widget.nomeContratado,
        nomeResponsavel: widget.nomeResponsavel,
        pronomeTexto: pronomeTexto,
        apenaVisualizacao: apenaVisualizacao,
        modoCriacao: modoCriacao,
        numeroInicial: modoCriacao ? proximoNumero : null,
        onSalvar: (novaEvolucao) {
          setState(() {
            if (modoCriacao) {
              _evolucoesTemporarias.add(novaEvolucao);
            } else {
              final index = _evolucoesTemporarias.indexWhere(
                (e) => e.uid == novaEvolucao.uid,
              );
              if (index != -1) {
                _evolucoesTemporarias[index] = novaEvolucao;
              }
            }
          });
        },
      ),
    );
  }

  void _mostrarModalAnotacaoGerenciadora({
    AnotacaoGerenciadoraComDados? anotacao,
    bool apenaVisualizacao = false,
    bool modoCriacao = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ModalAnotacao(
        titulo: 'Anotação Gerenciadora',
        anotacao: anotacao?.anotacao,
        data: anotacao?.data,
        nomeObra: widget.nomeObra,
        nomeContratado: widget.nomeContratado,
        nomeResponsavel: widget.nomeResponsavel,
        pronomeTexto: pronomeTexto,
        apenaVisualizacao: apenaVisualizacao,
        onSalvar: (novaAnotacao, novaData) {
          setState(() {
            final _uuid = Uuid();

            final nova = AnotacaoGerenciadoraComDados(
              uid: modoCriacao ? 'temp_${_uuid.v4()}' : anotacao!.uid,
              data: novaData,
              anotacao: novaAnotacao,
              dataHoraInclusao: DateTime.now().toIso8601String(),
            );
            if (modoCriacao) {
              _anotacoesGerenciadoraTemporarias.add(nova);
            } else {
              final index = _anotacoesGerenciadoraTemporarias.indexWhere(
                (e) => e.uid == nova.uid,
              );
              if (index != -1) {
                _anotacoesGerenciadoraTemporarias[index] = nova;
              }
            }
          });
        },
      ),
    );
  }

  void _mostrarModalAnotacaoContratada({
    AnotacaoContratadaComDados? anotacao,
    bool apenaVisualizacao = false,
    bool modoCriacao = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ModalAnotacao(
        titulo: 'Anotação Contratada',
        anotacao: anotacao?.anotacao,
        data: anotacao?.data,
        nomeObra: widget.nomeObra,
        nomeContratado: widget.nomeContratado,
        nomeResponsavel: widget.nomeResponsavel,
        pronomeTexto: pronomeTexto,
        apenaVisualizacao: apenaVisualizacao,
        onSalvar: (novaAnotacao, novaData) {
          setState(() {
            final _uuid = Uuid();

            final nova = AnotacaoContratadaComDados(
              uid: modoCriacao ? 'temp_${_uuid.v4()}' : anotacao!.uid,
              data: novaData,
              anotacao: novaAnotacao,
              dataHoraInclusao: DateTime.now().toIso8601String(),
            );
            if (modoCriacao) {
              _anotacoesContratadaTemporarias.add(nova);
            } else {
              final index = _anotacoesContratadaTemporarias.indexWhere(
                (e) => e.uid == nova.uid,
              );
              if (index != -1) {
                _anotacoesContratadaTemporarias[index] = nova;
              }
            }
          });
        },
      ),
    );
  }

  void _mostrarModalAnexo({
    AnexoComDados? anexo,
    bool apenaVisualizacao = false,
    bool modoCriacao = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ModalAnexo(
        anexo: anexo,
        apenaVisualizacao: apenaVisualizacao,
        onSalvar: (novoAnexo) {
          setState(() {
            if (modoCriacao) {
              _anexosTemporarios.add(novoAnexo);
            } else {
              final index = _anexosTemporarios.indexWhere(
                (e) => e.uid == novoAnexo.uid,
              );
              if (index != -1) {
                _anexosTemporarios[index] = novoAnexo;
              }
            }
          });
        },
      ),
    );
  }
}

// Widgets auxiliares
class _SecaoComBotao extends StatelessWidget {
  final String titulo;
  final String textoBotao;
  final VoidCallback? onPressed;

  const _SecaoComBotao({
    required this.titulo,
    required this.textoBotao,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontFamily: 'Boomer',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2E35),
          ),
        ),
        if (onPressed != null)
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add, size: 16),
            label: Text(textoBotao),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A8E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontFamily: 'Boomer', fontSize: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
  const _BodyCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Boomer',
        ),
      ),
    );
  }
}

// Modal Evolução dos Serviços
class _ModalEvolucaoServico extends StatefulWidget {
  final EvolucaoServicoComDados? evolucao;
  final bool apenaVisualizacao;
  final bool modoCriacao;
  final String nomeObra;
  final String nomeContratado;
  final String pronomeTexto;
  final String nomeResponsavel;
  final Function(EvolucaoServicoComDados)? onSalvar;
  final String? numeroInicial;

  const _ModalEvolucaoServico({
    this.evolucao,
    this.apenaVisualizacao = false,
    this.modoCriacao = false,
    this.onSalvar,
    this.numeroInicial,
    required this.nomeObra,
    required this.nomeContratado,
    required this.pronomeTexto,
    required this.nomeResponsavel,
  });

  @override
  State<_ModalEvolucaoServico> createState() => _ModalEvolucaoServicoState();
}

class _ModalEvolucaoServicoState extends State<_ModalEvolucaoServico> {
  late TextEditingController numeroController;
  late TextEditingController evolucaoController;

  @override
  void initState() {
    super.initState();
    final numeroFormatado = widget.modoCriacao && widget.numeroInicial != null
        ? widget.numeroInicial!
        : (widget.evolucao?.numero != null
              ? int.tryParse(
                      widget.evolucao!.numero,
                    )?.toString().padLeft(5, '0') ??
                    widget.evolucao!.numero
              : '00001');

    numeroController = TextEditingController(text: numeroFormatado);
    evolucaoController = TextEditingController(
      text: widget.evolucao?.evolucao ?? '',
    );
  }

  @override
  void dispose() {
    numeroController.dispose();
    evolucaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Evolução dos Serviços',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Boomer',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Text(
              "Obra: ${widget.nomeObra}",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Boomer',
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "Contratada: ${widget.nomeContratado}",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Boomer',
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "Responsável: ${widget.pronomeTexto.toUpperCase()} ${widget.nomeResponsavel}",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Boomer',
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: numeroController,
              enabled: false,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Número',
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Boomer',
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: evolucaoController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Evolução',
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
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
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
                    style: TextStyle(color: Colors.white, fontFamily: 'Boomer'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!widget.apenaVisualizacao)
                  ElevatedButton(
                    onPressed: () {
                      if (numeroController.text.trim().isEmpty ||
                          evolucaoController.text.trim().isEmpty) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Preencha todos os campos'),
                        //     backgroundColor: Colors.orange,
                        //   ),
                        // );
                        return;
                      }

                      final numeroFormatado =
                          int.tryParse(
                            numeroController.text.trim(),
                          )?.toString().padLeft(5, '0') ??
                          numeroController.text.trim();

                      final _uuid = Uuid();

                      final evolucao = EvolucaoServicoComDados(
                        uid: widget.modoCriacao
                            ? 'temp_${_uuid.v4()}'
                            : (widget.evolucao?.uid ?? 'temp_${_uuid.v4()}'),
                        numero: numeroFormatado,
                        evolucao: evolucaoController.text.trim(),
                        sequencial: widget.evolucao?.sequencial,
                        dataHoraInclusao: DateTime.now().toIso8601String(),
                      );

                      if (widget.onSalvar != null) {
                        widget.onSalvar!(evolucao);
                      }
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
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

// Modal Anotação (Gerenciadora e Contratada)
class _ModalAnotacao extends StatefulWidget {
  final String titulo;
  final String? anotacao;
  final DateTime? data;
  final String nomeObra;
  final String nomeContratado;
  final String pronomeTexto;
  final String nomeResponsavel;
  final bool apenaVisualizacao;
  final Function(String, DateTime)? onSalvar;

  const _ModalAnotacao({
    required this.titulo,
    this.anotacao,
    this.data,
    this.apenaVisualizacao = false,
    this.onSalvar,
    required this.nomeObra,
    required this.nomeContratado,
    required this.pronomeTexto,
    required this.nomeResponsavel,
  });

  @override
  State<_ModalAnotacao> createState() => _ModalAnotacaoState();
}

class _ModalAnotacaoState extends State<_ModalAnotacao> {
  late TextEditingController anotacaoController;
  late TextEditingController dataController;
  late DateTime dataSelecionada;

  @override
  void initState() {
    super.initState();
    dataSelecionada = widget.data ?? DateTime.now();
    anotacaoController = TextEditingController(text: widget.anotacao ?? '');
    dataController = TextEditingController(
      text:
          "${dataSelecionada.day.toString().padLeft(2, '0')}/"
          "${dataSelecionada.month.toString().padLeft(2, '0')}/"
          "${dataSelecionada.year}",
    );
  }

  @override
  void dispose() {
    anotacaoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale('pt', 'BR'),
      initialDate: dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 15, 135, 233),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != dataSelecionada) {
      setState(() {
        dataSelecionada = picked;
        dataController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Boomer',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                "Obra: ${widget.nomeObra}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Boomer',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "Contratada: ${widget.nomeContratado}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Boomer',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "Responsável: ${widget.pronomeTexto.toUpperCase()} ${widget.nomeResponsavel}",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Boomer',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: dataController,
                enabled: !widget.apenaVisualizacao,
                readOnly: true,
                onTap: widget.apenaVisualizacao ? null : _selecionarData,
                decoration: InputDecoration(
                  labelText: 'Data',
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
                  suffixIcon: widget.apenaVisualizacao
                      ? null
                      : const Icon(Icons.calendar_today, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: anotacaoController,
                enabled: !widget.apenaVisualizacao,
                readOnly: widget.apenaVisualizacao,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Anotação',
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
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!widget.apenaVisualizacao)
                    ElevatedButton(
                      onPressed: () {
                        if (anotacaoController.text.trim().isEmpty) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Preencha a anotação'),
                          //     backgroundColor: Colors.orange,
                          //   ),
                          // );
                          return;
                        }

                        if (widget.onSalvar != null) {
                          widget.onSalvar!(
                            anotacaoController.text.trim(),
                            dataSelecionada,
                          );
                        }
                        Navigator.pop(context);
                        FocusManager.instance.primaryFocus?.unfocus();
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
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modal Anexo
class _ModalAnexo extends StatefulWidget {
  final AnexoComDados? anexo;
  final bool apenaVisualizacao;
  final Function(AnexoComDados)? onSalvar;

  const _ModalAnexo({
    this.anexo,
    this.apenaVisualizacao = false,
    this.onSalvar,
  });

  @override
  State<_ModalAnexo> createState() => _ModalAnexoState();
}

class _ModalAnexoState extends State<_ModalAnexo> {
  late TextEditingController descricaoController;
  XFile? imagemSelecionada;
  Uint8List? imagemBytes;
  bool carregandoImagem = false;

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController(
      text: widget.anexo?.descricao ?? '',
    );

    if (widget.anexo != null &&
        widget.anexo!.guidControleUpload.startsWith('/')) {
      _carregarImagemLocal();
    }
  }

  Future<void> _carregarImagemLocal() async {
    if (widget.anexo == null) return;

    try {
      final file = File(widget.anexo!.guidControleUpload);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          imagemBytes = bytes;
        });
      }
    } catch (e) {
      print('Erro ao carregar imagem local: $e');
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.apenaVisualizacao
              ? Icons.image_not_supported
              : Icons.add_photo_alternate,
          size: 64,
          color: widget.apenaVisualizacao
              ? Colors.grey.shade400
              : Colors.grey.shade600,
        ),
        const SizedBox(height: 8),
        Text(
          widget.apenaVisualizacao
              ? 'Nenhuma imagem'
              : 'Toque para selecionar imagem',
          style: TextStyle(
            color: widget.apenaVisualizacao
                ? Colors.grey.shade500
                : Colors.grey.shade700,
            fontFamily: 'Boomer',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImagemPreview() {
    if (carregandoImagem) {
      return Center(
        child: Image.asset(
          'assets/images/loading-screen-spinner.gif',
          width: 80,
          height: 80,
        ),
      );
    }

    if (imagemSelecionada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imagemSelecionada!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    if (imagemBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          imagemBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    if (widget.apenaVisualizacao) return;

    final imagePicker = ImagePicker();

    // Abre um modal para o usuário escolher a origem da imagem
    final ImageSource? origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    // Se o usuário cancelar, não faz nada
    if (origem == null) return;

    try {
      final pickedFile = await imagePicker.pickImage(
        source: origem,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          imagemSelecionada = pickedFile;
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Erro ao selecionar imagem'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Anexo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Boomer',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.apenaVisualizacao ? null : _selecionarImagem,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: widget.apenaVisualizacao
                        ? Colors.grey.shade200
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _buildImagemPreview(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descricaoController,
                enabled: !widget.apenaVisualizacao,
                readOnly: widget.apenaVisualizacao,
                maxLines: 3,
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
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!widget.apenaVisualizacao)
                    ElevatedButton(
                      onPressed: () async {
                        if (descricaoController.text.trim().isEmpty) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Preencha a descrição'),
                          //     backgroundColor: Colors.orange,
                          //   ),
                          // );
                          return;
                        }

                        if (imagemSelecionada == null) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Selecione uma imagem'),
                          //     backgroundColor: Colors.orange,
                          //   ),
                          // );
                          return;
                        }

                        String guidControleUpload =
                            widget.anexo?.guidControleUpload ?? '';

                        // Se selecionou uma nova imagem, usa o path local
                        if (imagemSelecionada != null) {
                          guidControleUpload = const Uuid().v4();
                        }

                        final anexo = AnexoComDados(
                          uid: widget.anexo?.uid ?? 'temp_${Uuid().v4()}',
                          descricao: descricaoController.text.trim(),
                          guidControleUpload: guidControleUpload,
                          uploadComplete: false,
                        );

                        if (widget.onSalvar != null) {
                          widget.onSalvar!(anexo);
                        }
                        Navigator.pop(context);
                        FocusManager.instance.primaryFocus?.unfocus();
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
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modal Apontamento
class _ModalApontamento extends StatefulWidget {
  final ApontamentoComDados? apontamento;
  final bool apenaVisualizacao;
  final Function(ApontamentoComDados)? onSalvar;

  const _ModalApontamento({
    this.apontamento,
    this.apenaVisualizacao = false,
    this.onSalvar,
  });

  @override
  State<_ModalApontamento> createState() => _ModalApontamentoState();
}

class _ModalApontamentoState extends State<_ModalApontamento> {
  late TextEditingController descricaoController;
  late TextEditingController valorController;
  String tipoSelecionado = 'Mão de Obra'; // ou 'Equipamento'

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController(
      text: widget.apontamento?.descricao ?? '',
    );
    valorController = TextEditingController(
      text: widget.apontamento?.valorApontamento.toStringAsFixed(2) ?? '0.00',
    );

    if (widget.apontamento != null) {
      tipoSelecionado = widget.apontamento!.maoDeObraUid != null
          ? 'Mão de Obra'
          : 'Equipamento';
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apontamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Boomer',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tipo',
              style: TextStyle(
                fontFamily: 'Boomer',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                tipoSelecionado == 'Mão de Obra',
                tipoSelecionado == 'Equipamento',
              ],
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: const Color.fromARGB(255, 15, 135, 233),
              color: Colors.black54,
              constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
              onPressed: widget.apenaVisualizacao
                  ? null
                  : (index) {
                      setState(() {
                        tipoSelecionado = index == 0
                            ? 'Mão de Obra'
                            : 'Equipamento';
                      });
                    },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'Mão de Obra',
                    style: TextStyle(fontFamily: 'Boomer'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'Equipamento',
                    style: TextStyle(fontFamily: 'Boomer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              decoration: InputDecoration(
                labelText: tipoSelecionado == 'Mão de Obra'
                    ? 'Mão de Obra'
                    : 'Equipamento',
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
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valorController,
              enabled: !widget.apenaVisualizacao,
              readOnly: widget.apenaVisualizacao,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Valor',
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
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
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
                    style: TextStyle(color: Colors.white, fontFamily: 'Boomer'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!widget.apenaVisualizacao)
                  ElevatedButton(
                    onPressed: () {
                      if (descricaoController.text.trim().isEmpty ||
                          valorController.text.trim().isEmpty) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Preencha todos os campos'),
                        //     backgroundColor: Colors.orange,
                        //   ),
                        // );
                        return;
                      }

                      final valor = double.tryParse(
                        valorController.text.trim(),
                      );
                      if (valor == null) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text('Valor inválido'),
                        //     backgroundColor: Colors.orange,
                        //   ),
                        // );
                        return;
                      }

                      final _uuid = Uuid();

                      final apontamento = ApontamentoComDados(
                        uid: widget.apontamento?.uid ?? 'temp_${_uuid.v4()}',
                        maoDeObraUid: tipoSelecionado == 'Mão de Obra'
                            ? 'temp_mao_obra'
                            : null,
                        equipamentoUid: tipoSelecionado == 'Equipamento'
                            ? 'temp_equipamento'
                            : null,
                        valorApontamento: valor,
                        descricao: descricaoController.text.trim(),
                      );

                      if (widget.onSalvar != null) {
                        widget.onSalvar!(apontamento);
                      }
                      Navigator.pop(context);
                      FocusManager.instance.primaryFocus?.unfocus();
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

class AutocompleteCustomizado extends StatefulWidget {
  final String? valorInicial;
  final List<String> opcoes;
  final String label;
  final bool somenteLeitura;
  final Function(String) onSelecionar;

  const AutocompleteCustomizado({
    super.key,
    required this.valorInicial,
    required this.opcoes,
    required this.label,
    required this.somenteLeitura,
    required this.onSelecionar,
  });

  @override
  State<AutocompleteCustomizado> createState() =>
      _AutocompleteCustomizadoState();
}

class _AutocompleteCustomizadoState extends State<AutocompleteCustomizado> {
  late TextEditingController _controller;
  String? _selecionado;
  late FocusNode _focusNode;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.valorInicial;
    _controller = TextEditingController(text: widget.valorInicial ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(AutocompleteCustomizado oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Atualiza o controller se o valorInicial mudou
    if (oldWidget.valorInicial != widget.valorInicial) {
      _selecionado = widget.valorInicial;
      if (_mounted) {
        _controller.text = widget.valorInicial ?? '';
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<List<String>> _getSuggestions(String pattern) async {
    if (widget.opcoes.isEmpty) return [];

    // Se há um item selecionado e o texto é exatamente o item selecionado
    if (_selecionado != null && pattern == _selecionado) {
      final outras = widget.opcoes
          .where((opcao) => opcao != _selecionado)
          .toList();
      return [_selecionado!, ...outras];
    }

    // Se está digitando, filtra normalmente
    if (pattern.isEmpty) {
      if (_selecionado != null) {
        final outras = widget.opcoes
            .where((opcao) => opcao != _selecionado)
            .toList();
        return [_selecionado!, ...outras];
      }
      return widget.opcoes;
    }

    return widget.opcoes.where((opcao) {
      return opcao.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      key: ValueKey('autocomplete_${widget.label}_${widget.valorInicial}'),
      builder: (context, controller, focusNode) {
        // Sincroniza o controller interno
        if (controller.text != _controller.text) {
          controller.text = _controller.text;
        }

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.somenteLeitura,
          readOnly: widget.somenteLeitura,
          autofocus: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.somenteLeitura
                ? Colors.grey.shade200
                : const Color.fromARGB(255, 236, 238, 238),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 15, 135, 233)),
            ),
            labelText: widget.label,
            labelStyle: TextStyle(
              color: widget.somenteLeitura ? Colors.grey : Colors.black54,
              fontFamily: 'Boomer',
            ),
            suffixIcon: widget.somenteLeitura
                ? null
                : const Icon(Icons.search, color: Color(0xFF2C2E35)),
          ),
          onChanged: (value) {
            if (!_mounted) return;
            
            // Se o valor mudou e não é o selecionado, limpa a seleção
            if (_selecionado != null && _selecionado != value) {
              if (mounted) {
                setState(() {
                  _selecionado = null;
                });
              }
            }
          },
          onTap: () {
            if (!widget.somenteLeitura && _mounted) {
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
          },
          onEditingComplete: () {
            if (!_mounted) return;
            
            if (_selecionado == null) {
              controller.clear();
              _controller.clear();
            }
          },
        );
      },

      suggestionsCallback: (pattern) {
        if (!_mounted) return Future.value(<String>[]);
        return _getSuggestions(pattern);
      },

      itemBuilder: (context, String suggestion) {
        if (!_mounted) {
          return const SizedBox.shrink();
        }

        final bool isSelected = _selecionado == suggestion;

        return Container(
          decoration: BoxDecoration(
            border: isSelected && _focusNode.hasFocus
                ? Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  )
                : null,
          ),
          child: ListTile(
            title: Text(
              suggestion,
              style: TextStyle(
                fontFamily: 'Boomer',
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

      onSelected: widget.somenteLeitura
          ? null
          : (String suggestion) {
              if (!_mounted) return;
              
              _controller.text = suggestion;
              if (mounted) {
                setState(() {
                  _selecionado = suggestion;
                });
              }
              widget.onSelecionar(suggestion);
            },

      emptyBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Nenhuma opção encontrada",
          style: TextStyle(fontFamily: 'Boomer'),
        ),
      ),
    );
  }
}