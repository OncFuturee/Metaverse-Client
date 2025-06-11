import 'package:metaverse_client/data/models/category_item.dart';

// 分类项领域实体
class CategoryEntity {
  final String title;
  final bool isSelected;
  final bool isVisible;
  final String link;

  CategoryEntity({
    required this.title,
    required this.isSelected,
    required this.isVisible,
    required this.link,
  });

  // 从数据模型转换为领域实体
  factory CategoryEntity.fromDataModel(CategoryItem model) {
    return CategoryEntity(
      title: model.title,
      isSelected: model.isSelected,
      isVisible: model.isVisible,
      link: model.link,
    );
  }

  // 转换为数据模型
  CategoryItem toDataModel() {
    return CategoryItem(
      title: title,
      isSelected: isSelected,
      isVisible: isVisible,
      link: link,
    );
  }
}
