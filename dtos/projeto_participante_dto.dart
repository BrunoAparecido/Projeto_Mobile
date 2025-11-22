import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class ProjetoParticipanteDto {
  String uid;
  String empresaUid;
  String projetoUid;
  Contato? contato;
  ProjetoEmpresaDto? projetoEmpresa;

  ProjetoParticipanteDto({
    required this.uid,
    required this.empresaUid,
    required this.projetoUid,
    this.contato,
    this.projetoEmpresa,
  });

  factory ProjetoParticipanteDto.fromJson(Map<String, dynamic> json) {
    return ProjetoParticipanteDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'],
      projetoUid: json['projetoUid'], 
      contato: json['contato'] != null
        ? Contato.fromJson(json['contato'])
        : null,
      projetoEmpresa: json['projetoEmpresa'] != null
        ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
        : null,
    );
  }
}