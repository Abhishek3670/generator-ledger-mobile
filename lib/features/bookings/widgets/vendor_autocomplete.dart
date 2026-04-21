import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vendors/providers/vendor_provider.dart';
import '../../../core/models/vendor.dart';

class VendorAutocomplete extends StatelessWidget {
  final Vendor? initialVendor;
  final ValueChanged<Vendor?> onSelected;

  const VendorAutocomplete({
    super.key,
    this.initialVendor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final vendors = context.watch<VendorProvider>().allVendors;

    return Autocomplete<Vendor>(
      initialValue: TextEditingValue(text: initialVendor?.name ?? ''),
      displayStringForOption: (Vendor option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Vendor>.empty();
        }
        return vendors.where((Vendor option) {
          return option.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()) ||
              option.id
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (Vendor selection) {
        onSelected(selection);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: 'Search and select vendor',
            hintText: 'e.g., City Power Rentals',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
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
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<Vendor> onSelected,
          Iterable<Vendor> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200.0,
              width: MediaQuery.of(context).size.width - 48, // Padding 24x2
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Vendor option = options.elementAt(index);
                  return ListTile(
                    title: Text(
                      option.name,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    subtitle: Text(
                      option.id,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
