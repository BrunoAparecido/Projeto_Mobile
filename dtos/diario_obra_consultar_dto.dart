import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_equipamento_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_subcontratada_dto.dart';
import 'package:lotus_mobile/dtos/diario_obra_dto.dart';
import 'package:lotus_mobile/dtos/obra_contratados_dto.dart';
import 'package:lotus_mobile/dtos/obra_dto.dart';
import 'package:lotus_mobile/dtos/projeto_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class DiarioObraConsultarDto {
  String uid;
  String? empresaUid;
  ObraDto? obra;
  String? obraUid;
  String? projetoUid;
  ObraContratadosDto? obraContratados;
  String? obraContratadosUid;
  Contato? contatoResponsavel;
  ProjetoDto? projeto;
  Contato? contato;
  ProjetoEmpresaDto? projetoEmpresa;

  List<DiarioObraDto>? diarioObra = [];
  List<DiarioObraConsultarMaoDeObraDto>? diarioObraConsultarMaoDeObra = [];
  List<DiarioObraConsultarEquipamentoDto>? diarioObraConsultarEquipamento = [];
  List<DiarioObraConsultarSubcontratadaDto>? diarioObraConsultarSubcontratada =
      [];

  DiarioObraConsultarDto({
    required this.uid,
    this.empresaUid,
    this.projetoUid,
    this.obraUid,
    this.obraContratadosUid,
    required this.obra,
    required this.obraContratados,
    required this.contatoResponsavel,
    required this.projeto,
    required this.contato,
    required this.projetoEmpresa,
    required this.diarioObra,
    required this.diarioObraConsultarMaoDeObra,
    required this.diarioObraConsultarEquipamento,
    required this.diarioObraConsultarSubcontratada,
  });

  factory DiarioObraConsultarDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraConsultarDto(
      empresaUid: json['empresaUid'] ?? '',
      projeto: json['projeto'] != null
          ? ProjetoDto.fromJson(json['projeto'])
          : null,
      obra: json['obra'] != null ? ObraDto.fromJson(json['obra']) : null,
      obraContratados: json['obraContratados'] != null
          ? ObraContratadosDto.fromJson(json['obraContratados'])
          : null,
      diarioObra:
          (json['diarioObra'] as List<dynamic>?)
              ?.map((e) => DiarioObraDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      diarioObraConsultarSubcontratada:
          (json['diarioObraConsultarSubcontratada'] as List<dynamic>?)
              ?.map(
                (e) => DiarioObraConsultarSubcontratadaDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      diarioObraConsultarEquipamento:
          (json['diarioObraConsultarEquipamento'] as List<dynamic>?)
              ?.map(
                (e) => DiarioObraConsultarEquipamentoDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      diarioObraConsultarMaoDeObra:
          (json['diarioObraConsultarMaoDeObra'] as List<dynamic>?)
              ?.map(
                (e) => DiarioObraConsultarMaoDeObraDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      uid: json['uid'] ?? '',
      contatoResponsavel: json['contatoResponsavel'] != null
          ? Contato.fromJson(json['contatoResponsavel'])
          : null,
      contato: json['contato'] != null
          ? Contato.fromJson(json['contato'])
          : null,
      projetoEmpresa: json['projetoEmpresa'] != null
          ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'projetoUid': projeto?.uid,
      'obraUid': obra?.uid,
      'obraContratadosUid': obraContratados?.uid,
      'diarioObra': diarioObra?.map((e) => e.toJson()).toList() ?? [],
      'diarioObraConsultarSubcontratada':
          diarioObraConsultarSubcontratada?.map((e) => e.toJson()).toList() ??
          [],
      'diarioObraConsultarEquipamento':
          diarioObraConsultarEquipamento?.map((e) => e.toJson()).toList() ?? [],
      'diarioObraConsultarMaoDeObra':
          diarioObraConsultarMaoDeObra?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  DiarioObraConsultarDto copyWith({
    String? uid,
    String? empresaUid,
    ObraDto? obra,
    String? obraUid,
    String? projetoUid,
    ObraContratadosDto? obraContratados,
    String? obraContratadosUid,
    Contato? contatoResponsavel,
    ProjetoDto? projeto,
    Contato? contato,
    ProjetoEmpresaDto? projetoEmpresa,
    List<DiarioObraDto>? diarioObra,
    List<DiarioObraConsultarMaoDeObraDto>? diarioObraConsultarMaoDeObra,
    List<DiarioObraConsultarEquipamentoDto>? diarioObraConsultarEquipamento,
    List<DiarioObraConsultarSubcontratadaDto>? diarioObraConsultarSubcontratada,
  }) {
    return DiarioObraConsultarDto(
      uid: uid ?? this.uid,
      empresaUid: empresaUid ?? this.empresaUid,
      obra: obra ?? this.obra,
      obraUid: obraUid ?? this.obraUid,
      projetoUid: projetoUid ?? this.projetoUid,
      obraContratados: obraContratados ?? this.obraContratados,
      obraContratadosUid: obraContratadosUid ?? this.obraContratadosUid,
      contatoResponsavel: contatoResponsavel ?? this.contatoResponsavel,
      projeto: projeto ?? this.projeto,
      contato: contato ?? this.contato,
      projetoEmpresa: projetoEmpresa ?? this.projetoEmpresa,
      diarioObra: diarioObra ?? this.diarioObra,
      diarioObraConsultarMaoDeObra:
          diarioObraConsultarMaoDeObra ?? this.diarioObraConsultarMaoDeObra,
      diarioObraConsultarEquipamento:
          diarioObraConsultarEquipamento ?? this.diarioObraConsultarEquipamento,
      diarioObraConsultarSubcontratada:
          diarioObraConsultarSubcontratada ??
          this.diarioObraConsultarSubcontratada,
    );
  }
}
