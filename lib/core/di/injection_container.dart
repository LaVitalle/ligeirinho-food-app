import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/cart/bloc/cart_cubit.dart';
import '../http/dio_client.dart';
import '../services/crash_reporting_service.dart';
import '../services/notification_service.dart';
import '../services/realtime_service.dart';
import '../storage/session_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/location/bloc/location_cubit.dart';
import '../../features/location/data/datasources/location_remote_data_source.dart';
import '../../features/location/data/repositories/location_repository.dart';
import '../../features/orders/bloc/orders_cubit.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository.dart';
import '../../features/stores/bloc/stores_cubit.dart';
import '../../features/stores/data/datasources/institutions_remote_data_source.dart';
import '../../features/stores/data/repositories/institutions_repository.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- External ---
  sl.registerLazySingleton<Dio>(() => createDioClient());
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage());
  sl.registerLazySingleton<RealtimeService>(() => RealtimeService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<CrashReportingService>(() => CrashReportingService());

  // --- Core ---

  // --- Data sources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<InstitutionsRemoteDataSource>(
    () => InstitutionsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(dio: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sessionStorage: sl(),
    ),
  );
  sl.registerLazySingleton<InstitutionsRepository>(
    () => InstitutionsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Use cases ---

  // --- Blocs / Cubits ---
  sl.registerFactory(() => AuthBloc(repository: sl()));
  sl.registerFactory(() => StoresCubit(repository: sl()));
  sl.registerFactory(() => LocationCubit(repository: sl()));
  sl.registerFactory(() => OrdersCubit(repository: sl()));
  sl.registerFactory(() => CartCubit());
}
