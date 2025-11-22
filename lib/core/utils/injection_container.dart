import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../domain/repositories/character_repository.dart';
import '../../domain/usecases/get_characters.dart';

import '../../data/datasources/character_remote_data_source.dart';
import '../../data/repositories/character_repository_impl.dart';

import '../../presentation/bloc/character_list_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerFactory(
    () => CharacterListBloc(getCharacters: getIt()),
  );

  getIt.registerLazySingleton(() => GetCharacters(getIt()));

  getIt.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton(() => http.Client());
}
