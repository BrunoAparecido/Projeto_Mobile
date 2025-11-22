import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/contato_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';

class ContatoService {
  final Dio _dio;

  ContatoService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<Contato>> buscarTodos(List<ParametroGetDto> parametros) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Obra/Buscar",
        "http://127.0.0.1:5089/Contato/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final contato = data.map((item) => Contato.fromJson(item)).toList();
        print(contato);
        print(contato.first.nome);
        return contato;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }

  Future<List<Contato>> buscarGrupoLotus(List<ParametroGetDto> parametros) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Obra/Buscar",
        "http://127.0.0.1:5089/Contato/BuscarGrupoLotus",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final contatoGrupoLotus = data.map((item) => Contato.fromJson(item)).toList();
        print(contatoGrupoLotus);
        print(contatoGrupoLotus.first.nome);
        return contatoGrupoLotus;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
