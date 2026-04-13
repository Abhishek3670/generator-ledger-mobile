import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/generator_provider.dart';
import 'widgets/generator_list.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../../core/auth/permission_service.dart';
import '../../../shared/widgets/search_bar.dart';
import 'widgets/generator_form.dart';

class GeneratorsScreen extends StatefulWidget {
  const GeneratorsScreen({super.key});

  @override
  State<GeneratorsScreen> createState() => _GeneratorsScreenState();
}

class _GeneratorsScreenState extends State<GeneratorsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _searchController.addListener(() {
      setState(() {}); // Redraw to show/hide clear button
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>().fetchGenerators();
      context.read<VendorProvider>().fetchRentalVendors();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _searchController.clear();
      context.read<GeneratorProvider>().setSearchQuery('');
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
      builder: (context) => const GeneratorForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageGenerators =
        context.read<PermissionService>().can('generator_management');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Column(
          children: [
            DirectorySearchBar(
              controller: _searchController,
              hintText: 'Search generators...',
              onChanged: (value) {
                context.read<GeneratorProvider>().setSearchQuery(value);
              },
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Retailer'),
                Tab(text: 'Permanent'),
                Tab(text: 'Emergency'),
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
          GeneratorList(inventoryType: 'retailer'),
          GeneratorList(inventoryType: 'permanent'),
          GeneratorList(inventoryType: 'emergency'),
        ],
      ),
      floatingActionButton: canManageGenerators
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
