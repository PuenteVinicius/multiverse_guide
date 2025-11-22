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
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
