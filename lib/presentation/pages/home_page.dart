import 'package:flutter/material.dart';
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: vm.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final cat = vm.categories[i];
                final selected = cat == vm.currentCategory;
                return GestureDetector(
                  onTap: () => vm.fetchVideos(category: cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(cat, style: TextStyle(color: selected ? Colors.white : Colors.black)),
                  ),
                );
              },
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
                        // 计算每个卡片的最大宽度，手机两列，宽屏自适应多列
                        double maxCardWidth = 220;
                        int crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(2, 6);
                        double childAspectRatio = 16 / 14; // 宽高比
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: vm.videos.length,
                          itemBuilder: (ctx, i) => VideoCard(video: vm.videos[i]),
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
