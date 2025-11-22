import 'package:lotus_mobile/dtos/diario_obra_anexo_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_contratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_anotacoes_gerenciadora_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_apontamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_evolucao_servicos_dto.dart';
import 'package:lotus_mobile/dtos/obra_contratados_dto.dart';

class DiarioObraDto {
  final String uid;
  final String empresaUid;
  final String? usuarioResponsavelUid;
  final String diarioObraConsultarUid;
  final String? obraContratadosUid;
  final String numero;
  final int sequencial;
  final String data;
  final int statusObraEnum;
  final String statusObraEnumTexto;
  final int periodoTrabalhadoManhaEnum;
  final String periodoTrabalhadoManhaEnumTexto;
  final int periodoTrabalhadoTardeEnum;
  final String periodoTrabalhadoTardeEnumTexto;
  final int periodoTrabalhadoNoiteEnum;
  final String periodoTrabalhadoNoiteEnumTexto;
  final String observacoesPeriodoTrabalhado;
  final int condicoesMeteorologicasManhaEnum;
  final String condicoesMeteorologicasManhaEnumTexto;
  final int condicoesMeteorologicasTardeEnum;
  final String condicoesMeteorologicasTardeEnumTexto;
  final int condicoesMeteorologicasNoiteEnum;
  final String condicoesMeteorologicasNoiteEnumTexto;
  final String observacoesCondicoesMeteorologicas;
  final String dataHoraInclusao;
  final int statusRegistroEnum;
  final bool? aprovadoContratada;
  final bool? assinadoContratada;
  final bool? assinadoContratante;
  
  final ObraContratadosDto? obraContratados;
  
  final List<DiarioObraEvolucaoServicosDto> diarioObraEvolucaoServicos;
  final List<DiarioObraAnotacoesGerenciadoraDto> diarioObraAnotacoesGerenciadora;
  final List<DiarioObraAnotacoesContratadaDto> diarioObraAnotacoesContratada;
  final List<DiarioObraAnexoDto> diarioObraAnexo;
  final List<DiarioObraApontamentoDto> diarioObraApontamento;
  
  bool novoRegistro;

  DiarioObraDto({
    required this.uid,
    required this.empresaUid,
    this.usuarioResponsavelUid,
    required this.diarioObraConsultarUid,
    this.obraContratadosUid,
    required this.numero,
    required this.sequencial,
    required this.data,
    required this.statusObraEnum,
    required this.statusObraEnumTexto,
    required this.periodoTrabalhadoManhaEnum,
    required this.periodoTrabalhadoManhaEnumTexto,
    required this.periodoTrabalhadoTardeEnum,
    required this.periodoTrabalhadoTardeEnumTexto,
    required this.periodoTrabalhadoNoiteEnum,
    required this.periodoTrabalhadoNoiteEnumTexto,
    required this.observacoesPeriodoTrabalhado,
    required this.condicoesMeteorologicasManhaEnum,
    required this.condicoesMeteorologicasManhaEnumTexto,
    required this.condicoesMeteorologicasTardeEnum,
    required this.condicoesMeteorologicasTardeEnumTexto,
    required this.condicoesMeteorologicasNoiteEnum,
    required this.condicoesMeteorologicasNoiteEnumTexto,
    required this.observacoesCondicoesMeteorologicas,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
    this.aprovadoContratada,
    this.assinadoContratada,
    this.assinadoContratante,
    this.obraContratados,
    this.diarioObraEvolucaoServicos = const [],
    this.diarioObraAnotacoesGerenciadora = const [],
    this.diarioObraAnotacoesContratada = const [],
    this.diarioObraAnexo = const [],
    this.diarioObraApontamento = const [],
    this.novoRegistro = true,
  });

