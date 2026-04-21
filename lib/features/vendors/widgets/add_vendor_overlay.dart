import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../../../core/models/vendor.dart';

class AddVendorOverlay extends StatefulWidget {
  final Vendor? vendor;
  final RentalVendor? rentalVendor;
  final bool isRental;

  const AddVendorOverlay({
    super.key,
    this.vendor,
    this.rentalVendor,
    required this.isRental,
  });

  static void show(
    BuildContext context, {
    Vendor? vendor,
    RentalVendor? rentalVendor,
    required bool isRental,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddVendorOverlay(
        vendor: vendor,
        rentalVendor: rentalVendor,
        isRental: isRental,
      ),
    );
  }

  @override
  State<AddVendorOverlay> createState() => _AddVendorOverlayState();
}

class _AddVendorOverlayState extends State<AddVendorOverlay> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late TextEditingController _phoneController;

  bool _isSubmitting = false;

  bool get _isEditMode => widget.vendor != null || widget.rentalVendor != null;

  String get _currentId => widget.vendor?.id ?? widget.rentalVendor?.rentalVendorId ?? '';

  @override
  void initState() {
    super.initState();
    final name = widget.vendor?.name ?? widget.rentalVendor?.name ?? '';
    final place = widget.vendor?.place ?? widget.rentalVendor?.place ?? '';
    final phone = widget.vendor?.phone ?? widget.rentalVendor?.phone ?? '';

    _idController = TextEditingController(text: _isEditMode ? _currentId : '');
    _nameController = TextEditingController(text: name);
    _placeController = TextEditingController(text: place);
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<VendorProvider>();

    try {
      final idInput = _idController.text.trim();
      final id = idInput.isEmpty ? null : idInput;

      if (widget.isRental) {
        if (_isEditMode) {
          await provider.updateRentalVendor(
            _currentId,
            name: _nameController.text.trim(),
            place: _placeController.text.trim(),
            phone: _phoneController.text.trim(),
          );
        } else {
          await provider.createRentalVendor(
            rentalVendorId: id,
            name: _nameController.text.trim(),
            place: _placeController.text.trim(),
            phone: _phoneController.text.trim(),
          );
        }
      } else {
        if (_isEditMode) {
          await provider.updateVendor(
            _currentId,
            name: _nameController.text.trim(),
            place: _placeController.text.trim(),
            phone: _phoneController.text.trim(),
          );
        } else {
          await provider.createVendor(
            vendorId: id,
            name: _nameController.text.trim(),
            place: _placeController.text.trim(),
            phone: _phoneController.text.trim(),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isRental
                  ? provider.rentalVendorsError ?? e.toString()
                  : provider.vendorsError ?? e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRental ? 'Delete Rental Vendor' : 'Delete Retailer Vendor'),
        content: Text('Are you sure you want to delete ${_nameController.text}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              setState(() => _isSubmitting = true);
              final provider = context.read<VendorProvider>();
              try {
                if (widget.isRental) {
                  await provider.deleteRentalVendor(_currentId);
                } else {
                  await provider.deleteVendor(_currentId);
                }
                if (mounted) Navigator.pop(context); // Close overlay
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.isRental
                            ? provider.rentalVendorsError ?? e.toString()
                            : provider.vendorsError ?? e.toString(),
                      ),
                    ),
                  );
                  setState(() => _isSubmitting = false);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final entityName = widget.isRental ? 'Rental Vendor' : 'Retailer Vendor';
    final idLabel = widget.isRental ? 'RENTAL VENDOR ID' : 'VENDOR ID';
    final nameLabel = widget.isRental ? 'PROPERTY NAME *' : 'VENDOR NAME *';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(top: kToolbarHeight),
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
                  _isEditMode ? 'Edit $entityName' : 'Add New $entityName',
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
                    _buildLabel('$idLabel${_isEditMode ? "" : " (OPTIONAL)"}'),
                    TextFormField(
                      controller: _idController,
                      enabled: !_isEditMode,
                      decoration: InputDecoration(
                        hintText: _isEditMode ? null : 'e.g., VEND-001',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: _isEditMode,
                        fillColor: _isEditMode ? Colors.grey.shade100 : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel(nameLabel),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '${widget.isRental ? "Property" : "Vendor"} Name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('LOCATION'),
                    TextFormField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Civil Line',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('PHONE'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),

                    if (_isEditMode) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _confirmDelete,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: Text('Delete $entityName', style: const TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                    ]
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Save $entityName', style: const TextStyle(fontWeight: FontWeight.bold)),
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
