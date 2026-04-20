import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generators/providers/generator_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../shared/widgets/search_bar.dart';
import 'widgets/genset_card.dart';
import '../generators/widgets/generator_form.dart';

class GensetsScreen extends StatefulWidget {
  const GensetsScreen({super.key});

  @override
  State<GensetsScreen> createState() => _GensetsScreenState();
}

class _GensetsScreenState extends State<GensetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> inventoryTypes = ['Retailer', 'Permanent', 'Emergency'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>().fetchGenerators();
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
    showDialog(context: context, builder: (context) => const GeneratorForm());
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('generator_management');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 80),
        child: Column(
          children: [
            DirectorySearchBar(
              controller: _searchController,
              hintText: 'Search gensets...',
              onChanged: (value) => context.read<GeneratorProvider>().setSearchQuery(value),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Retailers'), Tab(text: 'Permanent'), Tab(text: 'Emergency')],
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: inventoryTypes.map((type) => _InventoryTypeView(inventoryType: type)).toList(),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add))
          : null,
    );
  }
}

class _InventoryTypeView extends StatelessWidget {
  final String inventoryType;

  const _InventoryTypeView({required this.inventoryType});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.generators.isEmpty) {
          return const LoadingState(message: 'Loading gensets...');
        }
        if (provider.error != null && provider.generators.isEmpty) {
          return ErrorState(message: provider.error!, onRetry: () => provider.fetchGenerators());
        }

        final filtered = provider.generators.where(
          (g) => g.inventoryType.toLowerCase() == inventoryType.toLowerCase()
        ).toList();

        if (filtered.isEmpty) {
          return const EmptyState(message: 'No gensets found', subMessage: 'Try adjusting filters.');
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchGenerators(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return GensetCard(generator: filtered[index]);
            },
          ),
        );
      },
    );
  }
}
