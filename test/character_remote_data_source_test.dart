import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:multiverse_guide/data/datasources/character_remote_data_source.dart';
import 'package:multiverse_guide/data/models/character_model.dart';
import 'package:multiverse_guide/data/models/character_response_model.dart';

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
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      final result = await dataSource.getCharacters();

      expect(result.info.count, tCharacterResponseModel.info.count);
      expect(result.info.pages, tCharacterResponseModel.info.pages);
      expect(result.results.length, tCharacterResponseModel.results.length);
      expect(result.results[0].name, tCharacterResponseModel.results[0].name);
      expect(result.results[1].name, tCharacterResponseModel.results[1].name);
    });

    test('should return empty CharacterResponseModel when the response is 404',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tEmptyJsonResponse), 404),
      );

      final result = await dataSource.getCharacters();

      expect(result.info.count, 0);
      expect(result.info.pages, 0);
      expect(result.results, isEmpty);
      expect(result, tEmptyCharacterResponseModel);
    });

    test('should throw Exception when the response is not 200 or 404',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should throw Exception when the response has malformed JSON',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Invalid JSON', 200),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should call http client with correct base URL and default parameters',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters();

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should call http client with correct URL when page is specified',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(page: 2);

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=2',
          ))).called(1);
    });

    test('should call http client with correct URL when status is specified',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(status: 'alive');

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&status=alive',
          ))).called(1);
    });

    test('should call http client with correct URL when name is specified',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(name: 'Rick');

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&name=Rick',
          ))).called(1);
    });

    test(
        'should call http client with correct URL when all parameters are specified',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(
        page: 3,
        status: 'dead',
        name: 'Morty',
      );

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=3&status=dead&name=Morty',
          ))).called(1);
    });

    test('should not include name parameter when name is empty string',
        () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(name: '');

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should not include name parameter when name is null', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(name: null);

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should not include status parameter when status is null', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(status: null);

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1',
          ))).called(1);
    });

    test('should handle URL encoding for special characters in name', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(name: 'Rick & Morty');

      verify(() => mockHttpClient.get(Uri.parse(
            'https://rickandmortyapi.com/api/character?page=1&name=Rick & Morty',
          ))).called(1);
    });

    test('should handle URL with multiple parameters correctly', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(tJsonResponse), 200),
      );

      await dataSource.getCharacters(
        page: 5,
        status: 'unknown',
        name: 'Alien',
      );

      const expectedUrl =
          'https://rickandmortyapi.com/api/character?page=5&status=unknown&name=Alien';
      verify(() => mockHttpClient.get(Uri.parse(expectedUrl))).called(1);
    });
  });

  group('Error Handling', () {
    test('should throw Exception on network timeout', () async {
      when(() => mockHttpClient.get(any())).thenThrow(
        Exception('Network timeout'),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should throw Exception on socket exception', () async {
      when(() => mockHttpClient.get(any())).thenThrow(
        Exception('Socket exception'),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 400 Bad Request by throwing Exception', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Bad Request', 400),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 401 Unauthorized by throwing Exception', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Unauthorized', 401),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 403 Forbidden by throwing Exception', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Forbidden', 403),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });

    test('should handle 429 Too Many Requests by throwing Exception', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('Too Many Requests', 429),
      );

      final call = dataSource.getCharacters;

      expect(() => call(), throwsA(isA<Exception>()));
    });
  });

  group('Response Parsing', () {
    test('should correctly parse response with empty results', () async {
      final emptyResponse = {
        "info": {"count": 0, "pages": 0, "next": null, "prev": null},
        "results": []
      };

      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(emptyResponse), 200),
      );

      final result = await dataSource.getCharacters();

      expect(result.info.count, 0);
      expect(result.info.pages, 0);
      expect(result.results, isEmpty);
      expect(result.info.next, isNull);
      expect(result.info.prev, isNull);
    });

    test('should correctly parse response with pagination info', () async {
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

      final result = await dataSource.getCharacters();

      expect(result.info.count, 20);
      expect(result.info.pages, 2);
      expect(
          result.info.next, "https://rickandmortyapi.com/api/character?page=2");
      expect(result.info.prev, isNull);
      expect(result.results.length, 1);
    });

    test('should handle character with missing optional fields', () async {
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

      final result = await dataSource.getCharacters();

      expect(result.results[0].name, "Test Character");
      expect(result.results[0].type, "");
      expect(result.results[0].episode, isEmpty);
    });
  });

  group('Performance and Edge Cases', () {
    test('should handle very long character names', () async {
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

      final result = await dataSource.getCharacters();

      expect(result.results[0].name, hasLength(100));
    });

    test('should handle large number of characters in response', () async {
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

      final result = await dataSource.getCharacters();

      expect(result.results.length, 100);
      expect(result.info.count, 100);
    });
  });
}
