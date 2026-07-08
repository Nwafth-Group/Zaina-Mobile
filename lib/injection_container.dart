import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/verification_cubit.dart';
import 'features/bookings/presentation/cubit/booking_flow_cubit.dart';
import 'features/bookings/presentation/cubit/bookings_cubit.dart';
import 'features/bookings/presentation/cubit/reschedule_shifts_cubit.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/home/presentation/cubit/address_cubit.dart';
import 'features/home/presentation/cubit/filter_cubit.dart';
import 'features/home/presentation/cubit/home_cubti.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/profile/presentation/cubit/cards_cubit.dart';
import 'features/profile/presentation/cubit/coupons_cubit.dart';
import 'features/profile/presentation/cubit/points_cubit.dart';
import 'features/profile/presentation/cubit/reports_cubit.dart';
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
  sl.registerFactory<BookingsCubit>(() => BookingsCubit(sl<ApiClient>()));
  sl.registerFactory<BookingDetailCubit>(
          () => BookingDetailCubit(sl<ApiClient>()));
  sl.registerFactory<BookingFlowCubit>(() => BookingFlowCubit(sl<ApiClient>()));
  sl.registerFactory<RescheduleShiftsCubit>(() => RescheduleShiftsCubit(sl<ApiClient>()));
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
  sl.registerFactory<CouponsCubit>(() => CouponsCubit(sl<ApiClient>()));

}
