
class RegraUsuarioItemDto {
  String uid;
  String empresaUid;
  bool selecionar = false;
  String funcaoRegraUsuarioTexto;
  int funcaoRegraUsuario;

  RegraUsuarioItemDto({
    required this.uid,
    required this.empresaUid,
    required this.selecionar,
    required this.funcaoRegraUsuario,
    required this.funcaoRegraUsuarioTexto
  });

  factory RegraUsuarioItemDto.fromJson(Map<String, dynamic> json) {
    return RegraUsuarioItemDto(
      uid: json['uid'],
      empresaUid: json['empresaUid'],
      selecionar: json['selecionar'],
      funcaoRegraUsuario: json['funcaoRegraUsuario'],
      funcaoRegraUsuarioTexto: json['funcaoRegraUsuarioTexto'],
    );
  }
}