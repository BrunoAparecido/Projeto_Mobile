import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lotus_mobile/dtos/login_dto.dart';

class LoginService{
  // String baseUrl = "https://lotusplanbackend.lotusprojetos.com.br/Autenticacao";
  String baseUrl = "http://127.0.0.1:5089/Autenticacao";

  Future<LoginResponseDto?> login({required String email, required String senha}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/Login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'senha': senha,
    }),
  );
  print(response.body);
  print(response.statusCode);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    print(json);
    return LoginResponseDto.fromJson(json);
  } else if (response.statusCode == 401) {
    throw Exception("Usuário ou senha inválidos");
  } else {
    throw Exception("Erro no servidor: ${response.statusCode}");
  }
}
}