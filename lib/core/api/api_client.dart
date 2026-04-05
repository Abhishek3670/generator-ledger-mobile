import 'package:dio/dio.dart';
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
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Trigger logout in AuthProvider to update UI immediately
          _authProvider.logout();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
