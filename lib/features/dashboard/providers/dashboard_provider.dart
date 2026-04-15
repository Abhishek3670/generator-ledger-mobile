import 'package:flutter/material.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_models.dart';
import '../../../core/auth/permission_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;
  final PermissionService _permissionService;

  DashboardProvider(this._repository, this._permissionService);

  DashboardSummary? _summaryData;
  DashboardSummary? get summaryData => _summaryData;

  List<DashboardAlert> _alerts = [];
  List<DashboardAlert> get alerts => _alerts;

  MonitorData? _monitorData;
  MonitorData? get monitorData => _monitorData;

  List<CalendarEvent> _calendarEvents = [];
  List<CalendarEvent> get calendarEvents => _calendarEvents;

  bool _isLoadingSummary = false;
  bool get isLoadingSummary => _isLoadingSummary;

  bool _isLoadingAlerts = false;
  bool get isLoadingAlerts => _isLoadingAlerts;

  bool _isLoadingMonitor = false;
  bool get isLoadingMonitor => _isLoadingMonitor;

  bool _isLoadingCalendar = false;
  bool get isLoadingCalendar => _isLoadingCalendar;

  String? _summaryError;
  String? get summaryError => _summaryError;

  String? _alertsError;
  String? get alertsError => _alertsError;

  String? _monitorError;
  String? get monitorError => _monitorError;

  String? _calendarError;
  String? get calendarError => _calendarError;

  String? _dayDetailError;
  String? get dayDetailError => _dayDetailError;

  bool get canBillingAccess => _permissionService.can('billing_access');

  Future<void> refreshAll() async {
    await Future.wait([
      fetchSummaryData(),
      fetchCalendarEvents(),
      fetchAlerts(),
      fetchMonitorData(),
    ]);
  }

  Future<void> fetchSummaryData() async {
    _isLoadingSummary = true;
    _summaryError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getGeneratorCount(),
        _repository.getGeneratorCount(activeOnly: true),
        _repository.getBookingCount(),
        _repository.getBookingCount(onlyConfirmed: true),
        _repository.getVendorCount(),
      ]);

      _summaryData = DashboardSummary(
        totalGenerators: results[0] as int,
        activeGenerators: results[1] as int,
        totalBookings: results[2] as int,
        confirmedBookings: results[3] as int,
        totalVendors: results[4] as int,
        todayBookings: 0, // No specific endpoint or metadata for "today" in current JSON contracts
        pendingInvoices: null, // No backend contract available
        pendingInvoicesAmount: null, // No backend contract available
        overdueAlerts: null, // No backend contract available
      );
    } catch (e) {
      _summaryError = e.toString();
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> fetchAlerts() async {
    _isLoadingAlerts = true;
    _alertsError = null;
    notifyListeners();

    try {
      // Codex confirmed no alert or notification endpoint exists.
      // Truthful empty state is represented by an empty list.
      _alerts = [];
    } catch (e) {
      _alertsError = e.toString();
    } finally {
      _isLoadingAlerts = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonitorData() async {
    if (!_permissionService.can('monitor_access')) {
      _monitorError =
          'Access Denied: You do not have monitor_access capability.';
      notifyListeners();
      return;
    }

    _isLoadingMonitor = true;
    _monitorError = null;
    notifyListeners();

    try {
      _monitorData = await _repository.getMonitorData();
    } catch (e) {
      _monitorError = e.toString();
    } finally {
      _isLoadingMonitor = false;
      notifyListeners();
    }
  }

  Future<void> fetchCalendarEvents() async {
    if (!_permissionService.can('read_only_operational_views')) {
      _calendarError =
          'Access Denied: You do not have read_only_operational_views capability.';
      notifyListeners();
      return;
    }

    _isLoadingCalendar = true;
    _calendarError = null;
    notifyListeners();

    try {
      _calendarEvents = await _repository.getCalendarEvents();
    } catch (e) {
      _calendarError = e.toString();
    } finally {
      _isLoadingCalendar = false;
      notifyListeners();
    }
  }

  Future<DayDetail?> fetchDayDetail(String date) async {
    if (!_permissionService.can('read_only_operational_views')) {
      _dayDetailError =
          'Access Denied: You do not have read_only_operational_views capability.';
      notifyListeners();
      return null;
    }

    _dayDetailError = null;
    try {
      return await _repository.getDayDetail(date);
    } catch (e) {
      _dayDetailError = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
