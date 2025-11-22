import 'package:lotus_mobile/dtos/contato_projeto_empresa_dto.dart';

class Contato{
  String empresaUid;
  int pronomeEnum;
  String pronomeEnumTexto;
  String nome;
  String ultimoNome;
  String hashTenant;
  String observacoes;
  List<ContatoProjetoEmpresaDto>? contatoProjetoEmpresa;
  String uid;
  String dataHoraInclusao;
  int statusRegistroEnum;

  Contato({
    required this.empresaUid,
    required this.pronomeEnum,
    required this.pronomeEnumTexto,
    required this.nome,
    required this.ultimoNome,
    required this.hashTenant,
    required this.observacoes,
    required this.contatoProjetoEmpresa,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      empresaUid: json['empresaUid'],
      pronomeEnum: json['pronomeEnum'],
      pronomeEnumTexto: json['pronomeEnumTexto'],
      nome: json['nome'],
      ultimoNome: json['ultimoNome'],
      hashTenant: json['hashTenant'],
      observacoes: json['observacoes'],
      contatoProjetoEmpresa: (json['contatoProjetoEmpresa'] as List?)
    ?.map((item) => ContatoProjetoEmpresaDto.fromJson(item))
    .toList() 
    ?? [],
      uid: json['uid'],
      dataHoraInclusao: json['dataHoraInclusao'],
      statusRegistroEnum: json['statusRegistroEnum'],
    );
  }

  Map<String, dynamic> toJson() {
    return{
      'empresaUid': empresaUid,
      'pronomeEnum': pronomeEnum,
      'pronomeEnumTexto': pronomeEnumTexto,
      'nome': nome,
      'ultimoNome': ultimoNome,
      'hashTenant': hashTenant,
      'observacoes': observacoes,
      'contatoProjetoEmpresa': contatoProjetoEmpresa,
      'uid': uid,
      'dataHoraInclusao': dataHoraInclusao,
      'statusRegistroEnum': statusRegistroEnum,
    };
  }
}