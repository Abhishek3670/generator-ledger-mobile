import 'package:flutter/material.dart';

class CapacitySelector extends StatelessWidget {
  final int? selectedCapacity;
  final ValueChanged<int> onSelected;
  final List<int> capacities;

  const CapacitySelector({
    super.key,
    this.selectedCapacity,
    required this.onSelected,
    required this.capacities,
  });

  @override
  Widget build(BuildContext context) {
    if (capacities.isEmpty) {
      return const Text('No capacities available.', style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: capacities.map((capacity) {
          final isSelected = selectedCapacity == capacity;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text('$capacity kVA'),
              selected: isSelected,
              onSelected: (_) => onSelected(capacity),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0F172A),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
