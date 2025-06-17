import 'package:flutter/material.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:provider/provider.dart';
import 'package:metaverse_client/presentation/viewmodels/category_viewmodel.dart';

// 分类选择器组件
class CategorySelector extends StatefulWidget {
  final double borderRadius; // 圆角半径
  final double iconSize; // 图标大小
  final double spacing; // 标签间距
  final Color selectedColor; // 选中颜色
  final Color unselectedColor; // 未选中颜色
  final Color deleteIconColor; // 删除图标颜色
  final String storageKey; // 存储键，用于持久化类别状态

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
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  GlobalKey _headerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  double _headerHeight = 0;
  double _headerTop = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getHeaderPosition();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // 获取头部组件位置信息
  void _getHeaderPosition() {
    final RenderBox renderBox = _headerKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    
    setState(() {
      _headerHeight = size.height;
      _headerTop = position.dy;
    });
  }

  // 显示悬浮面板
  void _showOverlay(BuildContext context, CategoryViewModel viewModel) {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            viewModel.toggleExpanded();
            _removeOverlay();
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                // 悬浮面板
                Positioned(
                  left: 0,
                  top: _headerTop + _headerHeight + 4,
                  width: MediaQuery.of(context).size.width,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Container(
                      padding: EdgeInsets.all(widget.spacing),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                      ),
                      child: Wrap(
                        spacing: widget.spacing,
                        runSpacing: widget.spacing,
                        children: [
                          ...viewModel.categories.map((cat) {
                            final isVisible = viewModel.visibleCategories.any((vc) => vc.title == cat.title);
                            
                            return GestureDetector(
                              onTap: () {
                                if (isVisible) {
                                  viewModel.selectCategory(cat);
                                  _removeOverlay();
                                } else {
                                  viewModel.addToVisibleList(cat.title);
                                  setState(()=>{}); // 立即刷新面板，显示删除按钮
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: widget.spacing * 2,
                                  vertical: widget.spacing,
                                ),
                                decoration: BoxDecoration(
                                  color: isVisible 
                                      ? (cat.isSelected ? widget.selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1))
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(widget.borderRadius),
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    Text(
                                      cat.title,
                                      style: TextStyle(
                                        color: isVisible 
                                            ? (cat.isSelected ? widget.selectedColor : widget.unselectedColor)
                                            : widget.unselectedColor,
                                      ),
                                    ),
                                    // 只在可见类别上显示删除按钮
                                    if (isVisible)
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: (() {
                                            viewModel.removeFromVisibleList(cat.title);
                                            setState(() {}); // 立即刷新面板，移除icon
                                          }),
                                          child: Container(
                                            width: widget.iconSize * 0.8,
                                            height: widget.iconSize * 0.8,
                                            decoration: BoxDecoration(
                                              color: widget.deleteIconColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: widget.iconSize * 0.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // 新增：在不可见类别被添加后，立即刷新面板以显示删除icon
                                    if (!isVisible)
                                      Positioned.fill(
                                        child: GestureDetector(
                                          onTap: () {
                                            viewModel.addToVisibleList(cat.title);
                                            setState(() {}); // 立即刷新面板，显示icon
                                          },
                                          behavior: HitTestBehavior.translucent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 移除悬浮面板
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, _) {
        // 监听展开状态变化，控制悬浮面板
        if (viewModel.isExpanded && _overlayEntry == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _getHeaderPosition();
            _showOverlay(context, viewModel);
          });
        } else if (!viewModel.isExpanded && _overlayEntry != null) {
          _removeOverlay();
        }
        
        return Container(
          key: _headerKey,
          width: double.infinity, // 确保容器宽度为父容器的宽度
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 水平滚动的标题导航栏 - 改进的滚动实现
              Container(
                constraints: BoxConstraints(
                  minHeight: 40, // 设置最小高度，允许内容撑开
                ),
                child: Row(
                  children: [
                    // 可滚动的标签区域
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Row(
                          children: [
                            // 可见的类别标签
                            ...viewModel.visibleCategories.map((cat) => _buildCategoryTag(
                              context,
                              cat,
                              viewModel,
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                    // 固定在最右侧的展开按钮
                    if (viewModel.hiddenCategories.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          viewModel.toggleExpanded();
                          _getHeaderPosition();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: widget.spacing),
                          padding: EdgeInsets.all(widget.spacing),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                          ),
                          child: Icon(
                            viewModel.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: widget.iconSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 不占用布局空间的占位符
              if (viewModel.isExpanded)
                Container(height: 0),
            ],
          ),
        );
      },
    );
  }

  // 构建类别标签
  Widget _buildCategoryTag(BuildContext context, CategoryEntity category, CategoryViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.selectCategory(category),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: widget.spacing),
        padding: EdgeInsets.symmetric(
          horizontal: widget.spacing * 2,
          vertical: widget.spacing,
        ),
        decoration: BoxDecoration(
          color: category.isSelected 
              ? widget.selectedColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Text(
          category.title,
          style: TextStyle(
            color: category.isSelected 
                ? widget.selectedColor
                : widget.unselectedColor,
          ),
        ),
      ),
    );
  }
}