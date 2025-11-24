import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiverse_guide/core/errors/failures.dart';
import 'package:multiverse_guide/domain/entities/character.dart';
import 'package:multiverse_guide/domain/repositories/character_repository.dart';
import 'package:multiverse_guide/domain/usecases/get_characters.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late GetCharacters usecase;
  late MockCharacterRepository mockCharacterRepository;

  setUp(() {
    mockCharacterRepository = MockCharacterRepository();
    usecase = GetCharacters(mockCharacterRepository);
  });

  final tCharacters = [
    Character(
      id: 1,
      name: 'Rick Sanchez',
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: 'Male',
      image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      location: 'Earth',
      origin: 'Earth',
      episode: const ['https://rickandmortyapi.com/api/episode/1'],
      created: DateTime(2017, 11, 4),
    ),
  ];

  group('GetCharacters', () {
    test('should get list of characters from the repository', () async {
      // Arrange
      when(() => mockCharacterRepository.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => const Right(Character));

      // Act
      final result = await usecase(GetCharactersParams());

      // Assert
      expect(result, const Right(tCharacters));
      verify(() => mockCharacterRepository.getCharacters(
            page: 1,
            status: null,
            name: null,
          )).called(1);
      verifyNoMoreInteractions(mockCharacterRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockCharacterRepository.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(GetCharactersParams());

      // Assert
      expect(result, Left(ServerFailure()));
      verify(() => mockCharacterRepository.getCharacters(
            page: 1,
            status: null,
            name: null,
          )).called(1);
    });

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(() => mockCharacterRepository.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => const Right(tCharacters));

      // Act
      await usecase(GetCharactersParams(
        page: 2,
        status: CharacterStatus.alive,
        name: 'Rick',
      ));

      // Assert
      verify(() => mockCharacterRepository.getCharacters(
            page: 2,
            status: CharacterStatus.alive,
            name: 'Rick',
          )).called(1);
    });
  });
}
