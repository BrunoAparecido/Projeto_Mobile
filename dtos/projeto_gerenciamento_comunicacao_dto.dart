import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/projeto_versao_gerenciamento_comunicacao_dto.dart';

class ProjetoGerenciamentoComunicacaoDto {
  String? uid;
  String empresaUid;
  int conteudoEnum;
  String conteudoEnumTexto;
  int meioEnum;
  String meioEnumTexto;
  int frequenciaEnum;
  String frequenciaEnumTexto;
  bool automatico;
  Contato? contatoResponsavel;
  Contato? contatoDestinatario;
  Contato? contato;
  ProjetoVersaoGerenciamentoComunicacaoDto? projetoVersaoGerenciamentoComunicacaoDto;

  ProjetoGerenciamentoComunicacaoDto({
    this.uid,
    required this.empresaUid,
    required this.conteudoEnum,
    required this.conteudoEnumTexto,
    required this.meioEnum,
    required this.meioEnumTexto,
    required this.frequenciaEnum,
    required this.frequenciaEnumTexto,
    required this.automatico,
    this.contatoResponsavel,
    this.contatoDestinatario,
    this.contato,
    this.projetoVersaoGerenciamentoComunicacaoDto,
  });

  factory ProjetoGerenciamentoComunicacaoDto.fromJson(Map<String, dynamic> json) {
    return ProjetoGerenciamentoComunicacaoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      conteudoEnum: json['conteudoEnum'], 
      conteudoEnumTexto: json['conteudoEnumTexto'], 
      meioEnum: json['meioEnum'], 
      meioEnumTexto: json['meioEnumTexto'], 
      frequenciaEnum: json['frequenciaEnum'], 
      frequenciaEnumTexto: json['frequenciaEnumTexto'], 
      automatico: json['automatico'], 
      contatoResponsavel: json['contatoResponsavel'] != null
        ? Contato.fromJson(json['contatoResponsavel'])
        : null,  
      contatoDestinatario: json['contatoDestinatario'] != null
        ? Contato.fromJson(json['contatoDestinatario'])
        : null, 
      contato: json['contato'] != null
        ? Contato.fromJson(json['contato'])
        : null, 
      projetoVersaoGerenciamentoComunicacaoDto: json['projetoVersaoGerenciamentoComunicacaoDto'] != null
        ? ProjetoVersaoGerenciamentoComunicacaoDto.fromJson(json['projetoVersaoGerenciamentoComunicacaoDto'])
        : null,  
    );
  }
}