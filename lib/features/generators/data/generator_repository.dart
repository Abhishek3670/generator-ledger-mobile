import '../../../core/api/api_client.dart';
import '../../../core/models/generator.dart';

class GeneratorRepository {
  final ApiClient _apiClient;

  GeneratorRepository(this._apiClient);

  Future<List<Generator>> getGenerators() async {
    final response = await _apiClient.dio.get('/api/generators');
    final List<dynamic> data = response.data;
    return data.map((json) => Generator.fromJson(json)).toList();
  }

  Future<void> createGenerator({
    required int capacityKva,
    required String type,
    String? identification,
    String? notes,
    required String status,
    required String inventoryType,
    String? rentalVendorId,
  }) async {
    await _apiClient.dio.post('/api/generators', data: {
      'capacity_kva': capacityKva,
      'type': type,
      'identification': identification,
      'notes': notes,
      'status': status,
      'inventory_type': inventoryType,
      if (rentalVendorId != null && rentalVendorId.isNotEmpty)
        'rental_vendor_id': rentalVendorId,
    });
  }

  Future<void> updateGenerator(
    String id, {
    required int capacityKva,
    required String type,
    String? identification,
    String? notes,
    required String status,
    required String inventoryType,
    String? rentalVendorId,
  }) async {
    await _apiClient.dio.patch('/api/generators/$id', data: {
      'capacity_kva': capacityKva,
      'type': type,
      'identification': identification,
      'notes': notes,
      'status': status,
      'inventory_type': inventoryType,
      'rental_vendor_id': rentalVendorId,
    });
  }

  Future<Map<String, dynamic>> getGeneratorBookings(
      String id, String date) async {
    final response = await _apiClient.dio
        .get('/api/generators/$id/bookings', queryParameters: {'date': date});
    return response.data;
  }
}
