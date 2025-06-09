import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              video.coverUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(video.authorAvatar)),
            title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(video.authorName),
            trailing: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
