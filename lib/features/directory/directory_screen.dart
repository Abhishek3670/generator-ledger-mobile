import 'package:flutter/material.dart';
import '../vendors/vendors_screen.dart';
import '../generators/generators_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                label: Text('Vendors'),
                icon: Icon(Icons.business),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text('Generators'),
                icon: Icon(Icons.power),
              ),
            ],
            selected: {_selectedIndex},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _selectedIndex = newSelection.first;
              });
            },
            showSelectedIcon: false,
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              VendorsScreen(),
              GeneratorsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
