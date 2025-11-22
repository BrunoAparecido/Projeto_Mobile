import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';

class PdfService {
  final DioClient _dioClient;

  PdfService(this._dioClient);

  /// Gera o PDF do diário de obra no backend e retorna os bytes
  Future<List<int>> gerarPdfDiarioObra(String diarioObraUid) async {
    try {
      final response = await _dioClient.dio.get(
        '/DiarioObra/GerarPdfDiarioObra',
        queryParameters: {'diarioObraUid': diarioObraUid},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Erro ao gerar PDF: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Diário de obra não encontrado.');
      }
      throw Exception('Erro ao gerar PDF: ${e.message}');
    }
  }
}