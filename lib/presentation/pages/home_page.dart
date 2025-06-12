import 'package:flutter/material.dart';
import 'package:metaverse_client/presentation/widgets/category_selector.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/video_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  const HomePage({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return SafeArea(
      child: Column(
        children: [
          // 顶部栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      vm.videos.isNotEmpty ? vm.videos[0].authorAvatar : 'https://i.pravatar.cc/150?img=1',
                    ),
                    radius: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索视频/用户',
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        isDense: true,
                      ),
                      readOnly: true,
                      onTap: () {}, // 可扩展
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(icon: Icon(Icons.qr_code_scanner), onPressed: () {}),
                IconButton(icon: Icon(Icons.settings), onPressed: () {}),
              ],
            ),
          ),
          // 分类栏
          SizedBox(
            height: 38,
            width: double.infinity,
            child: CategorySelector(
              storageKey: 'my_categories',
              // 可选配置参数
              selectedColor: Colors.blue,
              unselectedColor: Colors.grey,
              deleteIconColor: Colors.red,
              borderRadius: 16.0,
              iconSize: 24.0,
              spacing: 8.0,
            ),
          ),
          // 视频区
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => vm.fetchVideos(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double padding = 10; // 布局的内边距
                        // 计算每个卡片的最大宽度，手机两列，宽屏自适应多列
                        double maxCardWidth = 220; // 卡片最大宽度
                        int crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(2, 6);
                        double crossAxisSpacing = 6; // 列间距
                        double mainAxisSpacing = 6; // 行间距
                        double coverAspectRatio = 16 / 9; // 封面宽高比
                        double cardWidth = (constraints.maxWidth - padding * 2 - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
                        double coverHeight = cardWidth / coverAspectRatio; // 封面高度
                        double listTileHeight = 60; // 列表项高度
                        double cardAspectRatio = cardWidth / (coverHeight + listTileHeight); // 卡片宽高比
                        return GridView.builder(
                          padding: const EdgeInsets.all(padding),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            childAspectRatio: cardAspectRatio,
                          ),
                          itemCount: vm.videos.length,
                          itemBuilder: (ctx, i) => VideoCard(
                            video: vm.videos[i],
                            coverAspectRatio: coverAspectRatio,),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
