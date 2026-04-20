import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/generator.dart';
import '../../../core/auth/permission_service.dart';
import '../../generators/widgets/generator_form.dart';

class GensetCard extends StatelessWidget {
  final Generator generator;

  const GensetCard({super.key, required this.generator});

  void _editGenerator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GeneratorForm(generator: generator),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('generator_management');
    
    // Status colors
    Color statusColor;
    switch (generator.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.teal; // Emerald
        break;
      case 'maintenance':
        statusColor = Colors.amber; // Amber
        break;
      default:
        statusColor = Colors.redAccent; // Rose
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    'ID: ${generator.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    generator.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editGenerator(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Capacity: ${generator.capacity} kVA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Type: ${generator.type}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
