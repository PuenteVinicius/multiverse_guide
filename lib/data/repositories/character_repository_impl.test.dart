import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiverse_guide/core/errors/exceptions.dart';
import 'package:multiverse_guide/core/errors/failures.dart';
import 'package:multiverse_guide/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_guide/data/models/character_model.dart';
import 'package:multiverse_guide/data/models/character_response_model.dart';
import 'package:multiverse_guide/data/repositories/character_repository_impl.dart';
import 'package:multiverse_guide/domain/entities/character.dart';

class MockCharacterRemoteDataSource extends Mock
    implements CharacterRemoteDataSource {}

void main() {
  late CharacterRepositoryImpl repository;
  late MockCharacterRemoteDataSource mockRemoteDataSource;

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
    location: LocationModel(name: 'Earth', url: ''),
    origin: LocationModel(name: 'Earth', url: ''),
    episode: ['https://rickandmortyapi.com/api/episode/1'],
    created: DateTime(2017, 11, 4),
  );

  final tCharacterResponseModel = CharacterResponseModel(
    info: InfoModel(count: 1, pages: 1, next: null, prev: null),
    results: [tCharacterModel],
  );

  final tCharacter = Character(
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
  );

  group('getCharacters', () {
    test(
        'should return remote data when the call to remote data source is successful',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      // Act
      final result = await repository.getCharacters();

      // Assert
      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: null,
          ));
      expect(result, Right([tCharacter]));
    });

    test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenThrow(ServerException());

      // Act
      final result = await repository.getCharacters();

      // Assert
      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: null,
          ));
      expect(result, Left(ServerFailure()));
    });

    test(
        'should return GeneralFailure when remote data source throws other exceptions',
        () async {
      // Arrange
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenThrow(Exception());

      // Act
      final result = await repository.getCharacters();

      // Assert
      verify(() => mockRemoteDataSource.getCharacters(
            page: 1,
            status: null,
            name: null,
          ));
      expect(result, Left(GeneralFailure()));
    });

    test('should pass correct parameters to remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCharacters(
            page: any(named: 'page'),
            status: any(named: 'status'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => tCharacterResponseModel);

      // Act
      await repository.getCharacters(
        page: 2,
        status: CharacterStatus.alive,
        name: 'Rick',
      );

      // Assert
      verify(() => mockRemoteDataSource.getCharacters(
            page: 2,
            status: 'alive',
            name: 'Rick',
          ));
    });
  });
}
