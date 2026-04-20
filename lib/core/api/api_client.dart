import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_provider.dart';
import 'api_config.dart';

class ApiClient {
  late final Dio _dio;
  final AuthProvider _authProvider;

  ApiClient(this._authProvider) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authProvider.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Fallback logic for connection issues
        final isConnectionError = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;

        if (isConnectionError && _dio.options.baseUrl == ApiConfig.primaryBaseUrl) {
          debugPrint('Primary backend (.71) unreachable. Trying fallback (.60)...');
          _dio.options.baseUrl = ApiConfig.fallbackBaseUrl;
          
          final options = e.requestOptions;
          options.baseUrl = ApiConfig.fallbackBaseUrl;
          
          try {
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          } catch (err) {
            return handler.next(e);
          }
        }

        // Existing 401 handling
        final skipAuthHandler =
            e.requestOptions.extra['skipAuthHandler'] == true;

        if (e.response?.statusCode == 401 && !skipAuthHandler) {
          _authProvider.logout();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
