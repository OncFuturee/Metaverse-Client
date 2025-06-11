import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metaverse_client/data/models/category_item.dart';

// 本地分类数据源
class LocalCategoryDatasource {
  final SharedPreferences sharedPreferences;
  
  LocalCategoryDatasource(this.sharedPreferences);
  
  // 保存分类到本地存储
  Future<void> saveCategories(List<CategoryItem> categories, String key) async {
    final jsonList = categories.map((cat) => cat.toMap()).toList();
    await sharedPreferences.setString(key, json.encode(jsonList));
  }
  
  // 从本地存储获取分类
  List<CategoryItem> getCategories(String key) {
    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return [];
    
    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((json) => CategoryItem.fromMap(json)).toList();
    } catch (e) {
      print('Error parsing categories: $e');
      return [];
    }
  }
}
