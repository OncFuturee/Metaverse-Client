import 'package:get_it/get_it.dart';
import 'package:metaverse_client/core/services/cache/cache_service.dart';
import 'package:metaverse_client/core/services/cache/hive_cache_service.dart';
import 'data/datasources/video_remote_datasource.dart';
import 'data/repositories/video_repository_impl.dart';
import 'domain/repositories/video_repository.dart';
import 'package:metaverse_client/data/datasources/local_category_datasource.dart';
import 'package:metaverse_client/data/repositories/category_repository_impl.dart';
import 'package:metaverse_client/domain/repositories/category_repository.dart';
import 'package:metaverse_client/domain/usecases/get_categories.dart';
import 'package:metaverse_client/domain/usecases/save_categories.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<VideoRemoteDataSource>(() => VideoRemoteDataSource());
  getIt.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(getIt()));
  getIt.registerLazySingleton<CacheService>(() => HiveCacheService());

  // 数据源
  getIt.registerLazySingleton<LocalCategoryDatasource>(
    () => LocalCategoryDatasource(getIt()),
  );

  // 仓库
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDatasource: getIt(),
      storageKey: 'categories_data',
    ),
  );

  // 用例
  getIt.registerLazySingleton(() => GetCategories(getIt()));
  getIt.registerLazySingleton(() => SaveCategories(getIt()));
}
