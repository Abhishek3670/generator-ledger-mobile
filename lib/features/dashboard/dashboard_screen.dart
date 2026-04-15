import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'providers/dashboard_provider.dart';
import 'models/dashboard_models.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../widgets/shared/corporate_app_bar.dart';
import 'widgets/dashboard_asset_row.dart';
import 'widgets/summary_metrics_grid.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/alerts_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // Default to month for parity
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DayDetail? _selectedDayDetail;
  bool _isLoadingDayDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refreshAll();
    });
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _isLoadingDayDetail = true;
        _selectedDayDetail = null;
      });

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
      try {
        final detail =
            await context.read<DashboardProvider>().fetchDayDetail(dateStr);
        if (mounted) {
          setState(() {
            _selectedDayDetail = detail;
          });
        }
      } catch (e) {
        // Error is tracked in the provider's dayDetailError
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingDayDetail = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Premium off-white background
      appBar: CorporateAppBar(
        title: 'Genset Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1A237E)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshAll(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Metrics
              if (provider.isLoadingSummary)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.summaryData != null)
                SummaryMetricsGrid(summary: provider.summaryData!)
              else if (provider.summaryError != null)
                ErrorState(
                  message: 'Metrics: ${provider.summaryError}',
                  onRetry: () => provider.fetchSummaryData(),
                ),

              // 2. Quick Actions
              const QuickActionsGrid(),

              // 3. Alerts
              if (provider.isLoadingAlerts)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LoadingState(message: 'Loading alerts...'),
                )
              else if (provider.alertsError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ErrorState(
                    message: 'Alerts: ${provider.alertsError}',
                    onRetry: () => provider.fetchAlerts(),
                  ),
                )
              else
                AlertsPanel(alerts: provider.alerts),

              // 4. Operational Calendar
              _buildCalendarSection(provider),

              // 5. Day Details
              if (_selectedDay != null) _buildDayDetailSection(provider),

              // 7. System Monitor (Secondary)
              _buildMonitorPanel(provider),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitorPanel(DashboardProvider provider) {
    if (provider.isLoadingMonitor) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingState(message: 'Updating monitor...'),
      );
    }

    if (provider.monitorError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorState(
          message: provider.monitorError!,
          onRetry: () => provider.fetchMonitorData(),
        ),
      );
    }

    final data = provider.monitorData;
    if (data == null) return const SizedBox.shrink();

    return ExpansionTile(
      title: const Text('System Infrastructure Health',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMonitorCard(
                      'CPU',
                      '${data.cpu.percent}%',
                      data.cpu.status,
                      Icons.developer_board,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMonitorCard(
                      'Memory',
                      '${data.memory.percent}%',
                      data.memory.status,
                      Icons.memory,
                      subtitle:
                          '${data.memory.usedMb.toInt()} / ${data.memory.totalMb.toInt()} MB',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTemperatureCard(data.temperature),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonitorCard(
      String title, String value, String status, IconData icon,
      {String? subtitle}) {
    Color statusColor;
    switch (status) {
      case 'normal':
        statusColor = Colors.green;
        break;
      case 'high':
        statusColor = Colors.orange;
        break;
      case 'critical':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: Semantics(
        label: '$title status is $status, current value $value',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(TemperatureStats temp) {
    Color statusColor;
    switch (temp.status) {
      case 'normal':
        statusColor = Colors.green;
        break;
      case 'high':
        statusColor = Colors.orange;
        break;
      case 'critical':
        statusColor = Colors.red;
        break;
      case 'unknown':
      default:
        statusColor = Colors.grey;
    }

    final tempText = temp.available
        ? '${temp.celsius?.toStringAsFixed(1) ?? 'N/A'} °C'
        : 'Temperature Unavailable';
    final subText = temp.available
        ? '${temp.sensor ?? 'Unknown sensor'} - ${temp.note}'
        : temp.note;

    return Card(
      child: Semantics(
        label:
            'System temperature: $tempText. Status: ${temp.status}. Note: $subText',
        child: ListTile(
          leading: Icon(
            temp.available ? Icons.thermostat : Icons.thermostat_outlined,
            color: statusColor,
          ),
          title: Text(tempText),
          subtitle: Text(subText),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              temp.status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Calendar',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (provider.calendarError != null &&
              provider.calendarError!.contains('Access Denied'))
            const AccessDeniedState(
                message: 'Operational Calendar Access Denied')
          else if (provider.isLoadingCalendar)
            const Card(
              child: SizedBox(
                height: 300,
                child: LoadingState(message: 'Loading calendar...'),
              ),
            )
          else if (provider.calendarError != null)
            ErrorState(
              message: provider.calendarError!,
              onRetry: () => provider.fetchCalendarEvents(),
            )
          else
            _buildCalendar(provider),
        ],
      ),
    );
  }

  Widget _buildCalendar(DashboardProvider provider) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            final dateStr = DateFormat('yyyy-MM-dd').format(day);
            return provider.calendarEvents
                .where((e) => e.start == dateStr)
                .toList();
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        if (provider.calendarEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No events scheduled in the current range.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildDayDetailSection(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Details for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isLoadingDayDetail)
            const LoadingState(message: 'Loading day details...')
          else if (provider.dayDetailError != null)
            ErrorState(
              message: provider.dayDetailError!,
              onRetry: () => _onDaySelected(_selectedDay!, _focusedDay),
            )
          else if (_selectedDayDetail == null ||
              _selectedDayDetail!.vendors.isEmpty)
            const EmptyState(
              message: 'No bookings scheduled',
              subMessage: 'No activity for this selected date.',
            )
          else
            ..._selectedDayDetail!.vendors.map(_buildVendorSection),
        ],
      ),
    );
  }

  Widget _buildVendorSection(VendorDayDetail vendor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            vendor.vendorName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...vendor.bookings.map((b) => _buildBookingCard(b, vendor.vendorName)),
      ],
    );
  }

  Widget _buildBookingCard(BookingDayDetail booking, String vendorName) {
    return Column(
      children: booking.items.map((item) {
        return DashboardAssetRow(
          booking: booking,
          item: item,
          vendorName: vendorName,
          onTap: () => context.push('/bookings/${booking.bookingId}'),
        );
      }).toList(),
    );
  }

}
