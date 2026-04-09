import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/permission_service.dart';
import '../../widgets/shared/corporate_app_bar.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _handleTileTap(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $moduleName sub-menu...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    // ScaffoldMessenger is used as a placeholder for the actual sign out call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging out of Genset Ledger...'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();
    final canAdmin = permissionService.can(PermissionService.settingsUserAdmin);

    if (!canAdmin) {
      return Scaffold(
        appBar: const CorporateAppBar(title: 'Admin & Settings'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Access Denied',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You do not have permission to access admin settings.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CorporateAppBar(
        title: 'Admin & Settings',
      ),
      backgroundColor: const Color(0xFFF8FAFC), // Scaffold background from Concept C
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Account Management'),
              _buildSettingsTile(
                context,
                title: 'Profile',
                subtitle: 'Manage your personal operator details',
                icon: Icons.account_circle_outlined,
                onTap: () => _handleTileTap(context, 'Profile'),
              ),
              _buildSettingsTile(
                context,
                title: 'Security',
                subtitle: 'Passwords, biometric login, and 2FA',
                icon: Icons.shield_outlined,
                onTap: () => _handleTileTap(context, 'Security'),
              ),
              
              const SizedBox(height: 32),
              
              _buildSectionHeader('System Administration'),
              _buildSettingsTile(
                context,
                title: 'User Roles',
                subtitle: 'Permissions and access levels for your fleet',
                icon: Icons.group_outlined,
                onTap: () => _handleTileTap(context, 'User Roles'),
              ),
              _buildSettingsTile(
                context,
                title: 'Data Export',
                subtitle: 'Download operational logs and reports',
                icon: Icons.file_download_outlined,
                onTap: () => _handleTileTap(context, 'Data Export'),
              ),
              _buildSettingsTile(
                context,
                title: 'System Preferences',
                subtitle: 'Offline mode, auto-billing, and synchronization',
                icon: Icons.settings_applications_outlined,
                onTap: () => _handleTileTap(context, 'System Preferences'),
              ),

              const SizedBox(height: 48),

              _buildSignOutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleSignOut(context),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        'SIGN OUT',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.red.withValues(alpha: 0.05),
      ),
    );
  }
}
