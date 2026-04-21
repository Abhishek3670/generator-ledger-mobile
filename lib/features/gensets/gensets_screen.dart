import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generators/providers/generator_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/state_widgets.dart';
import 'widgets/genset_card.dart';
import 'widgets/genset_filter_bar.dart';
import 'widgets/add_genset_overlay.dart';
import '../../../core/models/generator.dart';
import '../../../widgets/shared/corporate_app_bar.dart';

class GensetsScreen extends StatefulWidget {
  const GensetsScreen({super.key});

  @override
  State<GensetsScreen> createState() => _GensetsScreenState();
}

class _GensetsScreenState extends State<GensetsScreen> with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>().fetchGenerators();
      context.read<VendorProvider>().ensureVendorsLoaded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('generator_management');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CorporateAppBar(title: 'Generators'),
      body: Consumer<GeneratorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.generators.isEmpty) {
            return const LoadingState(message: 'Loading gensets...');
          }
          if (provider.error != null && provider.generators.isEmpty) {
            return ErrorState(message: provider.error!, onRetry: () => provider.fetchGenerators());
          }

          final retailers = provider.generators.where((g) => g.inventoryType.toLowerCase() == 'retailer').toList();
          final permanents = provider.generators.where((g) => g.inventoryType.toLowerCase() == 'permanent').toList();
          final emergencies = provider.generators.where((g) => g.inventoryType.toLowerCase() == 'emergency').toList();

          return Column(
            children: [
              GensetFilterBar(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Retailers'),
                    Tab(text: 'Permanents'),
                    Tab(text: 'Emergencies'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InventoryGroupView(
                      subtitle: 'Gensets used for normal bookings and day-to-day retailer assignments.',
                      generators: retailers,
                      selectedDate: _selectedDate,
                    ),
                    _InventoryGroupView(
                      subtitle: 'Gensets permanently parked at Rental Vendor properties.',
                      generators: permanents,
                      selectedDate: _selectedDate,
                    ),
                    _InventoryGroupView(
                      subtitle: 'Backup gensets kept ready when any genset fails or for emergencies.',
                      generators: emergencies,
                      selectedDate: _selectedDate,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => AddGensetOverlay.show(context),
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Genset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

class _InventoryGroupView extends StatefulWidget {
  final String subtitle;
  final List<Generator> generators;
  final DateTime? selectedDate;

  const _InventoryGroupView({
    required this.subtitle,
    required this.generators,
    this.selectedDate,
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
    final filtered = widget.generators.where((g) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return g.id.toLowerCase().contains(query) ||
             g.type.toLowerCase().contains(query) ||
             g.status.toLowerCase().contains(query) ||
             g.identification.toLowerCase().contains(query) ||
             (g.notes?.toLowerCase().contains(query) ?? false) ||
             (g.rentalVendorName?.toLowerCase().contains(query) ?? false);
    }).toList();

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
                    child: Text(widget.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                      '${widget.generators.length} RECORDS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search by ID, Type, Status, Vendor, Notes...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No gensets match your search.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: () => context.read<GeneratorProvider>().fetchGenerators(),
                  child: ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemBuilder: (context, index) => GensetCard(
                      generator: filtered[index],
                      selectedDate: widget.selectedDate,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
