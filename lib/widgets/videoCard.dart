import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'helper/chewieListItem.dart';

class VideoCard extends StatelessWidget {
  final title;
  final videoPath;
  VideoCard(this.title,this.videoPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ChewieListItem(
            videoPlayerController: VideoPlayerController.network(videoPath),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 22),
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
