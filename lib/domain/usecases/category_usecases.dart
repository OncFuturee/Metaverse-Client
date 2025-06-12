import 'package:dartz/dartz.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:metaverse_client/domain/repositories/category_repository.dart';

// 获取分类列表用例
class CategoryUsecases {
  final CategoryRepository repository;

  CategoryUsecases(this.repository);

  Future<Either<Exception, List<CategoryEntity>>> getCategories() {
    return repository.getCategories();
  }

  Future<Either<Exception, void>> saveCategories(List<CategoryEntity> categories) {
    return repository.saveCategories(categories);
  }
}