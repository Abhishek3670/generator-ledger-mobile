import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateChipsPicker extends StatelessWidget {
  final List<DateTime> selectedDates;
  final ValueChanged<List<DateTime>> onDatesChanged;

  const DateChipsPicker({
    super.key,
    required this.selectedDates,
    required this.onDatesChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0F172A),
            colorScheme: const ColorScheme.light(primary: Color(0xFF0F172A)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Check if it's already added to avoid duplicates based on yyyy-mm-dd
      final normalizedPicked = DateTime(picked.year, picked.month, picked.day);
      final exists = selectedDates.any((d) =>
          d.year == normalizedPicked.year &&
          d.month == normalizedPicked.month &&
          d.day == normalizedPicked.day);

      if (!exists) {
        final newDates = List<DateTime>.from(selectedDates)..add(normalizedPicked);
        onDatesChanged(newDates);
      }
    }
  }

  void _removeDate(DateTime date) {
    final newDates = List<DateTime>.from(selectedDates)..remove(date);
    onDatesChanged(newDates);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedDates.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedDates.map((date) {
              return Chip(
                label: Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                backgroundColor: const Color(0xFF0F172A),
                deleteIcon: const Icon(Icons.close, color: Colors.white, size: 16),
                onDeleted: () => _removeDate(date),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
        if (selectedDates.isNotEmpty) const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _pickDate(context),
          icon: const Icon(Icons.calendar_today, size: 18),
          label: const Text('Add Date'),
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
