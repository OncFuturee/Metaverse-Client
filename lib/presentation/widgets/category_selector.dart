import 'package:flutter/material.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:provider/provider.dart';
import 'package:metaverse_client/presentation/viewmodels/category_viewmodel.dart';

// 分类选择器组件
class CategorySelector extends StatelessWidget {
  final double borderRadius;
  final double iconSize;
  final double spacing;
  final Color selectedColor;
  final Color unselectedColor;
  final Color deleteIconColor;
  final String storageKey;

  const CategorySelector({
    Key? key,
    this.borderRadius = 16.0,
    this.iconSize = 24.0,
    this.spacing = 8.0,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.deleteIconColor = Colors.red,
    required this.storageKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主容器
            Container(
              key: GlobalKey(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    viewModel.calculateVisibleCategories(
                      constraints.maxWidth,
                      iconSize,
                      spacing,
                    );
                  });
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 可见的类别标签
                        ...viewModel.visibleCategories.map((cat) => _buildCategoryTag(
                          context,
                          cat,
                          viewModel,
                        )).toList(),
                        
                        // 展开按钮
                        if (viewModel.hiddenCategories.isNotEmpty)
                          GestureDetector(
                            onTap: viewModel.toggleExpanded,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: spacing),
                              padding: EdgeInsets.all(spacing),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(borderRadius),
                              ),
                              child: Icon(
                                viewModel.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: iconSize,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // 展开的面板
            if (viewModel.isExpanded)
              Container(
                margin: EdgeInsets.only(top: spacing),
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    ...viewModel.categories.map((cat) {
                      final isVisible = viewModel.visibleCategories.any((vc) => vc.title == cat.title);
                      
                      return GestureDetector(
                        onTap: () {
                          if (isVisible) {
                            viewModel.selectCategory(cat);
                          } else {
                            viewModel.addToVisibleList(cat.title);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing * 2,
                            vertical: spacing,
                          ),
                          decoration: BoxDecoration(
                            color: isVisible 
                                ? (cat.isSelected ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1))
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.title,
                                style: TextStyle(
                                  color: isVisible 
                                      ? (cat.isSelected ? selectedColor : unselectedColor)
                                      : unselectedColor,
                                ),
                              ),
                              if (isVisible)
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: iconSize * 0.7,
                                    color: deleteIconColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () => viewModel.removeFromVisibleList(cat.title),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // 构建类别标签
  Widget _buildCategoryTag(BuildContext context, CategoryEntity category, CategoryViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.selectCategory(category),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing),
        padding: EdgeInsets.symmetric(
          horizontal: spacing * 2,
          vertical: spacing,
        ),
        decoration: BoxDecoration(
          color: category.isSelected 
              ? selectedColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            Text(
              category.title,
              style: TextStyle(
                color: category.isSelected 
                    ? selectedColor
                    : unselectedColor,
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => viewModel.removeFromVisibleList(category.title),
                child: Container(
                  width: iconSize * 0.8,
                  height: iconSize * 0.8,
                  decoration: BoxDecoration(
                    color: deleteIconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: iconSize * 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
