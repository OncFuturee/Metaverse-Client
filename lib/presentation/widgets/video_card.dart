import 'package:flutter/material.dart';
import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final double coverAspectRatio;
  const VideoCard({super.key, required this.video, required this.coverAspectRatio});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
          ListTile(
            dense: true,
            tileColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(horizontal: 6),
            leading: CircleAvatar(backgroundImage: NetworkImage(video.authorAvatar), radius: 15,),
            title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(video.authorName),
            trailing: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
