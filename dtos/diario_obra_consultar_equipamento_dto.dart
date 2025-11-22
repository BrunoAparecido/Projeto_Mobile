import 'package:lotus_mobile/dtos/equipamento_dto.dart';

class DiarioObraConsultarEquipamentoDto {
  final String empresaUid;
  final String equipamentoUid;
  final EquipamentoDto? equipamento;
  final int status;
  final String statusEquipamentoEnumTexto;
  final String uid;
  final String dataHoraInclusao;
  final int statusRegistroEnum;

  DiarioObraConsultarEquipamentoDto({
    required this.empresaUid,
    required this.equipamentoUid,
    this.equipamento,
    required this.status,
    required this.statusEquipamentoEnumTexto,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory DiarioObraConsultarEquipamentoDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraConsultarEquipamentoDto(
      empresaUid: json['empresaUid'] ?? '',
      equipamentoUid: json['equipamentoUid'] ?? '',
      equipamento: json['equipamento'] != null 
          ? EquipamentoDto.fromJson(json['equipamento']) 
          : null,
      status: json['status'] ?? 0,
      statusEquipamentoEnumTexto: json['statusEquipamentoEnumTexto'] ?? '',
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'equipamentoUid': equipamentoUid,
      'status': status,
    };
  }
}