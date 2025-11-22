class EquipamentoDto {
  String empresaUid;
  String nomeEquipamento;
  int statusEquipamentoEnum;
  String statusEquipamentoEnumTexto;
  String uid;
  String dataHoraInclusao;
  int statusRegistroEnum;

  EquipamentoDto({
    required this.empresaUid,
    required this.nomeEquipamento,
    required this.statusEquipamentoEnum,
    required this.statusEquipamentoEnumTexto,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory EquipamentoDto.fromJson(Map<String,dynamic> json) {
    return EquipamentoDto(
      empresaUid: json['empresaUid'], 
      nomeEquipamento: json['nomeEquipamento'], 
      statusEquipamentoEnum: json['statusEquipamentoEnum'], 
      statusEquipamentoEnumTexto: json['statusEquipamentoEnumTexto'], 
      uid: json['uid'], 
      dataHoraInclusao: json['dataHoraInclusao'], 
      statusRegistroEnum: json['statusRegistroEnum'],
    );
  }
}