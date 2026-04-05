import 'package:flutter/material.dart';
import '../data/vendor_repository.dart';
import '../../../core/models/vendor.dart';
import 'package:dio/dio.dart';

class VendorProvider extends ChangeNotifier {
  final VendorRepository _repository;

  List<Vendor> _vendors = [];
  List<RentalVendor> _rentalVendors = [];
  
  bool _isVendorsLoading = false;
  String? _vendorsError;
  
  bool _isRentalVendorsLoading = false;
  String? _rentalVendorsError;

  String _vendorSearchQuery = '';
  String _rentalVendorSearchQuery = '';

  VendorProvider(this._repository);

  // Getters for Vendors
  List<Vendor> get vendors {
    if (_vendorSearchQuery.isEmpty) return _vendors;
    return _vendors.where((v) => 
      v.name.toLowerCase().contains(_vendorSearchQuery.toLowerCase()) ||
      v.place.toLowerCase().contains(_vendorSearchQuery.toLowerCase()) ||
      v.phone.contains(_vendorSearchQuery)
    ).toList();
  }
  bool get isVendorsLoading => _isVendorsLoading;
  String? get vendorsError => _vendorsError;

  // Getters for Rental Vendors
  List<RentalVendor> get rentalVendors {
    if (_rentalVendorSearchQuery.isEmpty) return _rentalVendors;
    return _rentalVendors.where((v) => 
      v.name.toLowerCase().contains(_rentalVendorSearchQuery.toLowerCase()) ||
      v.place.toLowerCase().contains(_rentalVendorSearchQuery.toLowerCase()) ||
      v.phone.contains(_rentalVendorSearchQuery)
    ).toList();
  }
  bool get isRentalVendorsLoading => _isRentalVendorsLoading;
  String? get rentalVendorsError => _rentalVendorsError;

  void setVendorSearchQuery(String query) {
    _vendorSearchQuery = query;
    notifyListeners();
  }

  void setRentalVendorSearchQuery(String query) {
    _rentalVendorSearchQuery = query;
    notifyListeners();
  }

  String _extractErrorMessage(DioException e) {
    final dynamic data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          // Handle Pydantic validation errors which often come as a list of dicts
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) return first['msg'];
        }
      }
      if (data.containsKey('message')) return data['message'];
    }
    return e.message ?? 'An unknown error occurred';
  }

  Future<void> fetchVendors() async {
    _isVendorsLoading = true;
    _vendorsError = null;
    notifyListeners();

    try {
      _vendors = await _repository.getVendors();
    } on DioException catch (e) {
      _vendorsError = _extractErrorMessage(e);
    } catch (e) {
      _vendorsError = e.toString();
    } finally {
      _isVendorsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRentalVendors() async {
    _isRentalVendorsLoading = true;
    _rentalVendorsError = null;
    notifyListeners();

    try {
      _rentalVendors = await _repository.getRentalVendors();
    } on DioException catch (e) {
      _rentalVendorsError = _extractErrorMessage(e);
    } catch (e) {
      _rentalVendorsError = e.toString();
    } finally {
      _isRentalVendorsLoading = false;
      notifyListeners();
    }
  }

  Future<void> createVendor({
    String? vendorId,
    required String name,
    String? place,
    String? phone,
  }) async {
    try {
      await _repository.createVendor(
        vendorId: vendorId,
        name: name,
        place: place,
        phone: phone,
      );
      await fetchVendors();
    } on DioException catch (e) {
      _vendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> updateVendor(String id, {
    required String name,
    String? place,
    String? phone,
  }) async {
    try {
      await _repository.updateVendor(
        id,
        name: name,
        place: place,
        phone: phone,
      );
      await fetchVendors();
    } on DioException catch (e) {
      _vendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> deleteVendor(String id) async {
    try {
      await _repository.deleteVendor(id);
      await fetchVendors();
    } on DioException catch (e) {
      _vendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> createRentalVendor({
    String? rentalVendorId,
    required String name,
    String? place,
    String? phone,
  }) async {
    try {
      await _repository.createRentalVendor(
        rentalVendorId: rentalVendorId,
        name: name,
        place: place,
        phone: phone,
      );
      await fetchRentalVendors();
    } on DioException catch (e) {
      _rentalVendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> updateRentalVendor(String id, {
    required String name,
    String? place,
    String? phone,
  }) async {
    try {
      await _repository.updateRentalVendor(
        id,
        name: name,
        place: place,
        phone: phone,
      );
      await fetchRentalVendors();
    } on DioException catch (e) {
      _rentalVendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  Future<void> deleteRentalVendor(String id) async {
    try {
      await _repository.deleteRentalVendor(id);
      await fetchRentalVendors();
    } on DioException catch (e) {
      _rentalVendorsError = _extractErrorMessage(e);
      rethrow;
    }
  }

  void clearErrors() {
    _vendorsError = null;
    _rentalVendorsError = null;
    notifyListeners();
  }
}
