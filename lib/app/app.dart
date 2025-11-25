import 'package:flutter/material.dart';

import '../presentation/pages/characters_list/characters_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia do Multiverso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.teal,
          elevation: 0,
        ),
      ),
      home: const CharactersListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
