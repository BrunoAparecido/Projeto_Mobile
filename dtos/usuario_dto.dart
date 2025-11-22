import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/regra_usuario_dto.dart';

class UsuarioDto {
  String empresaUid;
  String email;
  String senha;
  RegraUsuarioDto? regraUsuarioDto;
  String regraUsuarioUid;
  String nome;
  String ultimoNome;
  String telefone;
  bool grupoLotus;
  Contato? contato;
  String contatoUid;
  String uid;
  String dataHoraInclusao;
  int statusRegistroEnum;

  UsuarioDto({ 
    required this.empresaUid,
    required this.email,
    required this.senha,
    required this.regraUsuarioDto,
    required this.regraUsuarioUid,
    required this.nome,
    required this.ultimoNome,
    required this.telefone,
    required this.grupoLotus,
    this.contato,
    required this.contatoUid,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory UsuarioDto.fromJson(Map<String,dynamic> json) {
    return UsuarioDto(
      empresaUid: json['empresaUid'], 
      email: json['email'], 
      senha: json['senha'], 
      regraUsuarioDto: json['regraUsuarioDto'] != null
    ? RegraUsuarioDto.fromJson(json['regraUsuarioDto'])
    : null, 
      regraUsuarioUid: json['regraUsuarioUid'], 
      nome: json['nome'], 
      ultimoNome: json['ultimoNome'], 
      telefone: json['telefone'], 
      grupoLotus: json['grupoLotus'],
      contato: json['contato'] != null
        ? Contato.fromJson(json['contato'])
        : null,
      contatoUid: json['contatoUid'], 
      uid: json['uid'], 
      dataHoraInclusao: json['dataHoraInclusao'], 
      statusRegistroEnum: json['statusRegistroEnum'],
    );
  }
}

