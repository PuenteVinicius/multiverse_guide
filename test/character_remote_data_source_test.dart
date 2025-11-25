import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:multiverse_guide/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_guide/data/models/character_model.dart';
import 'package:multiverse_guide/data/models/character_response_model.dart';

// Mocks
class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late CharacterRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = CharacterRemoteDataSourceImpl(client: mockHttpClient);
  });

  // Test data
  final tJsonResponse = {
    "info": {"count": 2, "pages": 1, "next": null, "prev": null},
    "results": [
      {
        "id": 1,
        "name": "Rick Sanchez",
        "status": "Alive",
        "species": "Human",
        "type": "",
        "gender": "Male",
        "origin": {
          "name": "Earth (C-137)",
          "url": "https://rickandmortyapi.com/api/location/1"
        },
        "location": {
          "name": "Earth (Replacement Dimension)",
          "url": "https://rickandmortyapi.com/api/location/20"
        },
        "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        "episode": [
          "https://rickandmortyapi.com/api/episode/1",
          "https://rickandmortyapi.com/api/episode/2"
        ],
        "url": "https://rickandmortyapi.com/api/character/1",
        "created": "2017-11-04T18:48:46.250Z"
      },
      {
        "id": 2,
        "name": "Morty Smith",
        "status": "Alive",
        "species": "Human",
        "type": "",
        "gender": "Male",
        "origin": {
          "name": "Earth (C-137)",
          "url": "https://rickandmortyapi.com/api/location/1"
        },
        "location": {
          "name": "Earth (Replacement Dimension)",
          "url": "https://rickandmortyapi.com/api/location/20"
        },
        "image": "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
        "episode": [
          "https://rickandmortyapi.com/api/episode/1",
          "https://rickandmortyapi.com/api/episode/2"
        ],
        "url": "https://rickandmortyapi.com/api/character/2",
        "created": "2017-11-04T18:50:21.651Z"
      }
    ]
  };

  final tCharacterResponseModel = CharacterResponseModel(
    info: const InfoModel(
      count: 2,
      pages: 1,
      next: null,
      prev: null,
    ),
    results: [
      CharacterModel(
        id: 1,
        name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        type: "",
        gender: "Male",
        origin: const LocationModel(
            name: "Earth (C-137)",
            url: "https://rickandmortyapi.com/api/location/1"),
        location: const LocationModel(
            name: "Earth (Replacement Dimension)",
            url: "https://rickandmortyapi.com/api/location/20"),
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: const [
          "https://rickandmortyapi.com/api/episode/1",
          "https://rickandmortyapi.com/api/episode/2"
        ],
        created: DateTime.parse("2017-11-04T18:48:46.250Z"),
      ),
      CharacterModel(
        id: 2,
        name: "Morty Smith",
        status: "Alive",
        species: "Human",
        type: "",
        gender: "Male",
        origin: const LocationModel(
            name: "Earth (C-137)",
            url: "https://rickandmortyapi.com/api/location/1"),
        location: const LocationModel(
            name: "Earth (Replacement Dimension)",
            url: "https://rickandmortyapi.com/api/location/20"),
        image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
        episode: const [
          "https://rickandmortyapi.com/api/episode/1",
          "https://rickandmortyapi.com/api/episode/2"
        ],
        created: DateTime.parse("2017-11-04T18:50:21.651Z"),
      ),
    ],
  );

  final tEmptyJsonResponse = {
    "info": {"count": 0, "pages": 0, "next": null, "prev": null},
    "results": []
  };

  const tEmptyCharacterResponseModel = CharacterResponseModel(
    info: InfoModel(count: 0, pages: 0, next: null, prev: null),
    results: [],
  );

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
      expect(result.info.count, tCharacterResponseModel.info.count);
      expect(result.info.pages, tCharacterResponseModel.info.pages);
      expect(result.results.length, tCharacterResponseModel.results.length);
      expect(result.results[0].name, tCharacterResponseModel.results[0].name);
      expect(result.results[1].name, tCharacterResponseModel.results[1].name);
    });

    test('should return empty CharacterResponseModel when the response is 404',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tEmptyJsonResponse), 404),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.info.count, 0);
      expect(result.info.pages, 0);
      expect(result.results, isEmpty);
      expect(result, tEmptyCharacterResponseModel);
    });

    test('should throw Exception when the response is not 200 or 404',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should throw Exception when the response has malformed JSON',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Invalid JSON', 200),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should call http client with correct base URL and default parameters',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters();

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should call http client with correct URL when page is specified',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(page: 2);

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=2',
          ))).called(1);
    });

    test('should call http client with correct URL when status is specified',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(status: 'alive');

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&status=alive',
          ))).called(1);
    });

    test('should call http client with correct URL when name is specified',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(name: 'Rick');

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&name=Rick',
          ))).called(1);
    });

    test(
        'should call http client with correct URL when all parameters are specified',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(
        page: 3,
        status: 'dead',
        name: 'Morty',
      );

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=3&status=dead&name=Morty',
          ))).called(1);
    });

    test('should not include name parameter when name is empty string',
        () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(name: '');

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should not include name parameter when name is null', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(name: null);

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should not include status parameter when status is null', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(status: null);

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should handle URL encoding for special characters in name', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(name: 'Rick & Morty');

      // Assert
      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&name=Rick & Morty',
          ))).called(1);
    });

    test('should handle URL with multiple parameters correctly', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      // Act
      await dataSource.getCharacters(
        page: 5,
        status: 'unknown',
        name: 'Alien',
      );

      // Assert
      const expectedUrl =
          'https://rickandmortyapi.com/api/character?page=5&status=unknown&name=Alien';
      verify(() => mockHttpClient.get(Uri.parse(expectedUrl))).called(1);
    });
  });

  group('Error Handling', () {
    test('should throw Exception on network timeout', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenThrow(
        Exception('Network timeout'),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should throw Exception on socket exception', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenThrow(
        Exception('Socket exception'),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 400 Bad Request by throwing Exception', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Bad Request', 400),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 401 Unauthorized by throwing Exception', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Unauthorized', 401),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 403 Forbidden by throwing Exception', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Forbidden', 403),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 429 Too Many Requests by throwing Exception', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Too Many Requests', 429),
      );

      // Act
      final call = dataSource.getCharacters;

      // Assert
      expect(() => call(), throwsA(isA<Exception>()));
    });
  });

  group('Response Parsing', () {
    test('should correctly parse response with empty results', () async {
      // Arrange
      final emptyResponse = {
        "info": {"count": 0, "pages": 0, "next": null, "prev": null},
        "results": []
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(emptyResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.info.count, 0);
      expect(result.info.pages, 0);
      expect(result.results, isEmpty);
      expect(result.info.next, isNull);
      expect(result.info.prev, isNull);
    });

    test('should correctly parse response with pagination info', () async {
      // Arrange
      final paginatedResponse = {
        "info": {
          "count": 20,
          "pages": 2,
          "next": "https://rickandmortyapi.com/api/character?page=2",
          "prev": null
        },
        "results": [
          {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": {
              "name": "Earth (C-137)",
              "url": "https://rickandmortyapi.com/api/location/1"
            },
            "location": {
              "name": "Earth (Replacement Dimension)",
              "url": "https://rickandmortyapi.com/api/location/20"
            },
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "episode": ["https://rickandmortyapi.com/api/episode/1"],
            "url": "https://rickandmortyapi.com/api/character/1",
            "created": "2017-11-04T18:48:46.250Z"
          }
        ]
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(paginatedResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.info.count, 20);
      expect(result.info.pages, 2);
      expect(
          result.info.next, "https://rickandmortyapi.com/api/character?page=2");
      expect(result.info.prev, isNull);
      expect(result.results.length, 1);
    });

    test('should handle character with missing optional fields', () async {
      // Arrange
      final minimalCharacterResponse = {
        "info": {"count": 1, "pages": 1, "next": null, "prev": null},
        "results": [
          {
            "id": 1,
            "name": "Test Character",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": {"name": "Unknown", "url": ""},
            "location": {"name": "Unknown", "url": ""},
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "episode": [],
            "url": "https://rickandmortyapi.com/api/character/1",
            "created": "2017-11-04T18:48:46.250Z"
          }
        ]
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(minimalCharacterResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.results[0].name, "Test Character");
      expect(result.results[0].type, "");
      expect(result.results[0].episode, isEmpty);
    });
  });

  group('Performance and Edge Cases', () {
    test('should handle very long character names', () async {
      // Arrange
      final longNameResponse = {
        "info": {"count": 1, "pages": 1, "next": null, "prev": null},
        "results": [
          {
            "id": 1,
            "name": "A" * 100, // Very long name
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": {"name": "Earth", "url": ""},
            "location": {"name": "Earth", "url": ""},
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "episode": [],
            "url": "https://rickandmortyapi.com/api/character/1",
            "created": "2017-11-04T18:48:46.250Z"
          }
        ]
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(longNameResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.results[0].name, hasLength(100));
    });

    test('should handle large number of characters in response', () async {
      // Arrange
      final largeResponse = {
        "info": {"count": 100, "pages": 1, "next": null, "prev": null},
        "results": List.generate(
            100,
            (index) => {
                  "id": index + 1,
                  "name": "Character ${index + 1}",
                  "status": "Alive",
                  "species": "Human",
                  "type": "",
                  "gender": "Male",
                  "origin": {"name": "Earth", "url": ""},
                  "location": {"name": "Earth", "url": ""},
                  "image":
                      "https://rickandmortyapi.com/api/character/avatar/${index + 1}.jpeg",
                  "episode": [],
                  "url":
                      "https://rickandmortyapi.com/api/character/${index + 1}",
                  "created": "2017-11-04T18:48:46.250Z"
                })
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(largeResponse), 200),
      );

      // Act
      final result = await dataSource.getCharacters();

      // Assert
      expect(result.results.length, 100);
      expect(result.info.count, 100);
    });
  });
}
