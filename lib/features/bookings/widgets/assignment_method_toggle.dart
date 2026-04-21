import 'package:flutter/material.dart';

enum AssignmentMethod { capacity, specificGenerator }

class AssignmentMethodToggle extends StatelessWidget {
  final AssignmentMethod selectedMethod;
  final ValueChanged<AssignmentMethod> onChanged;

  const AssignmentMethodToggle({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              context,
              'By Capacity',
              AssignmentMethod.capacity,
            ),
          ),
          Expanded(
            child: _buildButton(
              context,
              'Specific Generator',
              AssignmentMethod.specificGenerator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, AssignmentMethod method) {
    final isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => onChanged(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
