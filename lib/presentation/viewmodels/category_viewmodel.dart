import 'package:flutter/material.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:metaverse_client/domain/usecases/category_usecases.dart';

// 分类视图模型
class CategoryViewModel extends ChangeNotifier {
  final CategoryUsecases categoryUsecases;
  final String storageKey;

  List<CategoryEntity> _categories = [];
  List<String> _visibleCategories = [];
  bool _isExpanded = false;

  CategoryViewModel({
    required this.categoryUsecases,
    required this.storageKey,
  }) {
    _init();
  }

  // 获取分类列表
  List<CategoryEntity> get categories => _categories;

  // 获取可见分类
  List<CategoryEntity> get visibleCategories => 
      _categories.where((cat) => _visibleCategories.contains(cat.title)).toList();

  // 获取不可见分类
  List<CategoryEntity> get hiddenCategories => 
      _categories.where((cat) => !_visibleCategories.contains(cat.title)).toList();

  // 获取选中的分类
  CategoryEntity? get selectedCategory {
    if (_categories.isEmpty) return null;
    return _categories.firstWhere((cat) => cat.isSelected, orElse: () => _categories[0]);
  }

  // 是否展开
  bool get isExpanded => _isExpanded;

  // 初始化
  Future<void> _init() async {
    final result = await categoryUsecases.getCategories();
    result.fold(
      (failure) {
        print('Failed to load categories: $failure');
        // 使用默认分类
        _categories = [
          CategoryEntity(title: "科技", isSelected: true, isVisible: true, link: "/tech"),
          CategoryEntity(title: "体育", isSelected: false, isVisible: true, link: "/sports"),
          CategoryEntity(title: "娱乐", isSelected: false, isVisible: true, link: "/entertainment"),
          CategoryEntity(title: "财经", isSelected: false, isVisible: false, link: "/finance"),
          CategoryEntity(title: "健康", isSelected: false, isVisible: false, link: "/health"),
          CategoryEntity(title: "教育", isSelected: false, isVisible: false, link: "/education"),
          CategoryEntity(title: "我练功发自真心", isSelected: false, isVisible: false, link: "/education"),
          CategoryEntity(title: "哇哈哈", isSelected: false, isVisible: false, link: "/education"),
        ];
        _visibleCategories = _categories.where((cat) => cat.isVisible).map((cat) => cat.title).toList();
        _saveCategories();
      },
      (categories) {
        _categories = categories;
        _visibleCategories = _categories.where((cat) => cat.isVisible).map((cat) => cat.title).toList();
      },
    );
    notifyListeners();
  }

  // 选择分类
  void selectCategory(CategoryEntity category) {
    _categories = _categories.map((cat) {
      if (cat.title == category.title) {
        return CategoryEntity(
          title: cat.title,
          isSelected: true,
          isVisible: cat.isVisible,
          link: cat.link,
        );
      } else {
        return CategoryEntity(
          title: cat.title,
          isSelected: false,
          isVisible: cat.isVisible,
          link: cat.link,
        );
      }
    }).toList();
    _saveCategories();
    _isExpanded = false;
    notifyListeners();
  }

  // 添加到可见列表
  void addToVisibleList(String title) {
    if (!_visibleCategories.contains(title)) {
      _visibleCategories.add(title);
      _updateCategoriesVisibility();
      _saveCategories();
      notifyListeners();
    }
  }

  // 从可见列表中移除
  void removeFromVisibleList(String title) {
    _visibleCategories.remove(title);
    _updateCategoriesVisibility();
    _saveCategories();
    notifyListeners();
  }

  // 更新分类可见性
  void _updateCategoriesVisibility() {
    _categories = _categories.map((cat) {
      return CategoryEntity(
        title: cat.title,
        isSelected: cat.isSelected,
        isVisible: _visibleCategories.contains(cat.title),
        link: cat.link,
      );
    }).toList();
  }

  // 保存分类
  Future<void> _saveCategories() async {
    await categoryUsecases.saveCategories(_categories);
  }

  // 切换展开/折叠状态
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  // 计算可见分类
  void calculateVisibleCategories(double availableWidth, double iconSize, double spacing) {
    // 测量展开按钮的宽度
    final iconWidth = iconSize + spacing * 2;
    
    // 计算可用空间
    double availableSpace = availableWidth;
    List<String> visibleTitles = [];
    
    // 为展开按钮预留空间
    availableSpace -= iconWidth;
    
    // 计算每个类别所需的宽度
    for (var category in _categories) {
      // 这里简化处理，实际应用中可能需要更精确的测量
      final titleWidth = category.title.length * 12.0 + spacing * 4 + iconSize;
      
      if (availableSpace >= titleWidth) {
        visibleTitles.add(category.title);
        availableSpace -= titleWidth;
      } else {
        break;
      }
    }
    
    if (visibleTitles.join(',') != _visibleCategories.join(',')) {
      _visibleCategories = visibleTitles;
      _updateCategoriesVisibility();
      _saveCategories();
      notifyListeners();
    }
  }
}
