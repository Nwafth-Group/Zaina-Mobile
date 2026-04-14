import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/data/datasources/search_remote_datasource.dart';
import 'features/home/data/search_repository/search_repository.dart';
import 'features/home/presentation/cubit/search_cubit.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient.instance);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Cubits
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SearchRemoteDataSource>(
          () => SearchRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<SearchRepository>(
          () => SearchRepositoryImpl(sl<SearchRemoteDataSource>()));
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));

}
