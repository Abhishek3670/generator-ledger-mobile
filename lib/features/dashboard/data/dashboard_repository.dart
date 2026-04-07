import 'package:dio/dio.dart';
import '../models/dashboard_models.dart';
import '../../../core/api/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<MonitorData> getMonitorData() async {
    try {
      final response = await _apiClient.dio.get('/api/monitor/live');
      return MonitorData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      final response = await _apiClient.dio.get('/api/calendar/events');
      return (response.data as List)
          .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<DayDetail> getDayDetail(String date) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/calendar/day',
        queryParameters: {'date': date},
      );
      return DayDetail.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
