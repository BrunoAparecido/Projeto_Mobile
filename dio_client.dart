import 'package:dio/dio.dart';
import 'package:lotus_mobile/services/storage_service.dart';

class DioClient {
  final Dio _dio;
  final StorageService storageService = StorageService();

  DioClient()
    : _dio = Dio(
        BaseOptions(
          // baseUrl: 'https://lotusplanbackend.lotusprojetos.com.br',
          baseUrl: 'http://127.0.0.1:5089',
          connectTimeout: Duration(minutes: 3),
          receiveTimeout: Duration(minutes: 3),
          sendTimeout: Duration(minutes: 3),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adiciona o token automaticamente em todas as requisições
          final token = await storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Trata erro de autenticação
          if (error.response?.statusCode == 401) {
            // Token expirado, fazer logout ou refresh
            await storageService.deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
