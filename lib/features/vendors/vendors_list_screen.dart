import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vendor.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../../widgets/shared/corporate_app_bar.dart';
import 'providers/vendor_provider.dart';
import 'widgets/vendor_card.dart';
import 'widgets/add_vendor_overlay.dart';

class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  State<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchVendors();
      context.read<VendorProvider>().fetchRentalVendors();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManageVendors =
        context.read<PermissionService>().can('vendor_management');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CorporateAppBar(title: 'Vendors'),
      body: Consumer<VendorProvider>(
        builder: (context, provider, child) {
          final retailers = provider.allVendors;
          final rentals = provider.rentalVendors;

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Retailer Vendor'),
                    Tab(text: 'Rental Vendors'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InventoryGroupView(
                      subtitle: 'Retail Vendor records of marriage functions or similar on site functions',
                      vendors: retailers,
                      isRental: false,
                    ),
                    _InventoryGroupView(
                      subtitle: 'Rental Vendor records of marriage halls, guest houses, and hotels.',
                      rentalVendors: rentals,
                      isRental: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: canManageVendors
          ? FloatingActionButton.extended(
              onPressed: () => AddVendorOverlay.show(
                context,
                isRental: _tabController.index == 1,
              ),
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                _tabController.index == 0 ? 'Add Retailer Vendor' : 'Add Rental Vendor',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }
}

class _InventoryGroupView extends StatefulWidget {
  final String subtitle;
  final List<Vendor>? vendors;
  final List<RentalVendor>? rentalVendors;
  final bool isRental;

  const _InventoryGroupView({
    required this.subtitle,
    this.vendors,
    this.rentalVendors,
    required this.isRental,
  });

  @override
  State<_InventoryGroupView> createState() => _InventoryGroupViewState();
}

class _InventoryGroupViewState extends State<_InventoryGroupView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    
    final isLoading = widget.isRental ? provider.isRentalVendorsLoading : provider.isVendorsLoading;
    final error = widget.isRental ? provider.rentalVendorsError : provider.vendorsError;
    final totalCount = widget.isRental ? (widget.rentalVendors?.length ?? 0) : (widget.vendors?.length ?? 0);

    List<dynamic> filtered = [];
    if (widget.isRental) {
      filtered = (widget.rentalVendors ?? []).where((v) {
        if (_searchQuery.isEmpty) return true;
        final query = _searchQuery.toLowerCase();
        return v.rentalVendorId.toLowerCase().contains(query) ||
            v.name.toLowerCase().contains(query) ||
            v.place.toLowerCase().contains(query) ||
            v.phone.contains(query);
      }).toList();
    } else {
      filtered = (widget.vendors ?? []).where((v) {
        if (_searchQuery.isEmpty) return true;
        final query = _searchQuery.toLowerCase();
        return v.id.toLowerCase().contains(query) ||
            v.name.toLowerCase().contains(query) ||
            v.place.toLowerCase().contains(query) ||
            v.phone.contains(query);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      '$totalCount RECORDS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: widget.isRental 
                      ? 'Search by Rental ID, Property, Place, Phone...'
                      : 'Search by Vendor ID, Name, Place, Phone...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (isLoading && totalCount == 0) {
                return const LoadingState(message: 'Loading vendors...');
              }
              if (error != null && totalCount == 0) {
                return ErrorState(
                  message: error,
                  onRetry: () => widget.isRental
                      ? provider.fetchRentalVendors()
                      : provider.fetchVendors(),
                );
              }
              if (totalCount == 0) {
                return EmptyState(
                  message: 'No vendors found',
                  subMessage: 'Try adding a new vendor.',
                );
              }
              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No vendors match your search.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => widget.isRental
                    ? provider.fetchRentalVendors()
                    : provider.fetchVendors(),
                child: ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    if (widget.isRental) {
                      return VendorCard(rentalVendor: item);
                    } else {
                      return VendorCard(vendor: item);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
