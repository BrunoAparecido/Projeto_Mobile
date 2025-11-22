class DiarioObraConsultarSubcontratadaDto {
  final String abreviacao;
  final String nomeEmpresa;
  final String contatoPrincipal;
  final String uid;
  final String dataHoraInclusao;
  final int statusRegistroEnum;

  DiarioObraConsultarSubcontratadaDto({
    required this.abreviacao,
    required this.nomeEmpresa,
    required this.contatoPrincipal,
    required this.uid,
    required this.dataHoraInclusao,
    required this.statusRegistroEnum,
  });

  factory DiarioObraConsultarSubcontratadaDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraConsultarSubcontratadaDto(
      abreviacao: json['abreviacao'] ?? '',
      nomeEmpresa: json['nomeEmpresa'] ?? '',
      contatoPrincipal: json['contatoPrincipal'] ?? '',
      uid: json['uid'] ?? '',
      dataHoraInclusao: json['dataHoraInclusao'] ?? '',
      statusRegistroEnum: json['statusRegistroEnum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'abreviacao': abreviacao,
      'nomeEmpresa': nomeEmpresa,
      'contatoPrincipal': contatoPrincipal,
    };
  }
}