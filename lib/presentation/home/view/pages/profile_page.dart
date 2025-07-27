import 'package:flutter/material.dart';
import 'package:metaverse_client/core/utils/colorextractor.dart';

/// 扩展 Color 类，添加调暗颜色的方法
extension DarkenColor on Color {
  /// 调暗颜色，[amount] 参数范围为 0.0 到 1.0
  /// 0.0 表示不调暗，1.0 表示完全变黑
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1); // 确保 amount 在有效范围内
    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();

  const ProfilePage({super.key});
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey appBarKey = GlobalKey(); // AppBar容器的key
  final GlobalKey topContainerKey = GlobalKey(); // 顶部头像到个签的容器key
  int _currentNavIndex = 0; // 导航栏当前选中索引
  double? backgroundImgHeight; // 背景图片的高度 （AppBar + topContainer）的高度
  final double topCardRadius = 24; // 顶部卡片圆角半径
  Color dominantColor = Colors.brown.withAlpha((0.8 * 255).floor()); // 主色调（棕色系）
  ImageProvider imageProvider = NetworkImage('https://picsum.photos/1000/300?random=1'); // 背景图片
  double statusBarHeight = 0; // 状态栏高度

  @override
  void initState() {
    super.initState();
    // 在布局完成后获取顶部容器的高度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox topContainerRenderBox =
          topContainerKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox appBarRenderBox =
          appBarKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        statusBarHeight = MediaQuery.of(context).padding.top;
        backgroundImgHeight = topContainerRenderBox.size.height + topCardRadius 
                              + appBarRenderBox.size.height;
      });
      // 异步预加载图片（不会阻塞UI）
      // 位置不能放在initState中，因为此时context还未完全构建
      _preloadImage();
    });
  }

  // 预加载图片的方法
  Future<void> _preloadImage() async {
    try {
      // 预加载图片（在后台线程下载）
      await precacheImage(imageProvider,context,);

      // 使用ColorExtractor提取主色调
      Color extractedColor = await ColorExtractor.extractDominantColorFromProvider(
        provider: imageProvider,
        defaultColor: Colors.brown.withAlpha((0.8 * 255).floor()),
      );
      
      // 图片加载完成后更新状态（可选）
      if (mounted) {
        setState(() {dominantColor = extractedColor;});
      }
    } catch (e) {
      print('图片加载失败: $e');
      // 处理错误，例如设置默认图片
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置背景图片
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景图片
          Container(
            height:
                backgroundImgHeight ?? MediaQuery.of(context).size.height * .5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            // 添加渐变遮罩层
            child: Stack(
              children: [
                // 底部渐变遮罩
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 100, // 渐变高度，可根据需要调整
                  child: Container(
                    decoration: BoxDecoration(
                      // 垂直渐变，从透明过渡到图片主色调（棕色系）
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          dominantColor.withAlpha((0.8*255).floor()).darken(.5), // 主色调半透明 调暗
                          dominantColor.darken(.5), // 主色调不透明 调暗
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomScrollView(
            slivers: [
              // 1. 顶部AppBar
              SliverToBoxAdapter(
                child: Container(
                  key: appBarKey,
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                  ), // 顶部填充以模拟状态栏和AppBar高度
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // 子组件之间分散空间
                    children: [
                      // 左侧图标
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), // 透明灰色背景
                          borderRadius: BorderRadius.circular(999), // 圆角
                        ),
                        margin: EdgeInsets.only(left: 4.0), // 添加一些外边距
                        child: IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // 点击添加用户功能
                            print('添加用户');
                          },
                        ),
                      ),
                      // 标题
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), // 透明灰色背景
                          borderRadius: BorderRadius.circular(999), // 圆角
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ), // 文本内边距
                        child: const Text(
                          'Andrew..',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // 右侧图标
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), // 透明灰色背景
                          borderRadius: BorderRadius.circular(999), // 圆角
                        ),
                        margin: EdgeInsets.only(right: 4.0), // 添加一些外边距
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // 更多操作点击事件
                            print('更多操作');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 2. 上半部分：个性化背景 + 个人信息区
              SliverToBoxAdapter(
                child: Container(
                  key: topContainerKey,
                  child: Column(
                    children: [
                      // 头像
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/100/100?random=2',
                        ), // 示例头像
                      ),
                      SizedBox(height: 16),

                      // 用户名
                      Text(
                        '@andrew_aisnley',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),

                      // 简介
                      Text(
                        'Designer & Videographer',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. 卡片风格的个人资料区
              SliverToBoxAdapter(
                child: ClipRRect(
                  // 仅设置顶部圆角，模拟卡片风格
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(topCardRadius),
                  ),
                  child: Container(
                    color: Colors.white, // 卡片背景色
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        // 统计数据（Posts/Followers等）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StatItem(title: '247', sub: 'Posts'),
                            StatItem(title: '368K', sub: 'Followers'),
                            StatItem(title: '374', sub: 'Following'),
                            StatItem(title: '3.7M', sub: 'Likes'),
                          ],
                        ),
                        SizedBox(height: 24),

                        // 编辑按钮（点击事件：进入编辑页面）
                        ElevatedButton(
                          onPressed: () {
                            // TODO: 实现编辑个人资料逻辑
                            debugPrint('点击了编辑个人资料按钮');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Edit Profile'),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              ),

              // 4. 吸顶导航栏（滚动时吸附到顶部）
              SliverPersistentHeader(
                pinned: true, // 关键：设置为true实现吸顶效果
                delegate: NavBarDelegate(
                  height: 56, // 导航栏高度
                  currentIndex: _currentNavIndex,
                  onTap: (index) {
                    setState(() => _currentNavIndex = index);
                  },
                ),
              ),

              // 5. 下半部分：内容区
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white, // 卡片背景色
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true, // 适应父容器高度
                      physics: NeverScrollableScrollPhysics(), // 避免嵌套滚动冲突
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 每行3列
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 6, // 示例数据数量
                      itemBuilder: (context, index) {
                        // 示例图片（可替换为真实数据）
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://picsum.photos/200/300?random=$index',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // 底部点赞数（示例）
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  '367.5K', // 示例数据
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计数据组件（Posts/Followers等）
class StatItem extends StatelessWidget {
  final String title;
  final String sub;

  const StatItem({required this.title, required this.sub, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 4),
        Text(sub, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

/// 吸顶导航栏代理（实现SliverPersistentHeaderDelegate）
class NavBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final int currentIndex;
  final Function(int) onTap;

  NavBarDelegate({
    required this.height,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white, // 导航栏背景色
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 导航项1：网格视图（示例功能）
          NavItem(
            icon: Icons.grid_on,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            // 注释：点击切换到「全部内容」视图
          ),
          // 导航项2：私密内容（示例功能）
          NavItem(
            icon: Icons.lock,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            // 注释：点击切换到「私密内容」视图
          ),
          // 导航项3：收藏（示例功能）
          NavItem(
            icon: Icons.bookmark,
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            // 注释：点击切换到「收藏内容」视图
          ),
          // 导航项4：喜欢（示例功能）
          NavItem(
            icon: Icons.favorite,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            // 注释：点击切换到「喜欢内容」视图
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}

/// 导航栏单个选项（带选中下划线）
class NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 点击事件：触发导航切换
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.pink : Colors.grey),
          SizedBox(height: 4),
          // 选中时下划线
          if (isActive) Container(width: 8, height: 2, color: Colors.pink),
        ],
      ),
    );
  }
}
