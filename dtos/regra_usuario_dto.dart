import 'package:lotus_mobile/dtos/regra_usuario_item_dto.dart';

class RegraUsuarioDto {
  String uid;
  String empresaUid;
  String nome;
  bool regraUsuarioPadrao;
  List<RegraUsuarioItemDto>? regraUsuarioItemDto;

  RegraUsuarioDto({
    required this.uid,
    required this.empresaUid,
    required this.nome,
    required this.regraUsuarioPadrao,
    this.regraUsuarioItemDto,
  });

  factory RegraUsuarioDto.fromJson(Map<String, dynamic> json) {
    return RegraUsuarioDto(
      uid: json['uid'],
      empresaUid: json['empresaUid'],
      nome: json['nome'],
      regraUsuarioPadrao: json['regraUsuarioPadrao'],
      regraUsuarioItemDto: (json['regraUsuarioItemDto'] as List<dynamic>?)
              ?.map((p) => RegraUsuarioItemDto.fromJson(p))
              .toList() ??
          [],
    );
  }
}