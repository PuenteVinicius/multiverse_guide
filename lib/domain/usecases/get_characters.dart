import 'package:dartz/dartz.dart';

import '../entities/character.dart';
import '../repositories/character_repository.dart';
import '../../core/errors/failures.dart';

class GetCharacters {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  Future<Either<Failure, List<Character>>> call({
    int page = 1,
    CharacterStatus? status,
    String? name,
  }) async {
    return await repository.getCharacters(
        page: page, status: status, name: name);
  }
}

class GetCharactersParams {
  final int page;
  final CharacterStatus? status;
  final String? name;

  GetCharactersParams(map, {this.page = 1, this.status, this.name});
}
