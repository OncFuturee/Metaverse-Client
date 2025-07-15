import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final double coverAspectRatio;
  const VideoCard({super.key, required this.video, required this.coverAspectRatio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击整体区域默认进入播放页面
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('进入视频播放页面'),duration: Duration(milliseconds: 200),),
        );
        context.router.pushNamed('/videoplayer');
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        color: const Color.fromARGB(255, 244, 239, 245),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            Card(
              margin: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: coverAspectRatio,
                child: Image.network(
                  video.coverUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // 添加 errorBuilder
                  errorBuilder: (context, error, stackTrace) {
                    // 在图片加载失败时显示一个图标或占位符
                    return Container(
                      color: Colors.grey[300], // 可以是任何背景色
                      child: Center(
                        child: Image.asset('assets/images/null.png', fit: BoxFit.fill,),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 视频信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频简介标题
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 作者信息和操作按钮
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 点击头像
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('点击了作者头像'),duration: Duration(milliseconds: 200),),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(video.authorAvatar),
                            radius: 10,
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // 点击作者名字
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('点击了作者名字'),duration: Duration(milliseconds: 200),),
                            );
                          },
                          child: Text(
                            video.authorName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            // 点击更多按钮
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('点击了更多操作'),duration: Duration(milliseconds: 200),),
                            );
                          },
                          child: Icon(Icons.more_vert, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
