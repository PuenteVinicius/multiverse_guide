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
    on<SearchCharacters>(_onSearchCharacters); // ← Novo handler
    on<ClearSearch>(_onClearSearch); // ← Novo handler
  }

  Future<void> _onFetchCharacters(
    FetchCharacters event,
    Emitter<CharacterListState> emit,
  ) async {
    // Evitar buscar se já chegou no máximo ou está carregando
    if (state.hasReachedMax || state.isLoading) {
      return;
    }

    // Primeira página - mostrar loading
    if (event.page == 1) {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));
    } else {
      // Paginação - manter dados atuais
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
    // Resetar estado e buscar primeira página com filtro
    emit(const CharacterListState(
      characters: [],
      hasReachedMax: false,
      isLoading: true,
    ));

    add(FetchCharacters(
      page: 1,
      status: event.status,
      name: state.searchQuery, // ← Manter a busca atual se houver
    ));
  }

  // ← NOVO HANDLER: Buscar por nome
  Future<void> _onSearchCharacters(
    SearchCharacters event,
    Emitter<CharacterListState> emit,
  ) async {
    // Se a busca estiver vazia, tratar como limpeza
    if (event.name.isEmpty) {
      add(ClearSearch());
      return;
    }

    // Resetar estado e buscar com o novo termo
    emit(CharacterListState(
      characters: const [],
      hasReachedMax: false,
      isLoading: true,
      searchQuery: event.name, // ← Salvar query de busca
    ));

    add(FetchCharacters(
      page: 1,
      name: event.name,
      status: _currentFilter, // ← Manter filtro atual se houver
    ));
  }

  // ← NOVO HANDLER: Limpar busca
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<CharacterListState> emit,
  ) async {
    // Resetar para estado inicial sem busca
    emit(const CharacterListState(
      characters: [],
      hasReachedMax: false,
      isLoading: true,
      searchQuery: null, // ← Limpar query de busca
    ));

    add(const FetchCharacters(page: 1));
  }

  // Helper para obter filtro atual do estado
  CharacterStatus? get _currentFilter {
    // Podemos extrair isso do estado se necessário
    // Por enquanto, vamos manter simples
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
