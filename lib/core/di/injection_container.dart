import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../http/dio_client.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // --- External ---
  sl.registerLazySingleton<Dio>(() => createDioClient());

  // --- Core ---

  // --- Data sources ---

  // --- Repositories ---

  // --- Use cases ---

  // --- Blocs / Cubits ---
}
