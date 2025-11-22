import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:lotus_mobile/dtos/projeto_dto.dart';

class ProjetoService {
  final Dio _dio;

  ProjetoService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<ProjetoDto>> buscarPorUsuario(List<ParametroGetDto> parametros, String uid) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Projeto/BuscarPorUsuario?usuarioUid=$uid",
        "http://127.0.0.1:5089/Projeto/BuscarPorUsuario?usuarioUid=$uid",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      // ✅ O backend retorna uma lista com 1 usuário
      if (data is List && data.isNotEmpty) {
        final projetos = data.map((item) => ProjetoDto.fromJson(item)).toList();
        return projetos;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
