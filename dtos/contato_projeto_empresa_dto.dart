import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class ContatoProjetoEmpresaDto {
  String uid;
  String projetoEmpresaUid;
  ProjetoEmpresaDto? projetoEmpresa;
  String? contatoNome;
  bool contatoPrincipal;
  String cargo;
  String email;
  String telefone;
  int statusContatoProjetoEmpresaEnum;
  String? statusContatoProjetoEmpresaEnumTexto;

  ContatoProjetoEmpresaDto({
    required this.uid,
    required this.projetoEmpresaUid,
    this.projetoEmpresa,
    this.contatoNome,
    required this.contatoPrincipal,
    required this.cargo,
    required this.email,
    required this.telefone,
    required this.statusContatoProjetoEmpresaEnum,
    this.statusContatoProjetoEmpresaEnumTexto,
  });
  
  factory ContatoProjetoEmpresaDto.fromJson(Map<String,dynamic> json) {
    return ContatoProjetoEmpresaDto(
      uid: json['uid'], 
      projetoEmpresaUid: json['projetoEmpresaUid'], 
      projetoEmpresa: json['projetoEmpresa'] != null
        ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
        : null,
      contatoNome: json['contatoNome'], 
      contatoPrincipal: json['contatoPrincipal'], 
      cargo: json['cargo'], 
      email: json['email'], 
      telefone: json['telefone'], 
      statusContatoProjetoEmpresaEnum: json['statusContatoProjetoEmpresaEnum'], 
      statusContatoProjetoEmpresaEnumTexto: json['statusContatoProjetoEmpresaEnumTexto'],
    );
  }

}