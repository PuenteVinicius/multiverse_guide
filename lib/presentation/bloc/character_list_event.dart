import 'package:equatable/equatable.dart';

import '../../../domain/entities/character.dart';

abstract class CharacterListEvent extends Equatable {
  const CharacterListEvent();

  @override
  List<Object> get props => [];
}

class FetchCharacters extends CharacterListEvent {
  final int page;
  final CharacterStatus? status;
  final String? name;
  const FetchCharacters({this.page = 1, this.status, this.name});

  @override
  List<Object> get props => [page];
}

class FilterCharacters extends CharacterListEvent {
  final CharacterStatus? status;

  const FilterCharacters({this.status});

  @override
  List<Object> get props => [status ?? CharacterStatus.unknown];
}

class SearchCharacters extends CharacterListEvent {
  final String name;

  const SearchCharacters({required this.name});

  @override
  List<Object> get props => [name];
}

class ClearSearch extends CharacterListEvent {}
