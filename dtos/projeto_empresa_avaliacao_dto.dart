import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class ProjetoEmpresaAvaliacaoDto {
  String uid;
  String empresaUid;
  String dataAvaliacao;
  int avaliacao;
  String observacoesAvaliacao;
  Contato? contatoAvaliador;
  Contato? contato;
  ProjetoEmpresaDto? projetoEmpresa;

  ProjetoEmpresaAvaliacaoDto({
    required this.uid,
    required this.empresaUid,
    required this.dataAvaliacao,
    required this.avaliacao,
    required this.observacoesAvaliacao,
    this.contatoAvaliador,
    this.contato,
    this.projetoEmpresa
  });

  factory ProjetoEmpresaAvaliacaoDto.fromJson(Map<String,dynamic> json) {
    return ProjetoEmpresaAvaliacaoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      dataAvaliacao: json['dataAvaliacao'], 
      avaliacao: json['avaliacao'], 
      observacoesAvaliacao: json['observacoesAvaliacao'], 
      contatoAvaliador: json['contatoAvaliador'] != null
        ? Contato.fromJson(json['contatoAvaliador'])
        : null, 
      contato: json['contato'] != null
        ? Contato.fromJson(json['contato'])
        : null, 
      projetoEmpresa: json['projetoEmpresa'] != null
        ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
        : null,
    );
  }
}