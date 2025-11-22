class DiarioObraAnexoDto {
  String uid;
  String? empresaUid;
  String descricao;
  String guidControleUpload;
  bool? uploadComplete;
  
  DiarioObraAnexoDto({
    required this.uid,
    this.empresaUid,
    required this.descricao,
    required this.guidControleUpload,
    this.uploadComplete,
  });

  factory DiarioObraAnexoDto.fromJson(Map<String, dynamic> json) {
    return DiarioObraAnexoDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      descricao: json['descricao'], 
      guidControleUpload: json['guidControleUpload'], 
      uploadComplete: json['uploadComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'descricao': descricao,
      'guidControleUpload': guidControleUpload,
      'uploadComplete': uploadComplete,
    };
  }
}