import 'package:dartz/dartz.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:metaverse_client/domain/repositories/category_repository.dart';

// 保存分类列表用例
class SaveCategories {
  final CategoryRepository repository;

  SaveCategories(this.repository);

  Future<Either<Exception, void>> execute(List<CategoryEntity> categories) {
    return repository.saveCategories(categories);
  }
}
