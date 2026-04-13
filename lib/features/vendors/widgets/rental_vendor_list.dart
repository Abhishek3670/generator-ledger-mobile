import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../../../core/models/vendor.dart';
import 'vendor_form.dart';
import '../../../core/auth/permission_service.dart';
import '../../../shared/widgets/state_widgets.dart';

class RentalVendorList extends StatelessWidget {
  const RentalVendorList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isRentalVendorsLoading && provider.rentalVendors.isEmpty) {
          return const LoadingState(message: 'Loading rental partners...');
        }

        if (provider.rentalVendorsError != null &&
            provider.rentalVendors.isEmpty) {
          return ErrorState(
            message: provider.rentalVendorsError!,
            onRetry: () => provider.fetchRentalVendors(),
          );
        }

        if (provider.rentalVendors.isEmpty) {
          return const EmptyState(
            message: 'No rental partners found',
            subMessage: 'Try adding a new partner or adjusting your search.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchRentalVendors(),
          child: ListView.builder(
            itemCount: provider.rentalVendors.length,
            itemBuilder: (context, index) {
              final vendor = provider.rentalVendors[index];
              return RentalVendorCard(vendor: vendor);
            },
          ),
        );
      },
    );
  }
}

class RentalVendorCard extends StatelessWidget {
  final RentalVendor vendor;

  const RentalVendorCard({super.key, required this.vendor});

  void _editVendor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VendorForm(rentalVendor: vendor, isRental: true),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rental Partner'),
        content: Text('Are you sure you want to delete ${vendor.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final provider = context.read<VendorProvider>();
                await provider.deleteRentalVendor(vendor.rentalVendorId);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  final provider = context.read<VendorProvider>();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.rentalVendorsError ??
                          'Failed to delete rental partner'),
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
    final canManage =
        context.read<PermissionService>().can('vendor_management');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        label: 'Rental Partner: ${vendor.name}, Location: ${vendor.place}',
        child: ListTile(
          title: Text(vendor.name),
          subtitle: Text('${vendor.place} • ${vendor.phone}'),
          trailing: canManage
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editVendor(context),
                      tooltip: 'Edit Rental Partner',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context),
                      tooltip: 'Delete Rental Partner',
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
