import 'package:equatable/equatable.dart';

enum CharacterStatus { alive, dead, unknown }

class Character extends Equatable {
  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String location;
  final String origin;
  final List<String> episode;
  final DateTime created;

  const Character({
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

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        species,
        type,
        gender,
        image,
        location,
        origin,
        episode,
        created,
      ];

  copyWith({required CharacterStatus status}) {}
}
