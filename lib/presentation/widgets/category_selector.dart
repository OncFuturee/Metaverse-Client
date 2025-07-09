import 'package:flutter/material.dart';
import 'package:metaverse_client/domain/entities/category_entity.dart';
import 'package:provider/provider.dart';
import 'package:metaverse_client/presentation/viewmodels/category_viewmodel.dart';

// 分类选择器组件
class CategorySelector extends StatefulWidget {
  /// 圆角半径
  final double borderRadius;

  /// 删除图标大小
  final double deleteIconSize;

  /// 拓展图标大小
  final double expandIconSize;

  /// 标签间距
  final double spacing;

  /// 选中颜色
  final Color selectedColor;

  /// 未选中颜色
  final Color unselectedColor;

  /// 删除图标颜色
  final Color deleteIconColor;

  /// 存储键，用于持久化类别状态
  final String storageKey;

  const CategorySelector({
    Key? key,
    this.borderRadius = 16.0,
    this.deleteIconSize = 20.0,
    this.expandIconSize = 20.0,
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

  // 用于获取每个标签的Key，以便计算指示器位置
  final Map<String, GlobalKey> _tagKeys = {};
  // 新增：用于获取每个标签文本的Key
  final Map<String, GlobalKey> _tagTextKeys = {};
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getHeaderPosition();
      _updateIndicatorPosition(
          Provider.of<CategoryViewModel>(context, listen: false));
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // 获取头部组件位置信息
  void _getHeaderPosition() {
    final RenderBox renderBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _headerHeight = size.height;
      _headerTop = position.dy;
    });
  }

  // 更新指示器位置和宽度
  void _updateIndicatorPosition(CategoryViewModel viewModel) {
    final selectedCategory = viewModel.visibleCategories.firstWhereOrNull(
      (cat) => cat.isSelected,
    );

    if (selectedCategory != null &&
        _tagKeys[selectedCategory.title]?.currentContext != null) {
      final tagContext = _tagKeys[selectedCategory.title]!.currentContext!;
      final RenderBox tagRenderBox = tagContext.findRenderObject() as RenderBox;
      final tagPosition = tagRenderBox.localToGlobal(Offset.zero);

      // 获取SingleChildScrollView的全局位置
      final RenderBox? scrollBox = context.findRenderObject() as RenderBox?;
      if (scrollBox == null) return;
      final scrollPosition = scrollBox.localToGlobal(Offset.zero);

      // 通过Text的GlobalKey获取文本宽度
      double textWidth = 0;
      final textKey = _tagTextKeys[selectedCategory.title];
      if (textKey != null && textKey.currentContext != null) {
        final RenderBox? textRenderBox = textKey.currentContext!.findRenderObject() as RenderBox?;
        if (textRenderBox != null) {
          textWidth = textRenderBox.size.width * 1.2; // 增加一些额外的宽度
        }
      }
      // 如果找不到文本宽度，则退回整个标签宽度
      if (textWidth == 0) {
        textWidth = tagRenderBox.size.width;
      }

      setState(() {
        _indicatorLeft = tagPosition.dx - scrollPosition.dx +
            (tagRenderBox.size.width - textWidth) / 2;
        _indicatorWidth = textWidth;
      });
    } else {
      setState(() {
        _indicatorLeft = 0;
        _indicatorWidth = 0;
      });
    }
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
                            final isVisible = viewModel.visibleCategories
                                .any((vc) => vc.title == cat.title);
                            final isSelected = cat.isSelected;

                            return GestureDetector(
                              onTap: () {
                                if (!isVisible) {
                                  viewModel.addToVisibleList(cat.title);
                                  _overlayEntry?.markNeedsBuild();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isVisible
                                      ? (isSelected
                                          ? widget.selectedColor
                                              .withOpacity(0.15)
                                          : Colors.white)
                                      : Colors.grey.withOpacity(0.08),
                                  border: Border.all(
                                    color: isVisible
                                        ? (isSelected
                                            ? widget.selectedColor
                                            : widget.unselectedColor)
                                        : Colors.grey.withOpacity(0.4),
                                    width: 1.2,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(widget.borderRadius),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 标签文本
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: widget.deleteIconSize * 0.4,
                                        horizontal: widget.deleteIconSize * 0.8,
                                      ),
                                      child: Text(
                                        cat.title,
                                        style: TextStyle(
                                          color: isVisible
                                              ? (isSelected
                                                  ? widget.selectedColor
                                                  : widget.unselectedColor)
                                              : widget.unselectedColor
                                                  .withOpacity(0.7),
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    // 删除按钮（仅可见标签显示）
                                    if (isVisible)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            viewModel
                                                .removeFromVisibleList(cat.title);
                                            _overlayEntry?.markNeedsBuild();
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child: Container(
                                            width: widget.deleteIconSize,
                                            height: widget.deleteIconSize,
                                            decoration: BoxDecoration(
                                              color: widget.deleteIconColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.close,
                                              size: widget.deleteIconSize * 0.7,
                                              color: Colors.white,
                                            ),
                                          ),
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

        // 确保_tagKeys为所有可见类别创建了GlobalKey
        for (var cat in viewModel.visibleCategories) {
          _tagKeys.putIfAbsent(cat.title, () => GlobalKey());
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
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                // 可见的类别标签
                                ...viewModel.visibleCategories.map((cat) =>
                                    _buildCategoryTag(
                                      context,
                                      cat,
                                      viewModel,
                                    )),
                              ],
                            ),
                            // 指示器滑块
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: _indicatorLeft,
                              bottom: 0, // 放置在标签下方
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: 3, // 指示器高度
                                width: _indicatorWidth,
                                decoration: BoxDecoration(
                                  color: widget.selectedColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            ),
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
                          padding: EdgeInsets.all(widget.spacing),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                          ),
                          child: Icon(
                            viewModel.isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: widget.expandIconSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 不占用布局空间的占位符
              if (viewModel.isExpanded) Container(height: 0),
            ],
          ),
        );
      },
    );
  }

  // 构建类别标签
  Widget _buildCategoryTag(
      BuildContext context, CategoryEntity category, CategoryViewModel viewModel) {
    // 获取对应的GlobalKey，如果不存在则创建一个
    _tagKeys.putIfAbsent(category.title, () => GlobalKey());
    // 新增：为文本分配GlobalKey
    _tagTextKeys.putIfAbsent(category.title, () => GlobalKey());

    return GestureDetector(
      key: _tagKeys[category.title], // 为每个标签设置key
      onTap: () {
        viewModel.selectCategory(category);
        // 在下一帧更新指示器位置
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateIndicatorPosition(viewModel);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: widget.spacing),
        padding: EdgeInsets.symmetric(
          horizontal: widget.spacing * 2,
          vertical: widget.spacing,
        ),
        child: Text(
          category.title,
          key: _tagTextKeys[category.title], // 新增：为Text设置key
          style: TextStyle(
            color: category.isSelected
                ? widget.selectedColor
                : widget.unselectedColor,
            fontWeight: category.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// 在CategoryViewModel中添加一个辅助方法，用于查找选中的类别
extension CategoryListExtension on List<CategoryEntity> {
  CategoryEntity? firstWhereOrNull(bool Function(CategoryEntity) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}