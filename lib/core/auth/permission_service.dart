import '../models/user.dart';
import 'auth_provider.dart';

/// Centralized permission resolver aligned to backend capability keys and default role rules.
///
/// Mirroring backend logic from web_app_source/core/permissions.py.
class PermissionService {
  final AuthProvider _authProvider;

  PermissionService(this._authProvider);

  // Capability Keys
  static const String settingsUserAdmin = "settings_user_admin";
  static const String monitorAccess = "monitor_access";
  static const String vendorManagement = "vendor_management";
  static const String generatorManagement = "generator_management";
  static const String bookingCreateUpdate = "booking_create_update";
  static const String bookingDelete = "booking_delete";
  static const String billingAccess = "billing_access";
  static const String exportAccess = "export_access";
  static const String readOnlyOperationalViews = "read_only_operational_views";

  static const String roleAdmin = "admin";
  static const String roleOperator = "operator";

  bool can(String capability) {
    final user = _authProvider.user;
    if (user == null) return false;
    final permissions = getEffectivePermissions(user);
    return permissions[capability] ?? false;
  }

  /// Resolves effective permissions for a user based on their role.
  static Map<String, bool> getEffectivePermissions(User user) {
    final role = user.role.toLowerCase();

    if (role == roleAdmin) {
      return {
        settingsUserAdmin: true,
        monitorAccess: true,
        vendorManagement: true,
        generatorManagement: true,
        bookingCreateUpdate: true,
        bookingDelete: true,
        billingAccess: true,
        exportAccess: true,
        readOnlyOperationalViews: true,
      };
    } else if (role == roleOperator) {
      return {
        settingsUserAdmin: false,
        monitorAccess: false,
        vendorManagement: false,
        generatorManagement: false,
        bookingCreateUpdate: true,
        bookingDelete: false,
        billingAccess: false,
        exportAccess: false,
        readOnlyOperationalViews: true,
      };
    }

    // Default: no permissions for unknown roles
    return {
      for (var key in [
        settingsUserAdmin,
        monitorAccess,
        vendorManagement,
        generatorManagement,
        bookingCreateUpdate,
        bookingDelete,
        billingAccess,
        exportAccess,
        readOnlyOperationalViews
      ])
        key: false
    };
  }

  /// Helper to check if a user has a specific capability.
  static bool hasCapability(User? user, String capability) {
    if (user == null) return false;
    final permissions = getEffectivePermissions(user);
    return permissions[capability] ?? false;
  }
}
