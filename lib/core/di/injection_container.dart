import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../http/dio_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(() => createDioClient());
}
