import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';

class StatusFilterChip extends StatelessWidget {
  final String label;
  final CharacterStatus? status;
  final bool isSelected;
  final VoidCallback onSelected;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.status,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        textAlign: TextAlign.center,
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: Colors.teal,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Colors.tealAccent,
          width: 1,
        ),
      ),
      labelStyle: TextStyle(
          height: 0,
          color: isSelected ? Theme.of(context).primaryColor : Colors.teal[50],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 18),
    );
  }
}
