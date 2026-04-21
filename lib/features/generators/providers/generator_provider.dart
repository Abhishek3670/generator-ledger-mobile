import 'package:flutter/material.dart';
import '../data/generator_repository.dart';
import '../../../core/models/generator.dart';
import 'package:dio/dio.dart';

class GeneratorProvider extends ChangeNotifier {
  final GeneratorRepository _repository;

  List<Generator> _generators = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  GeneratorProvider(this._repository);

  List<Generator> get generators {
    if (_searchQuery.isEmpty) return _generators;
    return _generators
        .where((g) =>
            g.capacity.toString().contains(_searchQuery) ||
            g.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.identification.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

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

  Future<void> fetchGenerators() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _generators = await _repository.getGenerators();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    try {
      await _repository.createGenerator(
        capacityKva: capacityKva,
        type: type,
        identification: identification,
        notes: notes,
        status: status,
        inventoryType: inventoryType,
        rentalVendorId: rentalVendorId,
      );
      await fetchGenerators();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      rethrow;
    }
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
    try {
      await _repository.updateGenerator(
        id,
        capacityKva: capacityKva,
        type: type,
        identification: identification,
        notes: notes,
        status: status,
        inventoryType: inventoryType,
        rentalVendorId: rentalVendorId,
      );
      await fetchGenerators();
    } on DioException catch (e) {
      _error = _extractErrorMessage(e);
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getGeneratorBookings(String id, String date) async {
    return await _repository.getGeneratorBookings(id, date);
  }
}
