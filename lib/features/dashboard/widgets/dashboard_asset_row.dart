import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/clean_authority_theme.dart';
import '../models/dashboard_models.dart';

class DashboardAssetRow extends StatelessWidget {
  final BookingDayDetail booking;
  final BookingItemDayDetail item;
  final String vendorName;
  final VoidCallback onTap;

  const DashboardAssetRow({
    super.key,
    required this.booking,
    required this.item,
    required this.vendorName,
    required this.onTap,
  });

  String _formatTime(String dtStr) {
    try {
      final dt = DateTime.parse(dtStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return dtStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine status purely for UI demonstration (e.g., active if today)
    // Here we'll treat all scheduled items as ACTIVE for this simple view
    const statusText = 'SCHEDULED';
    final statusColor = CleanAuthorityTheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CleanAuthorityTheme.surfaceContainerHigh,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CleanAuthorityTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, size: 20, color: CleanAuthorityTheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            
            // Core Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.generatorId,
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.capacityKva ?? '--'} KVA • $vendorName',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Time Window
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatTime(item.startDt)} - ${_formatTime(item.endDt)}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
