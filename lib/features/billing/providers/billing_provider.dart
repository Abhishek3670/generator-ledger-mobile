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

  final Map<int, double> _rates = {};
  Map<int, double> get rates => _rates;

  final Set<String> _paidBookings = {};

  void setRate(int capacity, double rate) {
    _rates[capacity] = rate;
    notifyListeners();
  }

  void togglePaymentStatus(String bookingId) {
    if (_paidBookings.contains(bookingId)) {
      _paidBookings.remove(bookingId);
    } else {
      _paidBookings.add(bookingId);
    }
    notifyListeners();
  }

  bool isPaid(String bookingId) => _paidBookings.contains(bookingId);

  double getAmountForCapacity(int? capacity) {
    if (capacity == null) return 0.0;
    return _rates[capacity] ?? 0.0;
  }

  double get totalRevenue {
    double total = 0;
    for (var row in filteredRows) {
      if (isPaid(row.bookingId)) {
        total += getAmountForCapacity(row.capacityKva);
      }
    }
    return total;
  }

  double get totalPending {
    double total = 0;
    for (var row in filteredRows) {
      if (!isPaid(row.bookingId)) {
        total += getAmountForCapacity(row.capacityKva);
      }
    }
    return total;
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
      // Auto-populate default rates to 0 if not present
      if (_billingData != null) {
        for (var capacity in _billingData!.capacities) {
          _rates.putIfAbsent(capacity, () => 0.0);
        }
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
