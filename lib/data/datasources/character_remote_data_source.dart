import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character_response_model.dart';

abstract class CharacterRemoteDataSource {
  Future<CharacterResponseModel> getCharacters({
    int page = 1,
    String? status,
    String? name, // ← Adicionar parâmetro de busca
  });
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  final http.Client client;

  CharacterRemoteDataSourceImpl({required this.client});

  @override
  Future<CharacterResponseModel> getCharacters({
    int page = 1,
    String? status,
    String? name, // ← Adicionar parâmetro de busca
  }) async {
    final queryParams = <String>['page=$page'];

    if (status != null) {
      queryParams.add('status=$status');
    }

    if (name != null && name.isNotEmpty) {
      queryParams.add('name=$name');
    }

    final url =
        'https://rickandmortyapi.com/api/character?${queryParams.join('&')}';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return CharacterResponseModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // A API retorna 404 quando não encontra resultados
      return const CharacterResponseModel(
        info: InfoModel(count: 0, pages: 0, next: null, prev: null),
        results: [],
      );
    } else {
      throw Exception();
    }
  }
}
