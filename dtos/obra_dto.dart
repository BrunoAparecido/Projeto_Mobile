import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/obra_contratados_dto.dart';
import 'package:lotus_mobile/dtos/projeto_dto.dart';

class ObraDto{
  String empresaUid;
  String nomeObra;
  String projetoUid;
  ProjetoDto? projeto;
  Contato? contatoResponsavel;
  List<ObraContratadosDto>? obraContratados = [];
  String uid;
  String dataHoraInclusao;
  int statusRegistroEnum;

  ObraDto({
    required this.empresaUid,
    required this.nomeObra,
    required this.projetoUid,
    this.projeto,
    this.contatoResponsavel,
    this.obraContratados,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory ObraDto.fromJson(Map<String, dynamic> json) {
    return ObraDto(
      empresaUid: json['empresaUid'],
      nomeObra: json['nomeObra'],
      projetoUid: json['projetoUid'],
      projeto: json['projeto'] != null
    ? ProjetoDto.fromJson(json['projeto'])
    : null,
      contatoResponsavel: json['contatoResponsavel'] != null
    ? Contato.fromJson(json['contatoResponsavel'])
    : null,
      obraContratados: (json['obraContratados'] as List<dynamic>?)
              ?.map((p) => ObraContratadosDto.fromJson(p))
              .toList() ??
          [],
      uid: json['uid'],
      dataHoraInclusao: json['dataHoraInclusao'],
      statusRegistroEnum: json['statusRegistroEnum'],
    );
  }
}