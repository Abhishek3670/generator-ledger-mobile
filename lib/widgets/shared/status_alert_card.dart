import 'package:flutter/material.dart';

enum AlertSeverity { success, warning, error }

class StatusAlertCard extends StatelessWidget {
  final AlertSeverity severity;
  final String message;
  final IconData? icon;

  const StatusAlertCard({
    super.key,
    required this.severity,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    IconData defaultIcon;

    switch (severity) {
      case AlertSeverity.success:
        // Use custom semantic colors defined in theme (using extensions ideally, but falling back to ColorScheme logic)
        backgroundColor = const Color(0xFFD1FAE5); // successContainer
        foregroundColor = const Color(0xFF065F46); // onSuccessContainer
        defaultIcon = Icons.check_circle_outline;
        break;
      case AlertSeverity.warning:
        backgroundColor = const Color(0xFFFEF3C7); // warningContainer
        foregroundColor = const Color(0xFF92400E); // onWarningContainer
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.error:
        backgroundColor = theme.colorScheme.errorContainer;
        foregroundColor = theme.colorScheme.error;
        defaultIcon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? defaultIcon,
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
