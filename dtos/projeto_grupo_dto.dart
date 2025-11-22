import 'package:lotus_mobile/dtos/projeto_grupo_tema_dto.dart';

class ProjetoGrupoDto {
  String uid;
  String empresaUid;
  String projetoUid;
  String nome;
  int statusProjetoGrupoTemaEnum;
  List<ProjetoGrupoTemaDto>? projetoGrupoTema;

  ProjetoGrupoDto({
    required this.uid,
    required this.empresaUid,
    required this.projetoUid,
    required this.nome,
    required this.statusProjetoGrupoTemaEnum,
    this.projetoGrupoTema
  });

  factory ProjetoGrupoDto.fromJson(Map<String, dynamic> json) {
    return ProjetoGrupoDto(
      uid: json['uid'],
      empresaUid: json['empresaUid'],
      projetoUid: json['projetoUid'],
      nome: json['nome'],
      statusProjetoGrupoTemaEnum: json['statusProjetoGrupoTemaEnum'],
      projetoGrupoTema: (json['projetoGrupoTema'] as List<dynamic>?)
              ?.map((p) => ProjetoGrupoTemaDto.fromJson(p))
              .toList() ??
          [],
    );
  }
}