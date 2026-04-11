import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/generator_provider.dart';
import '../../vendors/providers/vendor_provider.dart';
import '../../../core/models/generator.dart';

class GeneratorForm extends StatefulWidget {
  final Generator? generator;

  const GeneratorForm({super.key, this.generator});

  @override
  State<GeneratorForm> createState() => _GeneratorFormState();
}

class _GeneratorFormState extends State<GeneratorForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _capacityController;
  late TextEditingController _identificationController;
  late TextEditingController _notesController;
  String _type = 'Silent';
  String _status = 'Active';
  String _inventoryType = 'retailer';
  String? _rentalVendorId;
  bool _isSubmitting = false;

  final List<String> _types = ['Silent', 'Open'];
  final List<String> _statuses = ['Active', 'Inactive', 'Maintenance'];
  final List<String> _inventoryTypes = ['retailer', 'permanent', 'emergency'];

  @override
  void initState() {
    super.initState();
    _capacityController = TextEditingController(
        text: widget.generator?.capacity.toString() ?? '');
    _identificationController =
        TextEditingController(text: widget.generator?.identification ?? '');
    _notesController =
        TextEditingController(text: widget.generator?.notes ?? '');
    _type = widget.generator?.type ?? 'Silent';
    _status = widget.generator?.status ?? 'Active';
    _inventoryType = widget.generator?.inventoryType ?? 'retailer';
    _rentalVendorId = widget.generator?.rentalVendorId;
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _identificationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_inventoryType == 'permanent' &&
        (_rentalVendorId == null || _rentalVendorId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Rental Partner is required for Permanent Genset')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<GeneratorProvider>();

    try {
      final capacityKva = int.parse(_capacityController.text.trim());
      final identification = _identificationController.text.trim();
      final notes = _notesController.text.trim();

      if (widget.generator != null) {
        await provider.updateGenerator(
          widget.generator!.id,
          capacityKva: capacityKva,
          type: _type,
          identification: identification,
          notes: notes,
          status: _status,
          inventoryType: _inventoryType,
          rentalVendorId:
              _inventoryType == 'permanent' ? _rentalVendorId : null,
        );
      } else {
        await provider.createGenerator(
          capacityKva: capacityKva,
          type: _type,
          identification: identification,
          notes: notes,
          status: _status,
          inventoryType: _inventoryType,
          rentalVendorId:
              _inventoryType == 'permanent' ? _rentalVendorId : null,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.generator != null;
    final title = isEditing ? 'Edit Generator' : 'Add Generator';
    final rentalVendors = context.watch<VendorProvider>().rentalVendors;

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity (kVA)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Capacity is required';
                  }
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be a positive number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                controller: _identificationController,
                decoration:
                    const InputDecoration(labelText: 'Identification / ID'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _inventoryType,
                items: _inventoryTypes
                    .map((it) => DropdownMenuItem(value: it, child: Text(it)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _inventoryType = v!;
                  if (_inventoryType != 'permanent') _rentalVendorId = null;
                }),
                decoration:
                    const InputDecoration(labelText: 'Inventory Category'),
              ),
              if (_inventoryType == 'permanent')
                DropdownButtonFormField<String>(
                  initialValue: _rentalVendorId,
                  items: rentalVendors
                      .map((rv) => DropdownMenuItem(
                          value: rv.rentalVendorId, child: Text(rv.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _rentalVendorId = v),
                  decoration:
                      const InputDecoration(labelText: 'Rental Partner'),
                  validator: (v) =>
                      _inventoryType == 'permanent' && (v == null || v.isEmpty)
                          ? 'Rental Partner required'
                          : null,
                ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
