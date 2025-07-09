import 'package:dartz/dartz.dart';
import 'package:metaverse_client/data/datasources/local_category_datasource.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:metaverse_client/domain/repositories/category_repository.dart';

// 分类仓库实现
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalCategoryDatasource localDatasource;
  final String storageKey;

  CategoryRepositoryImpl({
    required this.localDatasource,
    required this.storageKey,
  });

  @override
  Future<Either<Exception, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = localDatasource.getCategories(storageKey);
      final entities = categories.map((model) => CategoryEntity.fromDataModel(model)).toList();
      return Right(entities);
    } catch (e) {
      return Left(Exception('Failed to get categories: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> saveCategories(List<CategoryEntity> categories) async {
    try {
      final models = categories.map((entity) => entity.toDataModel()).toList();
      await localDatasource.saveCategories(models, storageKey);
      return Right(null);
    } catch (e) {
      return Left(Exception('Failed to save categories: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateCategory(CategoryEntity category) async {
    try {
      final categories = localDatasource.getCategories(storageKey);
      final index = categories.indexWhere((cat) => cat.title == category.title);
      
      if (index != -1) {
        categories[index] = category.toDataModel();
      } else {
        categories.add(category.toDataModel());
      }
      
      await localDatasource.saveCategories(categories, storageKey);
      return Right(null);
    } catch (e) {
      return Left(Exception('Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteCategory(String title) async {
    try {
      final categories = localDatasource.getCategories(storageKey);
      final filtered = categories.where((cat) => cat.title != title).toList();
      await localDatasource.saveCategories(filtered, storageKey);
      return Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete category: $e'));
    }
  }
}
