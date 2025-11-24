import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/character.dart';
import '../../widgets/detail_section.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_badge.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'character-${character.id}',
                child: CachedNetworkImage(
                  imageUrl: character.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareCharacter(context),
              ),
            ],
          ),
          // Conteúdo
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 16),
                    _buildLocationSection(),
                    const SizedBox(height: 16),
                    _buildEpisodesSection(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return DetailSection(
      title: 'Informações do Personagem',
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            character.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          StatusBadge(status: character.status),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return DetailSection(
      title: 'Detalhes',
      child: Column(
        children: [
          InfoRow(
            label: 'Espécie',
            value: character.species.isNotEmpty
                ? character.species
                : 'Desconhecida',
          ),
          InfoRow(
            label: 'Gênero',
            value: _getGenderText(character.gender),
          ),
          InfoRow(
            label: 'Tipo',
            value:
                character.type.isNotEmpty ? character.type : 'Não especificado',
          ),
          InfoRow(
            label: 'Criado em',
            value: _formatDate(character.created),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return DetailSection(
      title: 'Localizações',
      child: Column(
        children: [
          InfoRow(
            label: 'Origem',
            value:
                character.origin.isNotEmpty ? character.origin : 'Desconhecida',
            trailing: character.origin.isNotEmpty
                ? const Icon(
                    Icons.public,
                    color: Colors.blue,
                    size: 18,
                  )
                : null,
          ),
          InfoRow(
            label: 'Localização',
            value: character.location.isNotEmpty
                ? character.location
                : 'Desconhecida',
            trailing: character.location.isNotEmpty
                ? const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 18,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection() {
    return DetailSection(
      title: 'Participação',
      child: Column(
        children: [
          InfoRow(
            label: 'Episódios',
            value: 'Aparece em ${character.episode.length} episódio(s)',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                character.episode.length.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (character.episode.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Lista de episódios disponível na API',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGenderText(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Feminino';
      case 'genderless':
        return 'Sem gênero';
      default:
        return 'Desconhecido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _shareCharacter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhar ${character.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
