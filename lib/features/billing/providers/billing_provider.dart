import 'package:flutter/material.dart';
import '../data/billing_repository.dart';
import '../models/billing_models.dart';
import '../../../core/auth/permission_service.dart';

class BillingProvider extends ChangeNotifier {
  final BillingRepository _repository;
  final PermissionService _permissionService;

  BillingProvider(this._repository, this._permissionService);

  BillingLinesResponse? _billingData;
  BillingLinesResponse? get billingData => _billingData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int? _capacityFilter;
  int? get capacityFilter => _capacityFilter;

  void setCapacityFilter(int? capacity) {
    _capacityFilter = capacity;
    notifyListeners();
  }

  List<BillingLineRow> get filteredRows {
    if (_billingData == null) return [];
    if (_capacityFilter == null) return _billingData!.rows;
    return _billingData!.rows
        .where((row) => row.capacityKva == _capacityFilter)
        .toList();
  }

  Future<void> fetchBillingLines({
    required String from,
    required String to,
  }) async {
    if (!_permissionService.can(PermissionService.billingAccess)) {
      _error = 'Access Denied: You do not have billing_access capability.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _billingData = await _repository.getBillingLines(from: from, to: to);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
