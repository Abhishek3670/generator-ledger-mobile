import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/generator_provider.dart';
import '../../../core/models/generator.dart';
import 'generator_form.dart';
import '../../../core/auth/permission_service.dart';
import '../../../shared/widgets/state_widgets.dart';

class GeneratorList extends StatelessWidget {
  final String inventoryType;

  const GeneratorList({super.key, required this.inventoryType});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneratorProvider>(
      builder: (context, provider, child) {
        final filteredGenerators = provider.generators
            .where((g) => g.inventoryType == inventoryType)
            .toList();

        if (provider.isLoading && provider.generators.isEmpty) {
          return LoadingState(message: 'Loading $inventoryType generators...');
        }

        if (provider.error != null && provider.generators.isEmpty) {
          return ErrorState(
            message: provider.error!,
            onRetry: () => provider.fetchGenerators(),
          );
        }

        if (filteredGenerators.isEmpty) {
          return EmptyState(
            message: 'No $inventoryType generators found',
            subMessage: 'Try a different category or adjusting your search.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchGenerators(),
          child: ListView.builder(
            itemCount: filteredGenerators.length,
            itemBuilder: (context, index) {
              final generator = filteredGenerators[index];
              return GeneratorCard(generator: generator);
            },
          ),
        );
      },
    );
  }
}

class GeneratorCard extends StatelessWidget {
  final Generator generator;

  const GeneratorCard({super.key, required this.generator});

  void _editGenerator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GeneratorForm(generator: generator),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.read<PermissionService>().can('generator_management');
    Color statusColor;
    switch (generator.inventoryType.toLowerCase()) {
      case 'permanent':
        statusColor = Colors.amber;
        break;
      case 'emergency':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        label: 'Generator: ${generator.identification}, Type: ${generator.type}, Status: ${generator.status}',
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Text(
              '${generator.capacity}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(generator.identification),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${generator.type} • ${generator.status}'),
              if (generator.inventoryType == 'permanent' && generator.rentalVendorName != null)
                Text(
                  'Assigned to: ${generator.rentalVendorName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          isThreeLine: generator.inventoryType == 'permanent',
          trailing: canManage
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editGenerator(context),
                  tooltip: 'Edit Generator',
                )
              : null,
        ),
      ),
    );
  }
}
