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
      backgroundColor: Theme.of(context).primaryColor,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.black,
            title: Text(
              'Detalhes do Personagem',
              style: TextStyle(color: Colors.white),
            ),
            stretch: true,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 16),
                    _buildStatusSection(),
                    const SizedBox(height: 16),
                    _buildPersonalInformationSection(),
                    const SizedBox(height: 16),
                    _buildOriginAndLocationSection(),
                    const SizedBox(height: 16),
                    _buildEpisodes(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return SizedBox(
      width: double.infinity,
      child: Hero(
        tag: 'character-${character.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: CachedNetworkImage(
            imageUrl: character.image,
            fit: BoxFit.fitWidth,
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
    );
  }

  Widget _buildPersonalInformationSection() {
    return DetailSection(
      title: 'Informações Pessoais',
      icon: Icons.person_2_outlined,
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
        ],
      ),
    );
  }

  Widget _buildOriginAndLocationSection() {
    return DetailSection(
      title: 'Origem e Localização',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          InfoRow(
            label: 'Origem',
            value:
                character.origin.isNotEmpty ? character.origin : 'Desconhecida',
          ),
          InfoRow(
              label: 'Localização',
              value: character.location.isNotEmpty
                  ? character.location
                  : 'Desconhecida'),
        ],
      ),
    );
  }

  Widget _buildEpisodes() {
    return DetailSection(
      icon: Icons.live_tv_outlined,
      title: 'Aparições',
      child: Column(
        children: [
          InfoRow(label: 'Episódios', value: '${character.episode.length}')
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return StatusBadge(status: character.status);
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
}
