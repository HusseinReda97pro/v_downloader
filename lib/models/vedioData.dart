import 'package:flutter/foundation.dart';

import 'Task.dart';

class VideoData {
  int dbID;
  final String id;
  String title;
  final String imageURL;
  final TaskInfo taskInfo;
  String playlistKey;
  String videoPathOnDevice;
  String kind;
  String done ;
  VideoData(
      {@required this.id,
      @required this.imageURL,
      @required this.title,
      this.taskInfo,
      this.playlistKey = 'Not',
      this.videoPathOnDevice = 'Nan',
      this.kind,
      this.done = 'no',
      dbID= 0});
}
