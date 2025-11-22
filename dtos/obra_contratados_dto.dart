import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class ObraContratadosDto {
  String uid;
  String empresaUid;
  ProjetoEmpresaDto? projetoEmpresa;
  int statusContratadoEnum;
  String statusContratadoEnumTexto;
  String escopo;
  String dataInicio;
  String dataTermino;
  String? dataTerminoRealizado;
  int prazo;
  int aditivos;

  ObraContratadosDto({
    required this.uid,
    required this.empresaUid,
    required this.projetoEmpresa,
    required this.statusContratadoEnum,
    required this.statusContratadoEnumTexto,
    required this.escopo,
    required this.dataInicio,
    required this.dataTermino,
    required this.dataTerminoRealizado,
    required this.prazo,
    required this.aditivos
  });

  factory ObraContratadosDto.fromJson(Map<String, dynamic> json){
    return ObraContratadosDto(
      uid: json['uid'],
      empresaUid: json['empresaUid'],
      projetoEmpresa: json['projetoEmpresa'] != null
    ? ProjetoEmpresaDto.fromJson(json['projetoEmpresa'])
    : null,
      statusContratadoEnum: json['statusContratadoEnum'],
      statusContratadoEnumTexto: json['statusContratadoEnumTexto'],
      escopo: json['escopo'],
      dataInicio: json['dataInicio'],
      dataTermino: json['dataTermino'],
      dataTerminoRealizado: json['dataTerminoRealizado'],
      prazo: json['prazo'],
      aditivos: json['aditivos'],
    );
  }
}