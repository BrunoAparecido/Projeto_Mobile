import 'package:dio/dio.dart';
import 'package:lotus_mobile/dio_client.dart';
import 'dart:io';

import 'package:lotus_mobile/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final DioClient _dioClient;
  final StorageService storageService;

  ImageUploadService(this._dioClient, this.storageService);

  Future<bool> uploadImagem(String guidControleUpload, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'guidControleUpload': guidControleUpload,
        'files': await MultipartFile.fromFile(
          imageFile.path,
          filename:
              '$guidControleUpload.png',
        ),
      });

      final response = await _dioClient.dio.post(
        '/DiarioObra/UploadAnexo', 
        data: formData,
        options: Options(
          // Não defina 'Content-Type' aqui — Dio cuida do boundary
          validateStatus: (status) => status != null && status < 500,
        ),
        onSendProgress: (sent, total) {
          print('upload progress: $guidControleUpload $sent/$total');
        },
      );

      print('📤 Request URI: ${response.requestOptions.uri}');
      print('📤 Status: ${response.statusCode}');
      print('📤 Response data: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ DioException ao enviar $guidControleUpload: ${e.type}');
      print('❌ Request URI: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('❌ Status code: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      } else {
        print('❌ Sem resposta (problema de conexão). Mensagem: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Erro genérico ao enviar $guidControleUpload: $e');
      return false;
    }
  }

  Future<Map<String, bool>> uploadMultiplasImagens(
    Map<String, File> imagens,
  ) async {
    final resultados = <String, bool>{};

    for (var entry in imagens.entries) {
      final guid = entry.key;
      final file = entry.value;

      print('📤 Enviando imagem: $guid');
      final sucesso = await uploadImagem(guid, file);
      resultados[guid] = sucesso;

      if (sucesso) {
        print('✅ Imagem enviada com sucesso: $guid');
      } else {
        print('❌ Falha ao enviar imagem: $guid');
      }
    }

    return resultados;
  }
}
