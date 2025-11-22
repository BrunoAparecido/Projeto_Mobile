import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:lotus_mobile/database/database.dart';
import 'dart:typed_data';

class ImageService {
  final Dio _dio;
  final AppDatabase _database;

  ImageService(this._dio, this._database);

  Future<bool> uploadImagem(String filePath, String guidControleUpload) async {
    try {
      // filename deve ser o GUID (sem extensão)
      final fileToSend = await MultipartFile.fromFile(
        filePath,
        filename: guidControleUpload,
      );

      final formData = FormData.fromMap({
        'files': [fileToSend],
      });

      print('📤 Enviando imagem: $guidControleUpload');

      final response = await _dio.post(
        '/DiarioObra/UploadAnexo',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Upload concluído para guidControleUpload=$guidControleUpload');
        return true;
      } else {
        print(
          '❌ Falha no upload (status ${response.statusCode}) para guidControleUpload=$guidControleUpload',
        );

        if (response.data != null) {
          print('Resposta do servidor: ${response.data}');
        }

        return false;
      }
    } on DioException catch (e) {
      print('❌ DioException no upload: ${e.message}');

      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
      }

      return false;
    } catch (e, st) {
      print('❌ Erro ao fazer upload da imagem: $e\n$st');
      return false;
    }
  }

  Future<void> limparCacheAntigo({int diasParaManter = 30}) async {
    try {
      final dataLimite = DateTime.now().subtract(
        Duration(days: diasParaManter),
      );

      await (_database.delete(_database.diarioObraAnexoImagem)..where(
            (tbl) => tbl.dataDownload.isSmallerThan(
              Value(dataLimite) as Expression<DateTime>,
            ),
          ))
          .go();

      print(
        '🧹 Cache de imagens antigas limpo (mantidos últimos $diasParaManter dias)',
      );
    } catch (e, st) {
      print('Erro ao limpar cache: $e\n$st');
    }
  }
}

