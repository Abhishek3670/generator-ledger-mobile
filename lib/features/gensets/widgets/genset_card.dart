import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generators/providers/generator_provider.dart';
import '../../../core/models/generator.dart';
import '../../../core/auth/permission_service.dart';
import 'add_genset_overlay.dart';

class GensetCard extends StatelessWidget {
  final Generator generator;
  final DateTime? selectedDate;

  const GensetCard({super.key, required this.generator, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('generator_management');
    
    // Status colors
    Color statusColor;
    Color statusBgColor;
    switch (generator.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green.shade700;
        statusBgColor = Colors.green.shade50;
        break;
      case 'maintenance':
        statusColor = Colors.orange.shade800;
        statusBgColor = Colors.orange.shade50;
        break;
      default:
        statusColor = Colors.red.shade700;
        statusBgColor = Colors.red.shade50;
    }

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
        onTap: canManage ? () => AddGensetOverlay.show(context, generator: generator) : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      generator.id,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      generator.status,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _buildInfoItem('Capacity (kVA)', generator.capacity.toString()),
                  _buildInfoItem('Type', generator.type),
                  if (generator.identification.isNotEmpty)
                    _buildInfoItem('Identification', generator.identification),
                ],
              ),
              const SizedBox(height: 12),
              if (generator.inventoryType.toLowerCase() == 'permanent' && generator.rentalVendorName != null) ...[
                _buildInfoItem('Rental Vendor', generator.rentalVendorName!),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: generator.inventoryType.toLowerCase() == 'permanent'
                        ? _buildInfoItem('Booking Status', 'N/A', valueColor: Colors.grey)
                        : selectedDate == null 
                            ? _buildInfoItem('Booking Status', '—', valueColor: Colors.grey)
                            : FutureBuilder<Map<String, dynamic>>(
                                future: context.read<GeneratorProvider>().getGeneratorBookings(
                                  generator.id, 
                                  "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return _buildInfoItem('Booking Status', 'Loading...');
                                  }
                                  if (snapshot.hasError) {
                                    return _buildInfoItem('Booking Status', 'Error');
                                  }
                                  final data = snapshot.data;
                                  final count = data?['count'] ?? 0;
                                  return _buildInfoItem(
                                    'Booking Status', 
                                    count > 0 ? 'Booked' : 'Free',
                                    valueColor: count > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                                  );
                                },
                              ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildInfoItem('Notes', generator.notes?.isEmpty ?? true ? '—' : generator.notes!),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13, 
            color: valueColor ?? Colors.black87,
            fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
