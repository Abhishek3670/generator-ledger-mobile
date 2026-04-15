import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class SummaryMetricsGrid extends StatelessWidget {
  final DashboardSummary summary;

  const SummaryMetricsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _MetricCard(
            title: 'Total Generators',
            value: '${summary.totalGenerators}',
            subtitle: '${summary.activeGenerators} active',
            icon: Icons.electrical_services,
            color: Colors.blue,
          ),
          _MetricCard(
            title: 'Total Bookings',
            value: '${summary.totalBookings}',
            subtitle: '${summary.confirmedBookings} confirmed',
            icon: Icons.calendar_today,
            color: Colors.green,
          ),
          _MetricCard(
            title: 'Total Vendors',
            value: '${summary.totalVendors}',
            subtitle: 'Direct Partners',
            icon: Icons.business,
            color: Colors.orange,
          ),
          const _MetricCard(
            title: 'Overdue Alerts',
            value: '-',
            subtitle: 'Data Unavailable',
            icon: Icons.warning_amber_rounded,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
