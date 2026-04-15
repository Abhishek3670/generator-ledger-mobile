import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/dashboard_models.dart';

class AlertsPanel extends StatelessWidget {
  final List<DashboardAlert> alerts;

  const AlertsPanel({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Active Alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          if (alerts.isEmpty)
            const Card(
              elevation: 0,
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Alert data unavailable.',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        'Not supported by current backend contract.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...alerts.map((alert) => _AlertCard(alert: alert)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final DashboardAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (alert.severity) {
      case 'critical':
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      color: color.withValues(alpha: 0.02),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(
          alert.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          alert.detail,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: () {
          if (alert.route != null) {
            context.push(alert.route!);
          }
        },
      ),
    );
  }
}
