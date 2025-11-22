class MaoDeObraDto {
  String empresaUid;
  String descricao;
  int statusMaoDeObraEnum;
  String statusMaoDeObraEnumTexto;
  int statusTipoMaoDeObraEnum;
  String statusTipoMaoDeObraEnumTexto;
  String uid;
  String dataHoraInclusao;
  int statusRegistroEnum;

  MaoDeObraDto({
    required this.empresaUid,
    required this.descricao,
    required this.statusMaoDeObraEnum,
    required this.statusMaoDeObraEnumTexto,
    required this.statusTipoMaoDeObraEnum,
    required this.statusTipoMaoDeObraEnumTexto,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum
  });

  factory MaoDeObraDto.fromJson(Map<String, dynamic> json) {
    return MaoDeObraDto(
      empresaUid: json['empresaUid'], 
      descricao: json['descricao'], 
      statusMaoDeObraEnum: json['statusMaoDeObraEnum'], 
      statusMaoDeObraEnumTexto: json['statusMaoDeObraEnumTexto'], 
      statusTipoMaoDeObraEnum: json['statusTipoMaoDeObraEnum'], 
      statusTipoMaoDeObraEnumTexto: json['statusTipoMaoDeObraEnumTexto'], 
      uid: json['uid'], 
      dataHoraInclusao: json['dataHoraInclusao'], 
      statusRegistroEnum: json['statusRegistroEnum'],
    );
  }
}