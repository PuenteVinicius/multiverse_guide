import 'package:dartz/dartz.dart';

import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/character_remote_data_source.dart';
import '../../core/errors/failures.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource remoteDataSource;

  CharacterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Character>>> getCharacters({
    int page = 1,
    CharacterStatus? status,
    String? name, // ← Adicionar parâmetro de busca
  }) async {
    try {
      final response = await remoteDataSource.getCharacters(
        page: page,
        status: _statusToString(status),
        name: name,
      );

      final characters = response.results
          .map((characterModel) => characterModel.toEntity())
          .toList();

      return Right(characters);
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<Either<Failure, Character>> getCharacterById(int id) async {
    // Implementaremos depois
    throw UnimplementedError();
  }

  String? _statusToString(CharacterStatus? status) {
    switch (status) {
      case CharacterStatus.alive:
        return 'alive';
      case CharacterStatus.dead:
        return 'dead';
      case CharacterStatus.unknown:
        return 'unknown';
      default:
        return null;
    }
  }
}
