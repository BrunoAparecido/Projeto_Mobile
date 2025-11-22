import 'package:lotus_mobile/dtos/projeto_dto.dart';
import 'package:lotus_mobile/dtos/projeto_gerenciamento_comunicacao_dto.dart';

class ProjetoVersaoGerenciamentoComunicacaoDto {
  String uid;
  String empresaUid;
  String projetoUid;
  int statusProjetoVersaoGerenciamentoComunicacaoEnum;
  String statusProjetoVersaoGerenciamentoComunicacaoEnumTexto;
  int versao;
  int sequencial;
  String? usuarioAprovacaoUid;
  String? dataAprovacao;
  List<ProjetoGerenciamentoComunicacaoDto> projetoGerenciamentoComunicacao = [];
  ProjetoDto? projeto;

  ProjetoVersaoGerenciamentoComunicacaoDto({
    required this.uid,
    required this.empresaUid,
    required this.projetoUid,
    required this.statusProjetoVersaoGerenciamentoComunicacaoEnum,
    required this.statusProjetoVersaoGerenciamentoComunicacaoEnumTexto,
    required this.versao,
    required this.sequencial,
    this.usuarioAprovacaoUid,
    this.dataAprovacao,
    required this.projetoGerenciamentoComunicacao,
    this.projeto,
  });

  factory ProjetoVersaoGerenciamentoComunicacaoDto.fromJson(Map<String, dynamic> json) {
    return ProjetoVersaoGerenciamentoComunicacaoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      projetoUid: json['projetoUid'], 
      statusProjetoVersaoGerenciamentoComunicacaoEnum: json['statusProjetoVersaoGerenciamentoComunicacaoEnum'], 
      statusProjetoVersaoGerenciamentoComunicacaoEnumTexto: json['statusProjetoVersaoGerenciamentoComunicacaoEnumTexto'], 
      versao: json['versao'], 
      sequencial: json['sequencial'], 
      usuarioAprovacaoUid: json['usuarioAprovacaoUid'], 
      dataAprovacao: json['dataAprovacao'], 
      projetoGerenciamentoComunicacao: (json['projetoGerenciamentoComunicacao'] as List<dynamic>?)
              ?.map((p) => ProjetoGerenciamentoComunicacaoDto.fromJson(p))
              .toList() ??
          [],
      projeto: json['projeto'] != null
        ? ProjetoDto.fromJson(json['projeto'])
        : null,
    );
  }
}