import '../../../core/api/api_client.dart';
import '../../../core/models/vendor.dart';

class VendorRepository {
  final ApiClient _apiClient;

  VendorRepository(this._apiClient);

  Future<List<Vendor>> getVendors() async {
    final response = await _apiClient.dio.get('/api/vendors');
    final List<dynamic> data = response.data;
    return data.map((json) => Vendor.fromJson(json)).toList();
  }

  Future<void> createVendor({
    String? vendorId,
    required String name,
    String? place,
    String? phone,
  }) async {
    await _apiClient.dio.post('/api/vendors', data: {
      if (vendorId != null && vendorId.isNotEmpty) 'vendor_id': vendorId,
      'vendor_name': name,
      'vendor_place': place,
      'phone': phone,
    });
  }

  Future<void> updateVendor(
    String id, {
    required String name,
    String? place,
    String? phone,
  }) async {
    await _apiClient.dio.patch('/api/vendors/$id', data: {
      'vendor_name': name,
      'vendor_place': place,
      'phone': phone,
    });
  }

  Future<void> deleteVendor(String id) async {
    await _apiClient.dio.delete('/api/vendors/$id');
  }

  Future<List<RentalVendor>> getRentalVendors() async {
    final response = await _apiClient.dio.get('/api/rental-vendors');
    final List<dynamic> data = response.data;
    return data.map((json) => RentalVendor.fromJson(json)).toList();
  }

  Future<void> createRentalVendor({
    String? rentalVendorId,
    required String name,
    String? place,
    String? phone,
  }) async {
    await _apiClient.dio.post('/api/rental-vendors', data: {
      if (rentalVendorId != null && rentalVendorId.isNotEmpty)
        'rental_vendor_id': rentalVendorId,
      'vendor_name': name,
      'vendor_place': place,
      'phone': phone,
    });
  }

  Future<void> updateRentalVendor(
    String id, {
    required String name,
    String? place,
    String? phone,
  }) async {
    await _apiClient.dio.patch('/api/rental-vendors/$id', data: {
      'vendor_name': name,
      'vendor_place': place,
      'phone': phone,
    });
  }

  Future<void> deleteRentalVendor(String id) async {
    await _apiClient.dio.delete('/api/rental-vendors/$id');
  }
}
