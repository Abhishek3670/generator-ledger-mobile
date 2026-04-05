import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class BookingItemEditForm extends StatefulWidget {
  final String bookingId;
  final List<BookingItem> existingItems;

  const BookingItemEditForm({
    super.key,
    required this.bookingId,
    required this.existingItems,
  });

  @override
  State<BookingItemEditForm> createState() => _BookingItemEditFormState();
}

class _BookingItemEditFormState extends State<BookingItemEditForm> {
  final _formKey = GlobalKey<FormState>();
  late List<BookingItemDraft> _updates;
  final List<int> _removes = [];
  bool _isSubmitting = false;
  bool _isAddingNew = false;

  // New item fields
  String? _newGeneratorId;
  int? _newCapacityKva;
  final _newStartController = TextEditingController();
  final _newEndController = TextEditingController();
  final _newRemarksController = TextEditingController();

  @override
  void dispose() {
    _newStartController.dispose();
    _newEndController.dispose();
    _newRemarksController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _updates = widget.existingItems.map((item) => BookingItemDraft(
      id: item.id,
      capacityKva: item.capacityKva,
      startDt: DateFormat('yyyy-MM-dd HH:mm').format(item.startDt),
      endDt: DateFormat('yyyy-MM-dd HH:mm').format(item.endDt),
      remarks: item.remarks,
    )).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation: Cannot remove all items
    if (_removes.length == widget.existingItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove all booking items. Use Delete Booking instead.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<BookingProvider>();

    try {
      if (_isAddingNew) {
        await provider.addBookingItem(
          widget.bookingId,
          generatorId: _newGeneratorId,
          capacityKva: _newCapacityKva,
          startDt: _newStartController.text,
          endDt: _newEndController.text,
          remarks: _newRemarksController.text.isEmpty ? null : _newRemarksController.text,
        );
      } else {
        final updatesPayload = _updates
            .where((u) => !_removes.contains(u.id))
            .map((u) => {
              'id': u.id,
              'start_dt': u.startDt,
              'end_dt': u.endDt,
              'remarks': u.remarks,
            }).toList();

        await provider.bulkUpdateItems(
          widget.bookingId,
          updates: updatesPayload,
          removes: _removes,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to update items')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAddingNew ? 'Add New Item' : 'Edit Booking Items'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minWidth: double.maxFinite,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isAddingNew)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _updates.length,
                    itemBuilder: (context, index) {
                      final update = _updates[index];
                      final isRemoved = _removes.contains(update.id);

                      return Card(
                        color: isRemoved ? Colors.grey[200] : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Item #${update.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(isRemoved ? Icons.undo : Icons.delete, color: isRemoved ? Colors.green : Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        if (isRemoved) {
                                          _removes.remove(update.id);
                                        } else {
                                          _removes.add(update.id!);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (!isRemoved) ...[
                                TextFormField(
                                  initialValue: update.startDt,
                                  decoration: const InputDecoration(labelText: 'Start (YYYY-MM-DD HH:mm)'),
                                  onChanged: (v) => update.startDt = v,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                                TextFormField(
                                  initialValue: update.endDt,
                                  decoration: const InputDecoration(labelText: 'End (YYYY-MM-DD HH:mm)'),
                                  onChanged: (v) => update.endDt = v,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                                ),
                                TextFormField(
                                  initialValue: update.remarks,
                                  decoration: const InputDecoration(labelText: 'Remarks'),
                                  onChanged: (v) => update.remarks = v,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Capacity (kVA)',
                          helperText: 'Required if Generator ID is empty',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _newCapacityKva = int.tryParse(v),
                        validator: (v) {
                          if (_newGeneratorId == null && (v == null || v.isEmpty)) {
                            return 'Capacity or Generator ID required';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _newStartController,
                        decoration: const InputDecoration(labelText: 'Start (YYYY-MM-DD HH:mm)'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _newEndController,
                        decoration: const InputDecoration(labelText: 'End (YYYY-MM-DD HH:mm)'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _newRemarksController,
                        decoration: const InputDecoration(labelText: 'Remarks'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!_isAddingNew)
          TextButton(
            onPressed: () => setState(() => _isAddingNew = true),
            child: const Text('Add New Item'),
          ),
        TextButton(
          onPressed: () {
            if (_isAddingNew) {
              setState(() => _isAddingNew = false);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(_isAddingNew ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

class BookingItemDraft {
  int? id;
  int? capacityKva;
  String? startDt;
  String? endDt;
  String? remarks;

  BookingItemDraft({this.id, this.capacityKva, this.startDt, this.endDt, this.remarks});
}
