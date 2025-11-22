import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/mao_de_obra_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';

class MaoDeObraService {
  final Dio _dio;

  MaoDeObraService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<MaoDeObraDto>> buscarMaoDeObra(List<ParametroGetDto> parametros) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/MaoDeObra/Buscar",
        "http://127.0.0.1:5089/MaoDeObra/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final maoDeObra = data.map((item) => MaoDeObraDto.fromJson(item)).toList();
        print("Carregadas ${maoDeObra.length} mão-de-obra");
        return maoDeObra;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
