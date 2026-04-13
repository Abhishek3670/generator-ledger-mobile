import 'package:flutter/material.dart';

class DirectorySearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const DirectorySearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SearchBar(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        leading: const Icon(Icons.search),
        trailing: [
          if (controller != null && controller!.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller!.clear();
                onChanged('');
                if (onClear != null) onClear!();
              },
            ),
        ],
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
        ),
      ),
    );
  }
}
