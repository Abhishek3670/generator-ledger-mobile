import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'providers/billing_provider.dart';
import 'models/billing_models.dart';
import '../../../core/auth/permission_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    if (_fromDate.isAfter(_toDate)) {
      return;
    }
    context.read<BillingProvider>().fetchBillingLines(
          from: _dateFormat.format(_fromDate),
          to: _dateFormat.format(_toDate),
        );
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      if (_fromDate.isAfter(_toDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('"From" date cannot be later than "To" date.')),
        );
      } else {
        _fetchData();
      }
    }
  }

  @override
    Widget build(BuildContext context) {
    final provider = context.watch<BillingProvider>();
    final permissionService = context.read<PermissionService>();
    final isInvalidRange = _fromDate.isAfter(_toDate);

    if (!permissionService.can(PermissionService.billingAccess)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Billing')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Access Denied', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('You do not have permission to view billing data.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Lines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isInvalidRange ? null : _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context, provider),
          if (isInvalidRange)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range, color: Colors.orange, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Invalid Date Range',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('"From" date cannot be later than "To" date.'),
                  ],
                ),
              ),
            )
          else if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (provider.error != null)
            Expanded(child: Center(child: _buildErrorWidget(provider.error!)))
          else
            Expanded(child: _buildList(provider)),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, BillingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                    child: Text(_dateFormat.format(_fromDate)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                    child: Text(_dateFormat.format(_toDate)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Capacity (KVA)', border: OutlineInputBorder()),
                  value: provider.capacityFilter,
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text('All Capacities')),
                    ...provider.billingData?.capacities.map((c) => DropdownMenuItem<int>(value: c, child: Text('$c KVA'))) ?? [],
                  ],
                  onChanged: (val) => provider.setCapacityFilter(val),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Text('Rows', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('${provider.filteredRows.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BillingProvider provider) {
    final rows = provider.filteredRows;
    if (rows.isEmpty) {
      return const Center(child: Text('No billing lines found for this period.'));
    }

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(row.vendorName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vendor ID: ${row.vendorId} | Booking ID: ${row.bookingId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text('Date: ${row.bookedDate} | Gen: ${row.generatorId}'),
                Row(
                  children: [
                    _buildInventoryTypeBadge(row.inventoryType),
                    const SizedBox(width: 8),
                    Text('${row.capacityKva ?? "N/A"} KVA', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/bookings/${row.bookingId}'),
          ),
        );
      },
    );
  }

  Widget _buildInventoryTypeBadge(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'retailer':
        color = Colors.blue;
        break;
      case 'permanent':
        color = Colors.green;
        break;
      case 'emergency':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
      ],
    );
  }
}
