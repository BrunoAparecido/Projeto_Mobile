class DiarioObraAnotacoesGerenciadoraDto {
  final String empresaUid;
  final String? usuarioResponsavelUid;
  final String obraUid;
  final String data;
  final String anotacao;
  final String uid;
  final String dataHoraInclusao;
  final int statusRegistroEnum;

  DiarioObraAnotacoesGerenciadoraDto({
    required this.empresaUid,
    this.usuarioResponsavelUid,
    required this.obraUid,
    required this.data,
    required this.anotacao,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory DiarioObraAnotacoesGerenciadoraDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraAnotacoesGerenciadoraDto(
      empresaUid: json['empresaUid'] ?? '',
      usuarioResponsavelUid: json['usuarioResponsavelUid'],
      obraUid: json['obraUid'] ?? '',
      data: json['data'] ?? '',
      anotacao: json['anotacao'] ?? '',
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'obraUid': obraUid,
      'data': data,
      'anotacao': anotacao,
    };
  }
}