import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/shared/corporate_app_bar.dart';
import '../generators/providers/generator_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../generators/widgets/generator_form.dart';
import '../vendors/widgets/vendor_form.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>().fetchGenerators();
      context.read<VendorProvider>().fetchVendors();
      context.read<VendorProvider>().fetchRentalVendors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CorporateAppBar(
          title: 'Directory',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Generators'),
              Tab(text: 'Vendors'),
              Tab(text: 'Inventory'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _GeneratorsTable(),
            _VendorsTable(),
            _InventoryTable(),
          ],
        ),
      ),
    );
  }
}

class _GeneratorsTable extends StatelessWidget {
  const _GeneratorsTable();

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.generators.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final generators = provider.generators;
        if (generators.isEmpty) {
          return const Center(child: Text('No generators found'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: generators.map((g) {
                return DataRow(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => GeneratorForm(generator: g),
                    );
                  },
                  cells: [
                    DataCell(Text(g.identification, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${g.capacity} KVA')),
                    DataCell(Text(g.type)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(g.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          g.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(g.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class _VendorsTable extends StatelessWidget {
  const _VendorsTable();

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorProvider>(
      builder: (context, provider, child) {
        if (provider.isVendorsLoading && provider.vendors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final vendors = provider.vendors;
        if (vendors.isEmpty) {
          return const Center(child: Text('No vendors found'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('Vendor Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: vendors.map((v) {
                return DataRow(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => VendorForm(vendor: v, isRental: false),
                    );
                  },
                  cells: [
                    DataCell(Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    const DataCell(Text('Retailer')),
                    DataCell(Text(v.phone)),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable();

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        final inventory = provider.generators.where((g) => g.inventoryType == 'permanent' || g.inventoryType == 'emergency').toList();
        if (inventory.isEmpty) {
          return const Center(child: Text('No inventory records found'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Inventory Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: inventory.map((g) {
                return DataRow(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => GeneratorForm(generator: g),
                    );
                  },
                  cells: [
                    DataCell(Text(g.identification, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(g.inventoryType)),
                    DataCell(Text(g.rentalVendorName ?? 'Unassigned')),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
