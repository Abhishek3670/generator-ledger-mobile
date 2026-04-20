import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vendor.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/state_widgets.dart';
import 'providers/vendor_provider.dart';
import 'widgets/vendor_form.dart';

class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  State<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchVendors();
      context.read<VendorProvider>().fetchRentalVendors();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _searchController.clear();
      final provider = context.read<VendorProvider>();
      provider.setVendorSearchQuery('');
      provider.setRentalVendorSearchQuery('');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => VendorForm(isRental: _tabController.index == 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageVendors =
        context.read<PermissionService>().can('vendor_management');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Column(
          children: [
            DirectorySearchBar(
              controller: _searchController,
              hintText: 'Search vendors...',
              onChanged: (value) {
                final provider = context.read<VendorProvider>();
                if (_tabController.index == 0) {
                  provider.setVendorSearchQuery(value);
                } else {
                  provider.setRentalVendorSearchQuery(value);
                }
              },
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Retailers'),
                Tab(text: 'Rental Partners'),
              ],
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RetailerVendorsView(),
          _RentalVendorsView(),
        ],
      ),
      floatingActionButton: canManageVendors
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _RetailerVendorsView extends StatelessWidget {
  const _RetailerVendorsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isVendorsLoading && provider.vendors.isEmpty) {
          return const LoadingState(message: 'Loading vendors...');
        }
        if (provider.vendorsError != null && provider.vendors.isEmpty) {
          return ErrorState(
            message: provider.vendorsError!,
            onRetry: () => provider.fetchVendors(),
          );
        }
        if (provider.vendors.isEmpty) {
          return const EmptyState(
            message: 'No vendors found',
            subMessage: 'Try adding a new retailer.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchVendors(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.vendors.length,
            itemBuilder: (context, index) {
              return _VendorCardItem(vendor: provider.vendors[index]);
            },
          ),
        );
      },
    );
  }
}

class _RentalVendorsView extends StatelessWidget {
  const _RentalVendorsView();

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isRentalVendorsLoading && provider.rentalVendors.isEmpty) {
          return const LoadingState(message: 'Loading rental partners...');
        }
        if (provider.rentalVendorsError != null && provider.rentalVendors.isEmpty) {
          return ErrorState(
            message: provider.rentalVendorsError!,
            onRetry: () => provider.fetchRentalVendors(),
          );
        }
        if (provider.rentalVendors.isEmpty) {
          return const EmptyState(
            message: 'No rental partners found',
            subMessage: 'Try adding a new partner.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchRentalVendors(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.rentalVendors.length,
            itemBuilder: (context, index) {
              return _RentalVendorCardItem(vendor: provider.rentalVendors[index]);
            },
          ),
        );
      },
    );
  }
}

class _VendorCardItem extends StatelessWidget {
  final Vendor vendor;

  const _VendorCardItem({required this.vendor});

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
                if (context.mounted) Navigator.pop(context);
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vendor.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (canManage) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editVendor(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vendor.place,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  vendor.phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RentalVendorCardItem extends StatelessWidget {
  final RentalVendor vendor;

  const _RentalVendorCardItem({required this.vendor});

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final provider = context.read<VendorProvider>();
                await provider.deleteRentalVendor(vendor.rentalVendorId);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vendor.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (canManage) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editVendor(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vendor.place,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  vendor.phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
