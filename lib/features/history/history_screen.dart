import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/permission_service.dart';
import '../../shared/widgets/state_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();

    if (!permissionService.can(PermissionService.readOnlyOperationalViews)) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const AccessDeniedState(
          message: 'You do not have permission to view history.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: EmptyState(
        icon: Icons.history,
        message: 'Mobile History Limited',
        subMessage:
            'Historical logs are currently only available on the web portal. Mobile JSON integration is not yet supported by the backend.',
        action: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
