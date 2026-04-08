import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/booking.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository(this._apiClient);

  Future<List<Booking>> getBookings() async {
    final response = await _apiClient.dio.get('/api/bookings');
    final List<dynamic> data = response.data;
    return data.map((json) => Booking.fromJson(json)).toList();
  }

  Future<BookingWithItems> getBookingDetails(String bookingId) async {
    final response = await _apiClient.dio.get('/api/bookings/$bookingId');
    return BookingWithItems.fromJson(response.data);
  }

  Future<Map<String, dynamic>> createBooking({
    required String vendorId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _apiClient.dio.post(
      '/api/bookings',
      data: {
        'vendor_id': vendorId,
        'items': items,
      },
    );
    return response.data;
  }

  Future<void> addBookingItem(
    String bookingId, {
    String? generatorId,
    int? capacityKva,
    required String startDt,
    required String endDt,
    String? remarks,
  }) async {
    final formData = FormData.fromMap({
      if (generatorId != null) 'generator_id': generatorId,
      if (capacityKva != null) 'capacity_kva': capacityKva,
      'start_dt': startDt,
      'end_dt': endDt,
      if (remarks != null) 'remarks': remarks,
    });

    await _apiClient.dio.post(
      '/api/bookings/$bookingId/items',
      data: formData,
    );
  }

  Future<void> bulkUpdateItems(
    String bookingId, {
    required List<Map<String, dynamic>> updates,
    required List<int> removes,
  }) async {
    await _apiClient.dio.post(
      '/api/bookings/$bookingId/items/bulk-update',
      data: {
        'updates': updates,
        'removes': removes,
      },
    );
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    final formData = FormData.fromMap({
      'reason': reason,
    });
    await _apiClient.dio.post(
      '/api/bookings/$bookingId/cancel',
      data: formData,
    );
  }

  Future<void> deleteBooking(String bookingId) async {
    await _apiClient.dio.delete('/api/bookings/$bookingId');
  }

  Future<Map<String, dynamic>> getVendorBookings(String vendorId) async {
    final response =
        await _apiClient.dio.get('/api/vendors/$vendorId/bookings');
    return response.data;
  }
}
