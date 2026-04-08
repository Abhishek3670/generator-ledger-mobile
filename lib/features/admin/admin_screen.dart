import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/permission_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();
    final canAdmin = permissionService.can(PermissionService.settingsUserAdmin);

    if (!canAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Access Denied', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You do not have permission to access admin settings.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 24),
            Text(
              'System Capability Matrix',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The following capabilities are defined in the backend and used for permission gating across the application.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildCapabilityMatrix(),
            const SizedBox(height: 24),
            _buildManagementNote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'User Management Notice',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Mobile user creation, role assignment, and permission overrides are currently read-only. '
              'To manage users or modify permissions, please use the web administration portal.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityMatrix() {
    final capabilities = [
      {'key': PermissionService.settingsUserAdmin, 'label': 'Settings & User Admin', 'desc': 'Access to this admin panel and user management.'},
      {'key': PermissionService.monitorAccess, 'label': 'Monitor Access', 'desc': 'View live system metrics and health status.'},
      {'key': PermissionService.vendorManagement, 'label': 'Vendor Management', 'desc': 'Create and manage vendor records.'},
      {'key': PermissionService.generatorManagement, 'label': 'Generator Management', 'desc': 'Manage generator inventory.'},
      {'key': PermissionService.bookingCreateUpdate, 'label': 'Booking Write', 'desc': 'Create and update bookings.'},
      {'key': PermissionService.bookingDelete, 'label': 'Booking Delete', 'desc': 'Ability to delete existing bookings.'},
      {'key': PermissionService.billingAccess, 'label': 'Billing Access', 'desc': 'View billing lines and financial data.'},
      {'key': PermissionService.exportAccess, 'label': 'Export Access', 'desc': 'Ability to export data reports.'},
      {'key': PermissionService.readOnlyOperationalViews, 'label': 'Operational View', 'desc': 'Read-only access to operational data.'},
    ];

    return Column(
      children: capabilities.map((cap) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(cap['label']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cap['desc']!, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cap['key']!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManagementNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Management',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Vendor and Generator management capabilities are integrated into the Directory module. '
            'If you have the required permissions, you can manage these records directly from the Directory screens.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
