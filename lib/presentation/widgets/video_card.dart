import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final double coverAspectRatio;
  const VideoCard({super.key, required this.video, required this.coverAspectRatio});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
              ),
            ),
          ),
          // 视频信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 0,
              ),
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
                      CircleAvatar(
                        backgroundImage: NetworkImage(video.authorAvatar),
                        radius: 10,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.authorName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Icon(Icons.more_vert, size: 20),
                    ],
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
