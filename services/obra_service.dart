import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/obra_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';

class ObraService {
  final Dio _dio;

  ObraService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<ObraDto>> buscarObra(List<ParametroGetDto> parametros) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Obra/Buscar",
        "http://127.0.0.1:5089/Obra/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final obras = data.map((item) => ObraDto.fromJson(item)).toList();
        print(obras.first.obraContratados);
        print(obras.last.obraContratados);
        return obras;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
