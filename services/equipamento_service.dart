import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/equipamento_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';

class EquipamentoService {
  final Dio _dio;

  EquipamentoService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<EquipamentoDto>> buscarEquipamento(List<ParametroGetDto> parametros) async {
    print("🔄 Carregando equipamentos...");
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/Equipamento/Buscar",
        "http://127.0.0.1:5089/Equipamento/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final equipamentos = data.map((item) => EquipamentoDto.fromJson(item)).toList();
        print("Carregados ${equipamentos.length} equipamentos");
        return equipamentos;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
