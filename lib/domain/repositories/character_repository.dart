import 'package:dartz/dartz.dart';

import '../entities/character.dart';
import '../../core/errors/failures.dart';

abstract class CharacterRepository {
  Future<Either<Failure, List<Character>>> getCharacters({
    int page = 1,
    CharacterStatus? status,
    String? name, // ← Adicionar parâmetro de busca
  });

  Future<Either<Failure, Character>> getCharacterById(int id);
}
