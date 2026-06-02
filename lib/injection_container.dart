import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/verification_cubit.dart';
import 'features/bookings/presentation/cubit/booking_flow_cubit.dart';
import 'features/bookings/presentation/cubit/bookings_cubit.dart';
import 'features/home/data/datasources/categories_remote_datasource.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/datasources/search_remote_datasource.dart';
import 'features/home/data/repository/category_repo.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/home/data/repository/search_repository.dart';
import 'features/home/presentation/cubit/address_cubit.dart';
import 'features/home/presentation/cubit/category_cubit.dart';
import 'features/home/presentation/cubit/home_cubti.dart';
import 'features/home/presentation/cubit/search_cubit.dart';
import 'features/home/presentation/cubit/service_cubit.dart';
import 'features/wallet/presentation/cubit/cubit.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

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


// --- Home Module ---

// Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(sl<ApiClient>()),
  );

// Repositories
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

// Cubits
  sl.registerFactory<HomeCubit>(
        () => HomeCubit(sl<HomeRepository>()),
  );

  sl.registerLazySingleton<CategoriesRemoteDataSource>(
          () => CategoriesRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<CategoriesRepository>(
          () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>()));
  sl.registerFactory<CategoriesCubit>(
          () => CategoriesCubit(sl<CategoriesRepository>()));
  sl.registerFactory<CategoryServicesCubit>(
          () => CategoryServicesCubit(sl<CategoriesRepository>()));
  sl.registerFactory<SubcategoriesCubit>(
          () => SubcategoriesCubit(sl<CategoriesRepository>()));
  sl.registerFactory<ServiceDetailCubit>(
          () => ServiceDetailCubit(sl<ApiClient>()));
  sl.registerFactory<PopularServicesCubit>(
          () => PopularServicesCubit(sl<ApiClient>()));
  sl.registerFactory<BookingsCubit>(() => BookingsCubit(sl<ApiClient>()));
  sl.registerFactory<BookingDetailCubit>(
          () => BookingDetailCubit(sl<ApiClient>()));
  sl.registerFactory<BookingFlowCubit>(() => BookingFlowCubit(sl<ApiClient>()));
  sl.registerLazySingleton<AddressCubit>(() => AddressCubit(sl<ApiClient>()));
  sl.registerFactory<WalletCubit>(() => WalletCubit(sl<ApiClient>()));
  sl.registerFactory<CardsCubit>(() => CardsCubit(sl<ApiClient>()));
  sl.registerFactory<TopUpCubit>(() => TopUpCubit(sl<ApiClient>()));
  sl.registerFactory<VerificationCubit>(
          () => VerificationCubit(sl<ApiClient>()));
  sl.registerFactory<ProfileCubit>(
          () => ProfileCubit(sl<ApiClient>()));

}
