import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vendor_provider.dart';
import 'widgets/vendor_list.dart';
import 'widgets/rental_vendor_list.dart';
import '../../../core/auth/permission_service.dart';
import '../../../shared/widgets/search_bar.dart';
import 'widgets/vendor_form.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(() {
      setState(() {}); // Redraw to show/hide clear button
    });
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
          VendorList(),
          RentalVendorList(),
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
