import 'package:equatable/equatable.dart';

import '../../../domain/entities/character.dart';

class CharacterListState extends Equatable {
  final List<Character> characters;
  final bool hasReachedMax;
  final bool isLoading;
  final String? errorMessage;
  final String? searchQuery; // ← Adicionar query de busca

  const CharacterListState({
    this.characters = const [],
    this.hasReachedMax = false,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery, // ← Adicionar query de busca
  });

  CharacterListState copyWith({
    List<Character>? characters,
    bool? hasReachedMax,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery, // ← Adicionar query de busca
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery:
          searchQuery ?? this.searchQuery, // ← Adicionar query de busca
    );
  }

  @override
  List<Object?> get props => [
        characters,
        hasReachedMax,
        isLoading,
        errorMessage,
        searchQuery, // ← Adicionar query de busca
      ];
}
