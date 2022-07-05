import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture_reso/core/network/network_info.dart';
import 'package:tdd_clean_architecture_reso/core/util/input_converter.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_concrete_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/domain/usecases/get_random_number_trivia_usecase.dart';
import 'package:tdd_clean_architecture_reso/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //! Features - Number Trivia
  //?Bloc
  sl.registerFactory(() => NumberTriviaBloc(
        getConcreteNumberTriviaUsecase: sl(),
        getRandomNumberTriviaUsecase: sl(),
        inputConverter: sl(),
      ));
  //?Usecases
  sl.registerLazySingleton(() => GetConcreteNumberTriviaUsecase(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTriviaUsecase(sl()));
  //?Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      numberTriviaRemoteDatasource: sl(),
      numberTriviaLocalDatasource: sl(),
      networkInfo: sl(),
    ),
  );
  //?Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDatasource>(
      () => NumberTriviaRemoteDatasourceImpl(sl())); //*httpClient
  sl.registerLazySingleton<NumberTriviaLocalDatasource>(
      () => NumberTriviaLocalDatasourceImpl(sl())); //*sharedPreferences
  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Client());
}
