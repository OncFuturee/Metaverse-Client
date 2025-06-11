import 'package:dartz/dartz.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:metaverse_client/domain/repositories/category_repository.dart';

// 获取分类列表用例
class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<Either<Exception, List<CategoryEntity>>> execute() {
    return repository.getCategories();
  }
}
