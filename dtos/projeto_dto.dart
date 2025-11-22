import 'dart:core';

import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';
import 'package:lotus_mobile/dtos/projeto_gerenciamento_comunicacao_dto.dart';
import 'package:lotus_mobile/dtos/projeto_grupo_tema_dto.dart';
import 'package:lotus_mobile/dtos/projeto_participante_dto.dart';

class ProjetoDto {
  String uid;
  String empresaUid;
  String codigo;
  int prioridadeEnum;
  int statusProjetoEnum;
  int situacaoProjetoEnum;
  String nome;
  Contato? gerenteProjeto;
  ProjetoEmpresaDto? projetoEmpresa;
  Contato? contatoSponsor;
  String dataInicio;
  String dataTerminoPrevisto;
  String? dataTermino;
  String? sharepoint;
  String? hashPlanner;

  List<ProjetoGrupoTemaDto>? projetoGrupoTema = [];
  List<ProjetoGerenciamentoComunicacaoDto>? projetoGerenciamentoComunicacao =
      [];
  List<ProjetoParticipanteDto>? projetoParticipante = [];

  ProjetoDto({
    required this.uid,
    required this.empresaUid,
    required this.codigo,
    required this.prioridadeEnum,
    required this.statusProjetoEnum,
    required this.situacaoProjetoEnum,
    required this.nome,
    this.gerenteProjeto,
    this.projetoEmpresa,
    this.contatoSponsor,
    required this.dataInicio,
    required this.dataTerminoPrevisto,
    this.dataTermino,
    this.sharepoint,
    this.hashPlanner,
    this.projetoGrupoTema,
    this.projetoGerenciamentoComunicacao,
    this.projetoParticipante,
  });

  factory ProjetoDto.fromJson(Map<String, dynamic> json) {
    return ProjetoDto(
      uid: json['uid'],
      empresaUid: json['empresaUid'],
      codigo: json['codigo'],
      prioridadeEnum: json['prioridadeEnum'],
      statusProjetoEnum: json['statusProjetoEnum'],
      situacaoProjetoEnum: json['situacaoProjetoEnum'],
      nome: json['nome'],
      gerenteProjeto: json['gerenteProjeto'] != null
          ? Contato.fromJson(json['gerenteProjeto'])
          : null,
      projetoEmpresa: json['projetoEmpresa'] != null
          ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
          : null,
      contatoSponsor: json['contatoSponsor'] != null
          ? Contato.fromJson(json['contatoSponsor'])
          : null,
      dataInicio: json['dataInicio'],
      dataTerminoPrevisto: json['dataTerminoPrevisto'],
      dataTermino: json['dataTermino'],
      sharepoint: json['sharepoint'],
      hashPlanner: json['hashPlanner'],
      projetoGrupoTema:
          (json['projetoGrupoTema'] as List<dynamic>?)
              ?.map((p) => ProjetoGrupoTemaDto.fromJson(p))
              .toList() ??
          [],
      projetoGerenciamentoComunicacao:
          (json['projetoGerenciamentoComunicacao'] as List<dynamic>?)
              ?.map((p) => ProjetoGerenciamentoComunicacaoDto.fromJson(p))
              .toList() ??
          [],
      projetoParticipante:
          (json['projetoParticipante'] as List<dynamic>?)
              ?.map((p) => ProjetoParticipanteDto.fromJson(p))
              .toList() ??
          [],
    );
  }
}
