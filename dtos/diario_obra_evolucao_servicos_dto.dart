class DiarioObraEvolucaoServicosDto {
  final String empresaUid;
  final String? usuarioResponsavelUid;
  final String obraUid;
  final int numero;
  final int sequencial;
  final String evolucao;
  final String uid;
  final String dataHoraInclusao;
  final int statusRegistroEnum;

  DiarioObraEvolucaoServicosDto({
    required this.empresaUid,
    this.usuarioResponsavelUid,
    required this.obraUid,
    required this.numero,
    required this.sequencial,
    required this.evolucao,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory DiarioObraEvolucaoServicosDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraEvolucaoServicosDto(
      empresaUid: json['empresaUid'] ?? '',
      usuarioResponsavelUid: json['usuarioResponsavelUid'],
      obraUid: json['obraUid'] ?? '',
      numero: json['numero'] ?? 0,
      sequencial: json['sequencial'] ?? 0,
      evolucao: json['evolucao'] ?? '',
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'obraUid': obraUid,
      'sequencial': sequencial,
      'numero': numero,
      'evolucao': evolucao,
    };
  }

}