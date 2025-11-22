class ServicoDto {
  String uid;
  String empresaUid;
  String nomeServico;
  int statusServicoEnum;

  ServicoDto({
    required this.uid,
    required this.empresaUid,
    required this.nomeServico,
    required this.statusServicoEnum
  });

  factory ServicoDto.fromJson(Map<String,dynamic> json) {
    return ServicoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      nomeServico: json['nomeServico'], 
      statusServicoEnum: json['statusServicoEnum']
    );
  }
}