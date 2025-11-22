import 'package:lotus_mobile/dtos/mao_de_obra_dto.dart';

class DiarioObraConsultarMaoDeObraDto {
  final String empresaUid;
  final String maoDeObraUid;
  final MaoDeObraDto? maoDeObra;
  final int status;
  
  final String statusMaoDeObraEnumTexto;
  final String uid;
  final String dataHoraInclusao;
  final int statusRegistroEnum;

  DiarioObraConsultarMaoDeObraDto({
    required this.empresaUid,
    required this.maoDeObraUid,
    this.maoDeObra,
    required this.status,
    required this.statusMaoDeObraEnumTexto,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory DiarioObraConsultarMaoDeObraDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraConsultarMaoDeObraDto(
      empresaUid: json['empresaUid'] ?? '',
      maoDeObraUid: json['maoDeObraUid'] ?? '',
      maoDeObra: json['maoDeObra'] != null 
          ? MaoDeObraDto.fromJson(json['maoDeObra']) 
          : null,
      status: json['status'] ?? 0,
      statusMaoDeObraEnumTexto: json['statusMaoDeObraEnumTexto'] ?? '',
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'maoDeObraUid': maoDeObraUid,
      'status': status,
    };
  }
}