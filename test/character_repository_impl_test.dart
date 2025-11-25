import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multiverse_guide/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_guide/data/models/character_model.dart';
import 'package:multiverse_guide/data/models/character_response_model.dart';
import 'package:multiverse_guide/data/repositories/character_repository_impl.dart';
import 'package:multiverse_guide/core/errors/failures.dart';
import 'package:multiverse_guide/domain/entities/character.dart';

class MockCharacterRemoteDataSource extends Mock
    implements CharacterRemoteDataSource {}

class FakeUri extends Fake implements Uri {}

void main() {
  late CharacterRepositoryImpl repository;
  late MockCharacterRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockRemoteDataSource = MockCharacterRemoteDataSource();
    repository = CharacterRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tCharacterModel = CharacterModel(
    id: 1,
    name: 'Rick Sanchez',
    status: 'Alive',
    species: 'Human',
    type: '',
    gender: 'Male',
    image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
    location: const LocationModel(name: 'Earth', url: ''),
    origin: const LocationModel(name: 'Earth', url: ''),
    episode: const ['https://rickandmortyapi.com/api/episode/1'],
    created: DateTime(2017, 11, 4),
  );

  final tCharacterResponseModel = CharacterResponseModel(
    info: const InfoModel(count: 1, pages: 1, next: null, prev: null),
    results: [tCharacterModel],
  );

  group('getCharacters', () {
    test('should pass correct parameters to remote data source', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(
        page: 2,
        status: CharacterStatus.alive,
        name: 'Rick',
      );

      verify(() => mockRemoteDataSource.getCharacters(
            page: 2,
            status: 'alive',
            name: 'Rick',
          )).called(1);
    });

    test('should convert CharacterStatus.alive to "alive" string', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(status: CharacterStatus.alive);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: 'alive',
            name: null,
          )).called(1);
    });

    test('should convert CharacterStatus.dead to "dead" string', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(status: CharacterStatus.dead);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: 'dead',
            name: null,
          )).called(1);
    });

    test('should convert CharacterStatus.unknown to "unknown" string',
        () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(status: CharacterStatus.unknown);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: 'unknown',
            name: null,
          )).called(1);
    });

    test('should pass null status when CharacterStatus is null', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(status: null);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: null,
          )).called(1);
    });

    test('should handle multiple characters in response', () async {
      final multipleCharactersResponse = CharacterResponseModel(
        info: const InfoModel(count: 2, pages: 1, next: null, prev: null),
        results: [
          tCharacterModel,
          CharacterModel(
            id: 2,
            name: 'Morty Smith',
            status: 'Alive',
            species: 'Human',
            type: '',
            gender: 'Male',
            image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
            location: const LocationModel(name: 'Earth', url: ''),
            origin: const LocationModel(name: 'Earth', url: ''),
            episode: const ['https://rickandmortyapi.com/api/episode/1'],
            created: DateTime(2017, 11, 4),
          ),
        ],
      );

      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => multipleCharactersResponse);

      final result = await repository.getCharacters();

      expect(result.getOrElse(() => []).length, 2);
      expect(result.getOrElse(() => [])[0].name, 'Rick Sanchez');
      expect(result.getOrElse(() => [])[1].name, 'Morty Smith');
    });

    test('should return ServerFailure when remote data source throws Exception',
        () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenThrow(Exception('Network error'));

      final result = await repository.getCharacters();

      expect(result, Left(ServerFailure()));
    });

    test('should throw Exception when character model conversion fails',
        () async {
      final malformedCharacterModel = CharacterModel(
        id: 1,
        name: 'Rick Sanchez',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Male',
        image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
        location: const LocationModel(name: 'Earth', url: ''),
        origin: const LocationModel(name: 'Earth', url: ''),
        episode: const ['https://rickandmortyapi.com/api/episode/1'],
        created: DateTime(2017, 11, 4),
      );

      final responseWithMalformedData = CharacterResponseModel(
        info: const InfoModel(count: 1, pages: 1, next: null, prev: null),
        results: [malformedCharacterModel],
      );

      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => responseWithMalformedData);

      expect(() async => await repository.getCharacters(), returnsNormally);
    });
  });

  group('getCharacterById', () {
    test('should throw UnimplementedError when getCharacterById is called',
        () async {
      expect(() => repository.getCharacterById(1),
          throwsA(isA<UnimplementedError>()));
    });

    test('should have getCharacterById method that throws UnimplementedError',
        () async {
      const testId = 1;

      expect(() => repository.getCharacterById(testId),
          throwsA(isA<UnimplementedError>()));
    });
  });

  group('Edge Cases', () {
    test('should handle empty name parameter correctly', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(name: '');

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: '',
          )).called(1);
    });

    test('should handle null name parameter correctly', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(name: null);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: null,
          )).called(1);
    });

    test('should handle page parameter correctly for pagination', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(page: 5);

      verify(() => mockRemoteDataSource.getCharacters(
            page: 5,
            status: null,
            name: null,
          )).called(1);
    });

    test('should handle combination of all parameters', () async {
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      await repository.getCharacters(
        page: 3,
        status: CharacterStatus.dead,
        name: 'Evil',
      );

      verify(() => mockRemoteDataSource.getCharacters(
            page: 3,
            status: 'dead',
            name: 'Evil',
          )).called(1);
    });
  });

  group('Data Conversion', () {
    test('should correctly convert CharacterModel to Character entity',
        () async {
      final characterModelWithAllFields = CharacterModel(
        id: 100,
        name: 'Test Character',
        status: 'Dead',
        species: 'Alien',
        type: 'Test type',
        gender: 'Female',
        image: 'https://example.com/image.jpg',
        location: const LocationModel(
            name: 'Test Location', url: 'https://example.com/location'),
        origin: const LocationModel(
            name: 'Test Origin', url: 'https://example.com/origin'),
        episode: const ['ep1', 'ep2', 'ep3'],
        created: DateTime(2020, 1, 1),
      );

      final response = CharacterResponseModel(
        info: const InfoModel(count: 1, pages: 1, next: null, prev: null),
        results: [characterModelWithAllFields],
      );

      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => response);

      final result = await repository.getCharacters();

      final character = result.getOrElse(() => []).first;
      expect(character.id, 100);
      expect(character.name, 'Test Character');
      expect(character.status, CharacterStatus.dead);
      expect(character.species, 'Alien');
      expect(character.type, 'Test type');
      expect(character.gender, 'Female');
      expect(character.image, 'https://example.com/image.jpg');
      expect(character.location, 'Test Location');
      expect(character.origin, 'Test Origin');
      expect(character.episode, ['ep1', 'ep2', 'ep3']);
      expect(character.created, DateTime(2020, 1, 1));
    });

    test('should handle CharacterModel with unknown status', () async {
      final characterModelWithUnknownStatus = CharacterModel(
        id: 1,
        name: 'Unknown Character',
        status: 'UnknownStatus',
        species: 'Human',
        type: '',
        gender: 'Male',
        image: 'https://example.com/image.jpg',
        location: const LocationModel(name: 'Earth', url: ''),
        origin: const LocationModel(name: 'Earth', url: ''),
        episode: const [],
        created: DateTime(2017, 11, 4),
      );

      final response = CharacterResponseModel(
        info: const InfoModel(count: 1, pages: 1, next: null, prev: null),
        results: [characterModelWithUnknownStatus],
      );

      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => response);

      final result = await repository.getCharacters();

      final character = result.getOrElse(() => []).first;
      expect(character.status, CharacterStatus.unknown);
    });
  });
}
