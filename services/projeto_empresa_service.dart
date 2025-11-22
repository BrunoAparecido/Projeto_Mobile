import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';
import 'package:lotus_mobile/dtos/projeto_empresa_dto.dart';

class ProjetoEmpresaService {
  final Dio _dio;

  ProjetoEmpresaService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<ProjetoEmpresaDto>> buscarProjetoEmpresa(List<ParametroGetDto> parametros) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/ProjetoEmpresa/Buscar",
        "http://127.0.0.1:5089/ProjetoEmpresa/Buscar",
        data: parametros.map((e) => e.toJson()).toList(),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content: $data");

      if (data is List && data.isNotEmpty) {
        final projetoEmpresas = data.map((item) => ProjetoEmpresaDto.fromJson(item)).toList();
        return projetoEmpresas;
      } else {
        throw Exception("Resposta inesperada: $data");
      }
      } on DioException catch (e) {
      throw Exception("Erro na requisiçao: ${e.response?.data ?? e.message}");
    }
  }
}
