import 'package:flutter/material.dart';
import 'dart:async'; // ← Adicionar este import

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String? initialValue;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.initialValue,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    // Debounce para evitar muitas requisições
    _controller.addListener(() {
      _onTextChanged(_controller.text);
    });
  }

  Timer? _debounceTimer;

  void _onTextChanged(String text) {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    // Iniciar novo timer (debounce de 500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(text);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClearSearch();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Buscar personagem...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
