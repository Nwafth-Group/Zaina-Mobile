import 'package:get_it/get_it.dart';
import 'package:zeina/features/contract/presentation/cubit/contract_cubit.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/verification_cubit.dart';
import 'features/bookings/presentation/cubit/bookings_cubit.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/home/presentation/cubit/address_cubit.dart';
import 'features/home/presentation/cubit/filter_cubit.dart';
import 'features/home/presentation/cubit/home_cubti.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/notifications/presentation/cubit/unread_count_cubit.dart';
import 'features/profile/presentation/cubit/cards_cubit.dart';
import 'features/profile/presentation/cubit/coupons_cubit.dart';
import 'features/profile/presentation/cubit/points_cubit.dart';
import 'features/profile/presentation/cubit/reports_cubit.dart';
import 'features/services/data/datasources/services_datasource.dart';
import 'features/services/data/repository/services_repository.dart';
import 'features/services/presentation/cubit/service_detail_cubit.dart';
import 'features/services/presentation/cubit/services_cubit.dart';
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
  sl.registerFactory<NotificationsCubit>(
          () => NotificationsCubit(sl<ApiClient>()));
  sl.registerFactory<UnreadCountCubit>(
          () => UnreadCountCubit(sl<ApiClient>()));
  sl.registerFactory<BookingsCubit>(() => BookingsCubit(sl<ApiClient>()));
  sl.registerFactory<BookingDetailCubit>(
          () => BookingDetailCubit(sl<ApiClient>(), sl<ServicesRepository>()));
  sl.registerFactory<AddressCubit>(() => AddressCubit(sl<ApiClient>()));
  sl.registerFactory<WalletCubit>(() => WalletCubit(sl<ApiClient>()));
  sl.registerFactory<CardsCubit>(() => CardsCubit(sl<ApiClient>()));
  sl.registerFactory<TopUpCubit>(() => TopUpCubit(sl<ApiClient>()));
  sl.registerFactory<VerificationCubit>(
          () => VerificationCubit(sl<ApiClient>()));
  sl.registerFactory<ProfileCubit>(
          () => ProfileCubit(sl<ApiClient>()));
  sl.registerFactory<FilterCubit>(() => FilterCubit(sl<ApiClient>()));
  sl.registerFactory<PointsCubit>(() => PointsCubit(sl<ApiClient>()));
  sl.registerFactory<EarnPointsCubit>(() => EarnPointsCubit(sl<ApiClient>()));
  sl.registerFactory<ReportsCubit>(() => ReportsCubit(sl<ApiClient>()));
  sl.registerFactory<ReportDetailCubit>(() => ReportDetailCubit(sl<ApiClient>()));
  sl.registerFactory<CouponsCubit>(() => CouponsCubit(sl<ApiClient>()));
  sl.registerFactory<ContractCubit>(() => ContractCubit(sl<ApiClient>()));

// --- Services Module ---

// Data Sources
  sl.registerLazySingleton<ServicesRemoteDataSource>(
        () => ServicesRemoteDataSourceImpl(sl<ApiClient>()),
  );

// Repositories
  sl.registerLazySingleton<ServicesRepository>(
        () => ServicesRepositoryImpl(sl<ServicesRemoteDataSource>()),
  );

// Cubits
  sl.registerFactory<ServicesCubit>(() => ServicesCubit(sl<ServicesRepository>()));
  sl.registerFactory<VisitTypesCubit>(() => VisitTypesCubit(sl<ServicesRepository>()));
  sl.registerFactory<ServiceDetailCubit>(() => ServiceDetailCubit(sl<ServicesRepository>()));
}