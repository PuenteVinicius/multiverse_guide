import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';

class StatusBadge extends StatelessWidget {
  final CharacterStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.alive:
        return Colors.green;
      case CharacterStatus.dead:
        return Colors.red;
      case CharacterStatus.unknown:
        return Colors.grey;
    }
  }

  String _getStatusText(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.alive:
        return 'Vivo';
      case CharacterStatus.dead:
        return 'Morto';
      case CharacterStatus.unknown:
        return 'Status Desconhecido';
    }
  }
}
