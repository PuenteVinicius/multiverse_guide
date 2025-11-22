import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:multiverse_guide/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_guide/data/models/character_model.dart';
import 'package:multiverse_guide/data/models/character_response_model.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late CharacterRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = CharacterRemoteDataSourceImpl(client: mockHttpClient);
  });

  final tCharacterResponseModel = CharacterResponseModel(
    info: InfoModel(count: 1, pages: 1, next: null, prev: null),
    results: [
      CharacterModel(
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
      ),
    ],
  );

  final tJsonResponse = {
    "info": {"count": 1, "pages": 1, "next": null, "prev": null},
    "results": [
      {
        "id": 1,
        "name": "Rick Sanchez",
        "status": "Alive",
        "species": "Human",
        "type": "",
        "gender": "Male",
        "origin": {"name": "Earth", "url": ""},
        "location": {"name": "Earth", "url": ""},
        "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        "episode": ["https://rickandmortyapi.com/api/episode/1"],
        "url": "https://rickandmortyapi.com/api/character/1",
        "created": "2017-11-04T18:48:46.250Z"
      }
    ]
  };

  group('getCharacters', () {
    test('should return CharacterResponseModel when the response is 200',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result, tCharacterResponseModel);
    });

    test('should return empty CharacterResponseModel when the response is 404',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('', 404),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.info.count, 0);
      expect(result.results, isEmpty);
    });

    test('should throw ServerException when the response is not 200 or 404',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA()));
    });

    test('should call http client with correct url and parameters', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(
        page: 2,
        status: 'alive',
        name: 'Rick',
      );

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=2&status=alive&name=Rick',
          ))).called(1);
    });
  });
}
