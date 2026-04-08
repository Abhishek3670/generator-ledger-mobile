import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/booking_repository.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  List<Booking> _bookings = [];
  BookingWithItems? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  BookingProvider(this._repository);

  List<Booking> get bookings => _bookings;
  BookingWithItems? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _extractErrorMessage(DioException e) {
    final dynamic data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) return first['msg'];
        }
      }
      if (data.containsKey('message')) return data['message'];
    }
    return e.message ?? 'An unknown error occurred';
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _repository.getBookings();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookingDetails(String bookingId) async {
    _isLoading = true;
    _error = null;
    _selectedBooking = null;
    notifyListeners();

    try {
      _selectedBooking = await _repository.getBookingDetails(bookingId);
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required String vendorId,
    required List<Map<String, dynamic>> items,
  }) async {
    _error = null;
    try {
      final result =
          await _repository.createBooking(vendorId: vendorId, items: items);
      await fetchBookings();
      return result;
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      if (e.response?.statusCode == 409) {
        // Return the 409 payload for the UI to handle suggestions
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> addBookingItem(
    String bookingId, {
    String? generatorId,
    int? capacityKva,
    required String startDt,
    required String endDt,
    String? remarks,
  }) async {
    _error = null;
    try {
      await _repository.addBookingItem(
        bookingId,
        generatorId: generatorId,
        capacityKva: capacityKva,
        startDt: startDt,
        endDt: endDt,
        remarks: remarks,
      );
      await fetchBookingDetails(bookingId);
      await fetchBookings();
      return {'success': true};
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      if (e.response?.statusCode == 409) {
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> bulkUpdateItems(
    String bookingId, {
    required List<Map<String, dynamic>> updates,
    required List<int> removes,
  }) async {
    _error = null;
    try {
      await _repository.bulkUpdateItems(bookingId,
          updates: updates, removes: removes);
      await fetchBookingDetails(bookingId);
      await fetchBookings();
      return {'success': true};
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      if (e.response?.statusCode == 409) {
        return e.response?.data;
      }
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _repository.cancelBooking(bookingId, reason);
      await fetchBookingDetails(bookingId);
      await fetchBookings();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _repository.deleteBooking(bookingId);
      await fetchBookings();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
