import 'package:dartz/dartz.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';

// 分类仓库接口
abstract class CategoryRepository {
  // 获取分类列表
  Future<Either<Exception, List<CategoryEntity>>> getCategories();
  
  // 保存分类列表
  Future<Either<Exception, void>> saveCategories(List<CategoryEntity> categories);
  
  // 更新分类项
  Future<Either<Exception, void>> updateCategory(CategoryEntity category);
  
  // 删除分类项
  Future<Either<Exception, void>> deleteCategory(String title);
}