  factory DiarioObraDto.fromJson(Map<String, dynamic> json) {

    Map<String, dynamic>? _safeMap(dynamic data) {
      if (data is Map<String, dynamic>) return data;
      return null;
    }
    return DiarioObraDto(
      empresaUid: json['empresaUid'] ?? '',
      usuarioResponsavelUid: json['usuarioResponsavelUid'],
      diarioObraConsultarUid: json['diarioObraConsultarUid'] ?? '',
      obraContratadosUid: json['obraContratadosUid'] ?? '',
      numero: json['numero'] ?? '',
      sequencial: json['sequencial'] ?? 0,
      data: json['data'] ?? '',
      statusObraEnum: json['statusObraEnum'] ?? 0,
      statusObraEnumTexto: json['statusObraEnumTexto'] ?? '',
      periodoTrabalhadoManhaEnum: json['periodoTrabalhadoManhaEnum'] ?? 0,
      periodoTrabalhadoManhaEnumTexto: json['periodoTrabalhadoManhaaEnumTexto'] ?? '',
      periodoTrabalhadoTardeEnum: json['periodoTrabalhadoTardeEnum'] ?? 0,
      periodoTrabalhadoTardeEnumTexto: json['periodoTrabalhadoTardeEnumTexto'] ?? '',
      periodoTrabalhadoNoiteEnum: json['periodoTrabalhadoNoiteEnum'] ?? 0,
      periodoTrabalhadoNoiteEnumTexto: json['periodoTrabalhadoNoiteEnumTexto'] ?? '',
      observacoesPeriodoTrabalhado: json['observacoesPeriodoTrabalhado'] ?? '',
      condicoesMeteorologicasManhaEnum: json['condicoesMeteorologicasManhaEnum'] ?? 0,
      condicoesMeteorologicasManhaEnumTexto: json['condicoesMeteorologicasManhaEnumTexto'] ?? '',
      condicoesMeteorologicasTardeEnum: json['condicoesMeteorologicasTardeEnum'] ?? 0,
      condicoesMeteorologicasTardeEnumTexto: json['condicoesMeteorologicasTardeEnumTexto'] ?? '',
      condicoesMeteorologicasNoiteEnum: json['condicoesMeteorologicasNoiteEnum'] ?? 0,
      condicoesMeteorologicasNoiteEnumTexto: json['condicoesMeteorologicasNoiteEnumTexto'] ?? '',
      observacoesCondicoesMeteorologicas: json['observacoesCondicoesMeteorologicas'] ?? '',
      aprovadoContratada: json['aprovadoContratada'] ?? false,
      assinadoContratada: json['assinadoContratada'] ?? false,
      assinadoContratante: json['assinadoContratante'] ?? false,
      diarioObraEvolucaoServicos: (json['diarioObraEvolucaoServicos'] as List<dynamic>?)
          ?.map((e) => DiarioObraEvolucaoServicosDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      diarioObraAnotacoesGerenciadora: (json['diarioObraAnotacoesGerenciadora'] as List<dynamic>?)
          ?.map((e) => DiarioObraAnotacoesGerenciadoraDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      diarioObraAnotacoesContratada: (json['diarioObraAnotacoesContratada'] as List<dynamic>?)
          ?.map((e) => DiarioObraAnotacoesContratadaDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      diarioObraAnexo: (json['diarioObraAnexo'] as List<dynamic>?)
          ?.map((e) => DiarioObraAnexoDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      diarioObraApontamento: (json['diarioObraApontamento'] as List<dynamic>?)
          ?.map((e) => DiarioObraApontamentoDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'obraContratadosUid': obraContratadosUid,
      'diarioObraConsultarUid': diarioObraConsultarUid,
      'numero': numero,
      'data': data,
      'sequencial': sequencial,
      'statusObraEnum': statusObraEnum,
      'periodoTrabalhadoManhaEnum': periodoTrabalhadoManhaEnum,
      'periodoTrabalhadoTardeEnum': periodoTrabalhadoTardeEnum,
      'periodoTrabalhadoNoiteEnum': periodoTrabalhadoNoiteEnum,
      'observacoesPeriodoTrabalhado': observacoesPeriodoTrabalhado,
      'condicoesMeteorologicasManhaEnum': condicoesMeteorologicasManhaEnum,
      'condicoesMeteorologicasTardeEnum': condicoesMeteorologicasTardeEnum,
      'condicoesMeteorologicasNoiteEnum': condicoesMeteorologicasNoiteEnum,
      'observacoesCondicoesMeteorologicas': observacoesCondicoesMeteorologicas,
      'aprovadoContratada': aprovadoContratada,
      'assinadoContratada': assinadoContratada,
      'assinadoContratante': assinadoContratante,
      'diarioObraEvolucaoServicos': diarioObraEvolucaoServicos.map((e) => e.toJson()).toList(),
      'diarioObraAnotacoesGerenciadora': diarioObraAnotacoesGerenciadora.map((e) => e.toJson()).toList(),
      'diarioObraAnotacoesContratada': diarioObraAnotacoesContratada.map((e) => e.toJson()).toList(),
      'diarioObraAnexo': diarioObraAnexo.map((e) => e.toJson()).toList(),
      'diarioObraApontamento': diarioObraApontamento.map((e) => e.toJson()).toList(),
    };
  }

  // Método auxiliar para parsing seguro de listas
  static List<T> _parseList<T>(dynamic data, T Function(dynamic) fromJson) {
    if (data == null) return [];
    if (data is! List) return [];
    
    return data
        .map((item) {
          try {
            return fromJson(item);
          } catch (e) {
            print('Erro ao parsear item da lista ${T.toString()}: $e');
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  // Getters úteis
  int get totalApontamentos => diarioObraApontamento.length;
  bool get temApontamentos => diarioObraApontamento.isNotEmpty;
  bool get isEmEdicao => statusObraEnum == 0;
}