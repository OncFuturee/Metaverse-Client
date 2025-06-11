import 'dart:convert';

// 分类标题数据模型
class CategoryItem {
  String title;       // 标题名称
  bool isSelected;    // 是否选中
  bool isVisible;     // 是否显示在主面板
  String link;        // 请求链接

  CategoryItem({
    required this.title,
    required this.isSelected,
    required this.isVisible,
    required this.link,
  });

  // 转换为Map，用于持久化
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isSelected': isSelected,
      'isVisible': isVisible,
      'link': link,
    };
  }

  // 从Map创建对象
  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      title: map['title'] ?? '',
      isSelected: map['isSelected'] ?? false,
      isVisible: map['isVisible'] ?? false,
      link: map['link'] ?? '',
    );
  }

  // 转换为JSON字符串
  String toJson() => json.encode(toMap());

  // 从JSON字符串创建对象
  factory CategoryItem.fromJson(String source) => CategoryItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CategoryItem(title: $title, isSelected: $isSelected, isVisible: $isVisible, link: $link)';
  }
}
