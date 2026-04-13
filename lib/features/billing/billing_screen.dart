import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/billing_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/state_widgets.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    if (_fromDate.isAfter(_toDate)) return;
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

  void _showRateDialog(BuildContext context, BillingProvider provider) {
    if (provider.billingData == null) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Capacity Rates'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: provider.rates.keys.map((capacity) {
                final currentRate = provider.rates[capacity] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextFormField(
                    initialValue: currentRate > 0 ? currentRate.toString() : '',
                    decoration: InputDecoration(
                      labelText: '$capacity KVA Rate',
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final newRate = double.tryParse(val);
                      if (newRate != null) {
                        provider.setRate(capacity, newRate);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillingProvider>();
    final permissionService = context.read<PermissionService>();
    final isInvalidRange = _fromDate.isAfter(_toDate);

    if (!permissionService.can(PermissionService.billingAccess)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Billing')),
        body: const AccessDeniedState(
          message: 'You do not have permission to view billing data.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_applications),
            tooltip: 'Set Capacity Rates',
            onPressed: () => _showRateDialog(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh billing data',
            onPressed: isInvalidRange ? null : _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBanner(context, provider),
          _buildFilters(context, provider),
          if (isInvalidRange)
            const Expanded(
              child: EmptyState(
                icon: Icons.date_range,
                message: 'Invalid Date Range',
                subMessage: '"From" date cannot be later than "To" date.',
              ),
            )
          else if (provider.isLoading)
            const Expanded(child: LoadingState(message: 'Loading billing records...'))
          else if (provider.error != null)
            Expanded(
              child: ErrorState(
                message: provider.error!,
                onRetry: _fetchData,
              ),
            )
          else
            Expanded(child: _buildGridList(provider)),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(BuildContext context, BillingProvider provider) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('Total Revenue', provider.totalRevenue, Colors.green.shade700),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildSummaryItem('Total Pending', provider.totalPending, Colors.orange.shade800),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color amountColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: amountColor),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, BillingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'From', border: OutlineInputBorder(), isDense: true),
                child: Text(_dateFormat.format(_fromDate)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'To', border: OutlineInputBorder(), isDense: true),
                child: Text(_dateFormat.format(_toDate)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridList(BillingProvider provider) {
    final rows = provider.filteredRows;
    if (rows.isEmpty) {
      return const EmptyState(
        message: 'No billing lines found',
        subMessage: 'Try adjusting your date range.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Invoice ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Issuance Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: rows.map((row) {
            final isPaid = provider.isPaid(row.bookingId);
            final amount = provider.getAmountForCapacity(row.capacityKva);

            return DataRow(
              onSelectChanged: (selected) {
                if (selected != null && selected) {
                  provider.togglePaymentStatus(row.bookingId);
                }
              },
              cells: [
                DataCell(Text(row.bookingId.substring(0, 8).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(row.vendorName)),
                DataCell(Text(row.bookedDate)),
                DataCell(Text(_currencyFormat.format(amount))),
                DataCell(_buildStatusBadge(isPaid)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid) {
    final color = isPaid ? Colors.green : Colors.orange;
    final text = isPaid ? 'PAID' : 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
