import 'package:bloc/bloc.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/usecases/get_characters.dart';
import '../../../core/errors/failures.dart';
import 'character_list_event.dart';
import 'character_list_state.dart';

class CharacterListBloc extends Bloc<CharacterListEvent, CharacterListState> {
  final GetCharacters getCharacters;

  CharacterListBloc({required this.getCharacters})
      : super(const CharacterListState()) {
    on<FetchCharacters>(_onFetchCharacters);
    on<FilterCharacters>(_onFilterCharacters);
    on<SearchCharacters>(_onSearchCharacters);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchCharacters(
    FetchCharacters event,
    Emitter<CharacterListState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoading) {
      return;
    }

    if (event.page == 1) {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    final result = await getCharacters(status: event.status, name: event.name);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (newCharacters) {
        final allCharacters = event.page == 1
            ? newCharacters
            : [...state.characters, ...newCharacters];

        emit(state.copyWith(
          characters: allCharacters,
          isLoading: false,
          hasReachedMax: newCharacters.isEmpty,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onFilterCharacters(
    FilterCharacters event,
    Emitter<CharacterListState> emit,
  ) async {
    emit(const CharacterListState(
      characters: [],
      hasReachedMax: false,
    ));

    add(FetchCharacters(
      page: 1,
      status: event.status,
      name: state.searchQuery,
    ));
  }

  Future<void> _onSearchCharacters(
    SearchCharacters event,
    Emitter<CharacterListState> emit,
  ) async {
    if (event.name.isEmpty) {
      add(ClearSearch());
      return;
    }

    emit(CharacterListState(
      characters: const [],
      hasReachedMax: false,
      searchQuery: event.name,
    ));

    add(FetchCharacters(
      page: 1,
      name: event.name,
      status: _currentFilter,
    ));
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<CharacterListState> emit,
  ) async {
    emit(const CharacterListState(
      characters: [],
      hasReachedMax: false,
      searchQuery: null,
    ));

    add(const FetchCharacters(page: 1));
  }

  CharacterStatus? get _currentFilter {
    return null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro no servidor. Tente novamente.';
      case NetworkFailure:
        return 'Sem conexão com a internet.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
