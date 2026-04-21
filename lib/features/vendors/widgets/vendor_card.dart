import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/vendor.dart';
import '../../../core/auth/permission_service.dart';
import 'add_vendor_overlay.dart';

class VendorCard extends StatelessWidget {
  final Vendor? vendor;
  final RentalVendor? rentalVendor;

  const VendorCard({super.key, this.vendor, this.rentalVendor})
      : assert(vendor != null || rentalVendor != null);

  String get id => vendor?.id ?? rentalVendor!.rentalVendorId;
  String get name => vendor?.name ?? rentalVendor!.name;
  String get place => vendor?.place ?? rentalVendor!.place;
  String get phone => vendor?.phone ?? rentalVendor!.phone;
  bool get isRental => rentalVendor != null;

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('vendor_management');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canManage
            ? () => AddVendorOverlay.show(
                  context,
                  vendor: vendor,
                  rentalVendor: rentalVendor,
                  isRental: isRental,
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _buildInfoItem(isRental ? 'RENTAL VENDOR ID' : 'VENDOR ID', id),
                  _buildInfoItem(isRental ? 'PROPERTY LOCATION' : 'LOCATION', place.isEmpty ? 'Civil Line' : place),
                  _buildInfoItem('PHONE', phone.isEmpty ? '—' : phone),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
