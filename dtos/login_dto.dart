class LoginRequestDto {
  String email;
  String senha;

  LoginRequestDto({ required this.email, required this.senha});
}

class LoginResponseDto{
  bool sucesso;
  String data;
  String uid;
  String regraUsuarioItem;
  String? listMensagem;

  LoginResponseDto({ required this.sucesso, required this.data, required this.uid, required this.regraUsuarioItem, this.listMensagem});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      sucesso: json['sucesso'],       
      data: json['data'],       
      uid: json['uid'],
      regraUsuarioItem: json['regraUsuarioItem'],
      listMensagem: json['listMensagem']  
    );
  }
}