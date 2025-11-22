import 'package:lotus_mobile/dtos/projeto_grupo_dto.dart';

class ProjetoGrupoTemaDto {
  String uid;
  String empresaUid;
  ProjetoGrupoDto? projetoGrupo;
  String nomeTema;
  int index;

  ProjetoGrupoTemaDto({
    required this.uid,
    required this.empresaUid,
    this.projetoGrupo,
    required this.nomeTema,
    required this.index,
  });

  factory ProjetoGrupoTemaDto.fromJson(Map<String, dynamic> json) {
    return ProjetoGrupoTemaDto(
      uid: json['uid'], 
      empresaUid: json['empresaUid'], 
      projetoGrupo: json['projetoGrupo'] != null
        ? ProjetoGrupoDto.fromJson(json['projetoGrupo'])
        : null, 
      nomeTema: json['nomeTema'], 
      index: json['index'],
    );
  }
}