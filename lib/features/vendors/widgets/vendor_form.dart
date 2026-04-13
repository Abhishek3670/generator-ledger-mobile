import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../../../core/models/vendor.dart';

class VendorForm extends StatefulWidget {
  final Vendor? vendor;
  final RentalVendor? rentalVendor;
  final bool isRental;

  const VendorForm({
    super.key,
    this.vendor,
    this.rentalVendor,
    this.isRental = false,
  });

  @override
  State<VendorForm> createState() => _VendorFormState();
}

class _VendorFormState extends State<VendorForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late TextEditingController _phoneController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(
      text: widget.isRental
          ? widget.rentalVendor?.rentalVendorId
          : widget.vendor?.id,
    );
    _nameController = TextEditingController(
      text: widget.isRental ? widget.rentalVendor?.name : widget.vendor?.name,
    );
    _placeController = TextEditingController(
      text: (widget.isRental
              ? widget.rentalVendor?.place
              : widget.vendor?.place) ??
          '',
    );
    _phoneController = TextEditingController(
      text: (widget.isRental
              ? widget.rentalVendor?.phone
              : widget.vendor?.phone) ??
          '',
    );
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
      final name = _nameController.text.trim();
      final place = _placeController.text.trim().isEmpty
          ? 'Civil Line'
          : _placeController.text.trim();
      final phone = _phoneController.text.trim();
      final id = _idController.text.trim();

      if (widget.isRental) {
        if (widget.rentalVendor != null) {
          await provider.updateRentalVendor(
            widget.rentalVendor!.rentalVendorId,
            name: name,
            place: place,
            phone: phone,
          );
        } else {
          await provider.createRentalVendor(
            rentalVendorId: id.isEmpty ? null : id,
            name: name,
            place: place,
            phone: phone,
          );
        }
      } else {
        if (widget.vendor != null) {
          await provider.updateVendor(
            widget.vendor!.id,
            name: name,
            place: place,
            phone: phone,
          );
        } else {
          await provider.createVendor(
            vendorId: id.isEmpty ? null : id,
            name: name,
            place: place,
            phone: phone,
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final error = widget.isRental
            ? provider.rentalVendorsError
            : provider.vendorsError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vendor != null || widget.rentalVendor != null;
    final title = isEditing
        ? 'Edit ${widget.isRental ? 'Rental Partner' : 'Retailer'}'
        : 'Add ${widget.isRental ? 'Rental Partner' : 'Retailer'}';

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing)
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: 'ID (Optional)',
                    hintText: widget.isRental ? 'RNV...' : 'VEN...',
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: 'Place',
                  hintText: 'Default: Civil Line',
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
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
