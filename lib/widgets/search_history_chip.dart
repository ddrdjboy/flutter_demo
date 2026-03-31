import 'package:flutter/material.dart';

class SearchHistoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SearchHistoryChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
