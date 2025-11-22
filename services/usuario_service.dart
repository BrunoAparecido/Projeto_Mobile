import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:lotus_mobile/dtos/usuario_dto.dart';

class UsuarioService {
  final Dio _dio;

  UsuarioService(DioClient dioClient) : _dio = dioClient.dio;

  Future<UsuarioDto> buscar(List<ParametroGetDto> parametros) async {
    print("🚀 Entrou em usuarioService.buscar()");
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Usuario/Buscar",
        "http://127.0.0.1:5089/Usuario/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("🧩 JSON recebido no UsuarioService: ${data.first}");
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      // ✅ O backend retorna uma lista com 1 usuário
      if (data is List && data.isNotEmpty) {
        return UsuarioDto.fromJson(data.first);
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
