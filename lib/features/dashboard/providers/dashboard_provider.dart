import 'package:flutter/material.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_models.dart';
import '../../../core/auth/permission_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;
  final PermissionService _permissionService;

  DashboardProvider(this._repository, this._permissionService);

  MonitorData? _monitorData;
  MonitorData? get monitorData => _monitorData;

  List<CalendarEvent> _calendarEvents = [];
  List<CalendarEvent> get calendarEvents => _calendarEvents;

  bool _isLoadingMonitor = false;
  bool get isLoadingMonitor => _isLoadingMonitor;

  bool _isLoadingCalendar = false;
  bool get isLoadingCalendar => _isLoadingCalendar;

  String? _monitorError;
  String? get monitorError => _monitorError;

  String? _calendarError;
  String? get calendarError => _calendarError;

  String? _dayDetailError;
  String? get dayDetailError => _dayDetailError;

  Future<void> refreshAll() async {
    await Future.wait([
      fetchMonitorData(),
      fetchCalendarEvents(),
    ]);
  }

  Future<void> fetchMonitorData() async {
    if (!_permissionService.can('monitor_access')) {
      _monitorError = 'Access Denied: You do not have monitor_access capability.';
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
      _calendarError = 'Access Denied: You do not have read_only_operational_views capability.';
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
      _dayDetailError = 'Access Denied: You do not have read_only_operational_views capability.';
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
