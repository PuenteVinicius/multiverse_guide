import 'package:equatable/equatable.dart';

import '../../domain/entities/character.dart';

class CharacterModel extends Equatable {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final LocationModel location;
  final LocationModel origin;
  final List<String> episode;
  final DateTime created;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.location,
    required this.origin,
    required this.episode,
    required this.created,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Nome desconhecido',
      status: json['status'] ?? 'unknown',
      species: json['species'] ?? 'Desconhecida',
      type: json['type'] ?? '',
      gender: json['gender'] ?? 'unknown',
      image: json['image'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      origin: LocationModel.fromJson(json['origin'] ?? {}),
      episode: List<String>.from(json['episode'] ?? []),
      created: DateTime.parse(json['created'] ?? DateTime.now().toString()),
    );
  }

  Character toEntity() {
    return Character(
      id: id,
      name: name,
      status: _mapStatus(status),
      species: species,
      type: type,
      gender: gender,
      image: image,
      location: location.name,
      origin: origin.name,
      episode: episode,
      created: created,
    );
  }

  CharacterStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return CharacterStatus.alive;
      case 'dead':
        return CharacterStatus.dead;
      default:
        return CharacterStatus.unknown;
    }
  }

  @override
  List<Object?> get props => [id];
}

class LocationModel extends Equatable {
  final String name;
  final String url;

  const LocationModel({required this.name, required this.url});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? 'Desconhecido',
      url: json['url'] ?? '',
    );
  }

  @override
  List<Object?> get props => [name, url];
}
