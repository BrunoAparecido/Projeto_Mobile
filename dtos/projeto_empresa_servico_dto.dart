import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';
import 'package:lotus_mobile/dtos/servico_dto.dart';

class ProjetoEmpresaServicoDto {
  String uid;
  String empresaUid;
  ServicoDto? servico;
  ProjetoEmpresaDto? projetoEmpresa;

  ProjetoEmpresaServicoDto({
    required this.uid,
    required this.empresaUid,
    this.servico,
    this.projetoEmpresa,
  });

  factory ProjetoEmpresaServicoDto.fromJson(Map<String, dynamic> json) {
    return ProjetoEmpresaServicoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      servico: json['servico'] != null
        ? ServicoDto.fromJson(json['servico'])
        : null,
      projetoEmpresa: json['projetoEmpresa'] != null
        ? ProjetoEmpresaDto.fromJson(json['contato'])
        : null,
    );
  }
}