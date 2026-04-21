import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../generators/providers/generator_provider.dart';

class GeneratorDropdown extends StatelessWidget {
  final String? selectedGeneratorId;
  final ValueChanged<String?> onChanged;

  const GeneratorDropdown({
    super.key,
    this.selectedGeneratorId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allGenerators = context.watch<GeneratorProvider>().generators;
    final isLoading = context.watch<GeneratorProvider>().isLoading;

    // P11-C2-003: Exclude permanent inventory — only bookable generators
    // (retailer + emergency) are selectable, matching backend _bookable_generators()
    final generators = allGenerators
        .where((g) => g.inventoryType != 'permanent')
        .toList();

    if (isLoading && allGenerators.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<String>(
      value: selectedGeneratorId,
      decoration: InputDecoration(
        labelText: 'Select Generator',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F172A)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: generators.map((g) {
        final emergencyFlag =
            g.inventoryType == 'emergency' ? ' • Emergency' : '';
        return DropdownMenuItem(
          value: g.id,
          child: Text(
            '${g.identification} - ${g.capacity} kVA$emergencyFlag',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
