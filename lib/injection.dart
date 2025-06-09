import 'package:get_it/get_it.dart';
import 'data/datasources/video_remote_datasource.dart';
import 'data/repositories/video_repository_impl.dart';
import 'domain/repositories/video_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<VideoRemoteDataSource>(() => VideoRemoteDataSource());
  getIt.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(getIt()));
}
