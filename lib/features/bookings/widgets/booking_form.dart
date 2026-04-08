import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../../vendors/providers/vendor_provider.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVendorId;
  final List<BookingItemDraft> _items = [BookingItemDraft()];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<VendorProvider>().ensureVendorsLoaded();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVendorId == null) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<BookingProvider>();

    try {
      final payload = _items.map((i) => i.toJson()).toList();
      final result = await provider.createBooking(
        vendorId: _selectedVendorId!,
        items: payload,
      );

      if (result['success'] == false &&
          result['error_code'] == 'retailer_out_of_stock') {
        if (mounted) _handleEmergencySuggestions(result);
      } else if (mounted) {
        final message = result['message'] ?? 'Booking created';
        final isMerged = result['is_merged'] ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message ${isMerged ? "(Merged)" : ""}')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create booking')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleEmergencySuggestions(Map<String, dynamic> response) {
    final suggestions = (response['affected_dates'] as List)
        .map((s) => EmergencySuggestion.fromJson(s))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final allResolved =
              suggestions.every((s) => _items[s.itemIndex].generatorId != null);

          return AlertDialog(
            title: const Text('Retailer Out of Stock'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final s = suggestions[index];
                  final selectedId = _items[s.itemIndex].generatorId;
                  final selectedOption = selectedId == null
                      ? null
                      : s.emergencyOptions
                          .firstWhere((o) => o.generatorId == selectedId);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${s.date}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Capacity: ${s.capacityKva} kVA'),
                          const Divider(),
                          if (selectedOption != null)
                            ListTile(
                              title: Text(selectedOption.identification),
                              subtitle: const Text('Selected',
                                  style: TextStyle(color: Colors.green)),
                              trailing: TextButton(
                                onPressed: () => setDialogState(() {
                                  _items[s.itemIndex].generatorId = null;
                                }),
                                child: const Text('Change'),
                              ),
                            )
                          else
                            ...s.emergencyOptions.map((opt) => ListTile(
                                  title: Text(opt.identification),
                                  subtitle: Text(
                                      '${opt.capacityKva} kVA • ${opt.type}'),
                                  onTap: () => setDialogState(() {
                                    _items[s.itemIndex].generatorId =
                                        opt.generatorId;
                                  }),
                                )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: allResolved
                    ? () {
                        Navigator.pop(context);
                        _submit();
                      }
                    : null,
                child: const Text('Resubmit'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendors = context.watch<VendorProvider>().allVendors;

    return AlertDialog(
      title: const Text('New Booking'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedVendorId,
                items: vendors
                    .map((v) =>
                        DropdownMenuItem(value: v.id, child: Text(v.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVendorId = v),
                decoration: const InputDecoration(labelText: 'Vendor'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(
                  _items.length, (index) => _buildItemFields(index)),
              TextButton.icon(
                onPressed: () => setState(() => _items.add(BookingItemDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Add Date/Capacity'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildItemFields(int index) {
    final item = _items[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.capacityKva?.toString(),
                    decoration:
                        const InputDecoration(labelText: 'Capacity (kVA)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => item.capacityKva = int.tryParse(v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null)
                          setState(() =>
                              item.date = DateFormat('yyyy-MM-dd').format(d));
                      },
                    ),
                    if (item.date != null)
                      Text(item.date!, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            FormField<String>(
              initialValue: item.date,
              validator: (v) => item.date == null ? 'Date required' : null,
              builder: (state) => state.hasError
                  ? Text(state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12))
                  : const SizedBox.shrink(),
            ),
            TextFormField(
              initialValue: item.remarks,
              decoration: const InputDecoration(labelText: 'Remarks'),
              onChanged: (v) => item.remarks = v,
            ),
            if (index > 0)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () => setState(() => _items.removeAt(index)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BookingItemDraft {
  String? generatorId;
  int? capacityKva;
  String? date;
  String? remarks;

  Map<String, dynamic> toJson() {
    return {
      'generator_id': generatorId,
      'capacity_kva': capacityKva,
      'date': date,
      'remarks': remarks,
    };
  }
}
