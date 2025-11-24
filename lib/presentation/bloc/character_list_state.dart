import 'package:equatable/equatable.dart';

import '../../../domain/entities/character.dart';

class CharacterListState extends Equatable {
  final List<Character> characters;
  final bool hasReachedMax;
  final bool isLoading;
  final String? errorMessage;
  final String? searchQuery;

  const CharacterListState({
    this.characters = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery,
  });

  CharacterListState copyWith({
    List<Character>? characters,
    bool? hasReachedMax,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        characters,
        hasReachedMax,
        isLoading,
        errorMessage,
        searchQuery,
      ];
}
