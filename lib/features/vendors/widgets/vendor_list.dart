import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../../../core/models/vendor.dart';
import 'vendor_form.dart';
import '../../../core/auth/permission_service.dart';

class VendorList extends StatelessWidget {
  const VendorList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isVendorsLoading && provider.vendors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.vendorsError != null && provider.vendors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.vendorsError}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchVendors(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.vendors.isEmpty) {
          return const Center(child: Text('No vendors found'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchVendors(),
          child: ListView.builder(
            itemCount: provider.vendors.length,
            itemBuilder: (context, index) {
              final vendor = provider.vendors[index];
              return VendorCard(vendor: vendor);
            },
          ),
        );
      },
    );
  }
}

class VendorCard extends StatelessWidget {
  final Vendor vendor;

  const VendorCard({super.key, required this.vendor});

  void _editVendor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VendorForm(vendor: vendor),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vendor'),
        content: Text('Are you sure you want to delete ${vendor.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final provider = context.read<VendorProvider>();
                await provider.deleteVendor(vendor.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  final provider = context.read<VendorProvider>();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.vendorsError ?? 'Failed to delete vendor'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('vendor_management');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(vendor.name),
        subtitle: Text('${vendor.place} • ${vendor.phone}'),
        trailing: canManage
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editVendor(context)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(context)),
                ],
              )
            : null,
      ),
    );
  }
}
