import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'package:lotus_mobile/dtos/diario_obra_consultar_dto.dart';
import 'package:lotus_mobile/dtos/parametro_get_dto.dart';

class DiarioObraConsultarService {
  final Dio _dio;

  DiarioObraConsultarService(DioClient dioClient) : _dio = dioClient.dio;

  Future<List<DiarioObraConsultarDto>> buscarDiarioPorProjetoUid(
    List<ParametroGetDto> parametros,
  ) async {
    try {
      final response = await _dio.post(
        //"https://lotusplanbackend.lotusprojetos.com.br/DiarioObraConsultar/Buscar",
        "http://127.0.0.1:5089/DiarioObraConsultar/Buscar?carregarApontamento=true",
        data: parametros.map((e) => e.toJson()).toList(),
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(minutes: 10),
        ),
      );
      final data = response.data;
      print("📦 Response data type: ${data.runtimeType}");
      print("📦 Response content diario obra consultar: $data");

      if (data == null) {
        return [];
      }

      // CORREÇÃO: O JSON retorna um objeto com a propriedade "diarioObra"
      // que contém a lista de diários
      List<dynamic> diariosLista;

      if (data is Map<String, dynamic>) {
        // Caso 1: Response é um objeto com propriedade "diarioObra"
        final diarioObraData = data['diarioObra'];

        if (diarioObraData == null ||
            (diarioObraData is List && diarioObraData.isEmpty)) {
          return [];
        }

        if (diarioObraData is! List) {
          throw Exception(
            "Formato inválido: 'diarioObra' deveria ser uma lista, mas é ${diarioObraData.runtimeType}",
          );
        }

        diariosLista = diarioObraData;
      } else if (data is List) {
        // Caso 2: Response já é uma lista diretamente
        if (data.isEmpty) {
          return [];
        }
        diariosLista = data;
      } else {
        throw Exception(
          "Formato de resposta inesperado. Tipo recebido: ${data.runtimeType}",
        );
      }

      // Mapeia os dados para DTOs
      return diariosLista.map((item) {
        final mapItem = Map<String, dynamic>.from(item as Map<String, dynamic>);

        if (mapItem['diarioObra'] != null && mapItem['diarioObra'] is List) {
          final lista = mapItem['diarioObra'] as List;

          // Filtrar antes de converter
          mapItem['diarioObra'] = lista
              .where((d) => (d['statusObraEnum'] ?? -1) == 0)
              .toList();
        }

        return DiarioObraConsultarDto.fromJson(mapItem);
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        "Erro na requisição: ${e.response?.statusCode} - ${e.response?.data ?? e.message}",
      );
    } catch (e) {
      throw Exception("Erro ao processar dados: $e");
    }
  }
}
