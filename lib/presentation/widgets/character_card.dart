import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Colors.teal,
          width: 2.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            children: [
              _buildCharacterAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCharacterInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterAvatar() {
    return Hero(
      tag: 'character-${character.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: character.image,
          width: 160,
          height: 160,
          fit: BoxFit.fill,
          placeholder: (context, url) => Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          character.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${_getStatusText(character.status)} - ${character.species}",
              style: TextStyle(
                fontSize: 18,
                color: _getStatusColor(character.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          character.location,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[300],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.alive:
        return Colors.green;
      case CharacterStatus.dead:
        return Colors.red;
      case CharacterStatus.unknown:
        return Colors.orange;
    }
  }

  String _getStatusText(CharacterStatus status) {
    switch (status) {
      case CharacterStatus.alive:
        return 'Vivo';
      case CharacterStatus.dead:
        return 'Morto';
      case CharacterStatus.unknown:
        return 'Desconhecido';
    }
  }
}
