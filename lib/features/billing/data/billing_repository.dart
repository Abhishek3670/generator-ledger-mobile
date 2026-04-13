import 'package:dio/dio.dart';
import '../models/billing_models.dart';
import '../../../core/api/api_client.dart';

class BillingRepository {
  final ApiClient _apiClient;

  BillingRepository(this._apiClient);

  Future<BillingLinesResponse> getBillingLines({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/billing/lines',
        queryParameters: {
          'from': from,
          'to': to,
        },
      );
      return BillingLinesResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final detail = e.response?.data['detail'];
        throw Exception(detail ?? 'Invalid date range or format.');
      }
      rethrow;
    }
  }
}
