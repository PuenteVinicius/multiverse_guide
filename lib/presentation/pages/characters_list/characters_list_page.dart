import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_bloc.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_event.dart';
import 'package:multiverse_guide/presentation/bloc/character_list_state.dart';

import '../../../core/utils/injection_container.dart';
import '../character_detail/character_detail_page.dart';
import '../../widgets/character_card.dart';
import '../../widgets/status_filter_chip.dart';
import '../../widgets/search_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../domain/entities/character.dart';

class CharactersListPage extends StatelessWidget {
  const CharactersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CharacterListBloc>(),
      child: const CharactersListView(),
    );
  }
}

class CharactersListView extends StatefulWidget {
  const CharactersListView({super.key});

  @override
  State<CharactersListView> createState() => _CharactersListViewState();
}

class _CharactersListViewState extends State<CharactersListView> {
  final ScrollController _scrollController = ScrollController();
  CharacterStatus? _currentFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CharacterListBloc>().add(const FetchCharacters(page: 1));
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<CharacterListBloc>().state;
      context.read<CharacterListBloc>().add(FetchCharacters(
            page: _currentPage + 1,
            status: _currentFilter,
            name: state.searchQuery,
          ));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  int get _currentPage {
    final state = context.read<CharacterListBloc>().state;
    return (state.characters.length ~/ 20) + 1;
  }

  void _onFilterSelected(CharacterStatus? status) {
    setState(() {
      _currentFilter = status;
    });
    context.read<CharacterListBloc>().add(FilterCharacters(status: status));
  }

  void _onSearchChanged(String query) {
    context
        .read<CharacterListBloc>()
        .add(SearchCharacters(name: query, status: _currentFilter));
  }

  void _onClearSearch() {
    context.read<CharacterListBloc>().add(ClearSearch());
    setState(() {
      _currentFilter = null;
    });
  }

  void _onCharacterTap(Character character) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CharacterDetailPage(character: character);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onRetry() {
    final state = context.read<CharacterListBloc>().state;
    context.read<CharacterListBloc>().add(FetchCharacters(
          page: 1,
          status: _currentFilter,
          name: state.searchQuery,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 32, bottom: 0),
            child: Title(
                color: Theme.of(context).primaryColor,
                child: const Text(
                  'Guia do Multiverso',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.tealAccent,
                  ),
                )),
          ),
          SearchBarWidget(
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
          ),
          _buildStatusFilter(),
          Expanded(
            child: BlocBuilder<CharacterListBloc, CharacterListState>(
              builder: (context, state) {
                if (state.isLoading && state.characters.isEmpty) {
                  return const LoadingWidget(
                      message: 'Carregando personagens...');
                }

                if (state.errorMessage != null && state.characters.isEmpty) {
                  return ErrorMessageWidget(
                    message: state.errorMessage!,
                    onRetry: _onRetry,
                  );
                }

                if (state.characters.isEmpty && state.searchQuery != null) {
                  return _buildEmptySearchState(state.searchQuery!);
                }

                return _buildCharacterList(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum personagem encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para: "$query"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onClearSearch,
            child: const Text('Limpar Busca'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return BlocBuilder<CharacterListBloc, CharacterListState>(
      builder: (context, state) {
        return SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 14,
                  width: 10,
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      StatusFilterChip(
                        label: 'Todos',
                        status: null,
                        isSelected: _currentFilter == null,
                        onSelected: () => _onFilterSelected(null),
                      ),
                      const SizedBox(width: 10),
                      StatusFilterChip(
                        label: 'Vivo',
                        status: CharacterStatus.alive,
                        isSelected: _currentFilter == CharacterStatus.alive,
                        onSelected: () =>
                            _onFilterSelected(CharacterStatus.alive),
                      ),
                      const SizedBox(width: 10),
                      StatusFilterChip(
                        label: 'Morto',
                        status: CharacterStatus.dead,
                        isSelected: _currentFilter == CharacterStatus.dead,
                        onSelected: () =>
                            _onFilterSelected(CharacterStatus.dead),
                      ),
                      const SizedBox(width: 10),
                      StatusFilterChip(
                        label: 'Desconhecido',
                        status: CharacterStatus.unknown,
                        isSelected: _currentFilter == CharacterStatus.unknown,
                        onSelected: () =>
                            _onFilterSelected(CharacterStatus.unknown),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterList(CharacterListState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CharacterListBloc>().add(FetchCharacters(
              page: 1,
              status: _currentFilter,
              name: state.searchQuery,
            ));
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.characters.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.characters.length) {
            return state.hasReachedMax
                ? const SizedBox.shrink()
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
          }

          final character = state.characters[index];
          return CharacterCard(
            character: character,
            onTap: () => _onCharacterTap(character),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
