import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metaverse_client/data/models/category_item.dart';

// 本地分类数据源
class LocalCategoryDatasource {
  final SharedPreferences sharedPreferences;
  
  LocalCategoryDatasource(this.sharedPreferences);
  
  // 保存分类到本地存储
  // TODO: 使用core核心中的cache服务
  Future<void> saveCategories(List<CategoryItem> categories, String key) async {
    final jsonList = categories.map((cat) => cat.toMap()).toList();
    await sharedPreferences.setString(key, json.encode(jsonList));
  }
  
  // 从本地存储获取分类
  List<CategoryItem> getCategories(String key) {
    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) {
      return [
          CategoryItem(title: "科技", isSelected: true, isVisible: true, link: "/tech"),
          CategoryItem(title: "体育", isSelected: false, isVisible: true, link: "/sports"),
          CategoryItem(title: "娱乐", isSelected: false, isVisible: true, link: "/entertainment"),
          CategoryItem(title: "财经", isSelected: false, isVisible: false, link: "/finance"),
          CategoryItem(title: "健康", isSelected: false, isVisible: false, link: "/health"),
          CategoryItem(title: "教育", isSelected: false, isVisible: false, link: "/education"),
          CategoryItem(title: "我练功发自真心", isSelected: false, isVisible: false, link: "/education"),
          CategoryItem(title: "哇哈哈", isSelected: false, isVisible: false, link: "/education"),
        ];
    }
    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((json) => CategoryItem.fromMap(json)).toList();
    } catch (e) {
      print('Error parsing categories: $e');
      return [];
    }
  }
}
