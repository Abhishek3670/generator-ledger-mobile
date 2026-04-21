import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generators/providers/generator_provider.dart';
import '../../vendors/providers/vendor_provider.dart';
import '../../../core/models/generator.dart';

class AddGensetOverlay extends StatefulWidget {
  final Generator? generator;

  const AddGensetOverlay({super.key, this.generator});

  static void show(BuildContext context, {Generator? generator}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGensetOverlay(generator: generator),
    );
  }

  @override
  State<AddGensetOverlay> createState() => _AddGensetOverlayState();
}

class _AddGensetOverlayState extends State<AddGensetOverlay> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _typeController;
  late TextEditingController _identificationController;
  late TextEditingController _notesController;
  
  int _capacityKva = 20;
  String _status = 'Active';
  String _inventoryType = 'Retailer Genset';
  String? _rentalVendorId;
  bool _isSubmitting = false;

  final List<int> _capacities = [20, 30, 45, 50, 82, 100, 125];
  final List<String> _statuses = ['Active', 'Inactive'];
  final List<String> _inventoryTypes = ['Retailer Genset', 'Permanent Genset', 'Emergency Genset'];

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.generator?.type ?? '');
    _identificationController = TextEditingController(text: widget.generator?.identification ?? '');
    _notesController = TextEditingController(text: widget.generator?.notes ?? '');
    
    _capacityKva = widget.generator?.capacity ?? 20;
    if (!_capacities.contains(_capacityKva)) {
      _capacities.add(_capacityKva); // In case of custom capacity
      _capacities.sort();
    }
    
    _status = widget.generator?.status ?? 'Active';
    
    // Map existing inventory types to the new display labels
    final currentInv = widget.generator?.inventoryType.toLowerCase() ?? 'retailer';
    if (currentInv.contains('permanent')) _inventoryType = 'Permanent Genset';
    else if (currentInv.contains('emergency')) _inventoryType = 'Emergency Genset';
    else _inventoryType = 'Retailer Genset';

    _rentalVendorId = widget.generator?.rentalVendorId;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _identificationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _mapInventoryTypeToBackend(String displayValue) {
    if (displayValue == 'Permanent Genset') return 'permanent';
    if (displayValue == 'Emergency Genset') return 'emergency';
    return 'retailer';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final backendInventoryType = _mapInventoryTypeToBackend(_inventoryType);
    if (backendInventoryType == 'permanent' && (_rentalVendorId == null || _rentalVendorId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rental Vendor is required for Permanent Gensets')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<GeneratorProvider>();

    try {
      if (widget.generator != null) {
        await provider.updateGenerator(
          widget.generator!.id,
          capacityKva: _capacityKva,
          type: _typeController.text.trim(),
          identification: _identificationController.text.trim(),
          notes: _notesController.text.trim(),
          status: _status,
          inventoryType: backendInventoryType,
          rentalVendorId: backendInventoryType == 'permanent' ? _rentalVendorId : null,
        );
      } else {
        await provider.createGenerator(
          capacityKva: _capacityKva,
          type: _typeController.text.trim(),
          identification: _identificationController.text.trim(),
          notes: _notesController.text.trim(),
          status: _status,
          inventoryType: backendInventoryType,
          rentalVendorId: backendInventoryType == 'permanent' ? _rentalVendorId : null,
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
    final rentalVendors = context.watch<VendorProvider>().rentalVendors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      margin: EdgeInsets.only(top: kToolbarHeight),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.generator != null ? 'Edit Genset' : 'Add New Genset',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('INVENTORY GROUP *'),
                    DropdownButtonFormField<String>(
                      value: _inventoryType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _inventoryTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _inventoryType = v!;
                          if (_mapInventoryTypeToBackend(_inventoryType) != 'permanent') {
                            _rentalVendorId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel('CAPACITY (KVA) *'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _capacities.map((cap) {
                        final isSelected = _capacityKva == cap;
                        return ChoiceChip(
                          label: Text('${cap} kVA'),
                          showCheckmark: false,
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _capacityKva = cap);
                          },
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('TYPE *'),
                    TextFormField(
                      controller: _typeController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Silent, Open',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Type is required' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('IDENTIFICATION (OPTIONAL)'),
                    TextFormField(
                      controller: _identificationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Number Plate, Serial',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('OPERATIONAL STATUS'),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 20),

                    if (_mapInventoryTypeToBackend(_inventoryType) == 'permanent') ...[
                      _buildLabel('RENTAL VENDOR *'),
                      if (context.watch<VendorProvider>().isRentalVendorsLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text('Loading rental vendors...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      else if (rentalVendors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text('No rental vendors available. Please add one first.', style: TextStyle(color: Colors.red)),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: _rentalVendorId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: rentalVendors.map((rv) => DropdownMenuItem(value: rv.rentalVendorId, child: Text(rv.name))).toList(),
                          onChanged: (v) => setState(() => _rentalVendorId = v),
                          validator: (v) => _mapInventoryTypeToBackend(_inventoryType) == 'permanent' && (v == null || v.isEmpty)
                              ? 'Rental Vendor is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],

                    _buildLabel('NOTES (OPTIONAL)'),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Genset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
