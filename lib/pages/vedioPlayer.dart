import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/Kind.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget with WidgetsBindingObserver {
  final Connectedmodel model;
  VideoPlayer(this.model);

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> with WidgetsBindingObserver{
  // @override
  // void initState() {
  //   try {
  //     // print('حاولت');
  //     widget.model.bindBackgroundIsolate();
  //     widget.model.initializeDownloader();
  //   } catch (e) {
  //     print('معرفتش');
  //     print('****************************       Erorr       **********');
  //     print(e);
  //     //   try {
  //     //           print(' تاني حاولت');

  //     //     widget.model.initializeDownloader();
  //     //   } catch (e2) {
  //     //     print(' معرفتش  تاني');
  //     //     print('****************************       Erorr2       **********');
  //     //     print(e2);
  //     //   }
  //     //   // widget.model.unbindBackgroundIsolate();
  //     //   // widget.model.bindBackgroundIsolate();
  //     //
  //   }
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   widget.model.unbindBackgroundIsolate();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
        builder: (BuildContext context, Widget child, Connectedmodel model) {
      return Scaffold(
        drawer: SideDrawer(context),
        appBar: AppBar(
          title: Container(
            child: Text("Vedio Player"),
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15),
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
              ),
              onPressed: () {
                model.cancelDownload(model.video.taskInfo.taskId);
              },
            ),
          ],
        ),
        body: model.videisLoading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : ListView(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: CustomPaint(painter: CurvePainter()),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  YoutubePlayer(
                    context: context,
                    videoId: model.video.id,
                    liveUIColor: Colors.redAccent,
                    flags: YoutubePlayerFlags(
                      autoPlay: false,
                      showVideoProgressIndicator: true,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width * 1,
                    lineHeight: 10,
                    percent: model.video.taskInfo.progress >= 0
                        ? model.video.taskInfo.progress / 100
                        : 0.0,
                    center: Text(
                      model.video.taskInfo.progress >= 0
                          ? model.video.taskInfo.progress.toString() + '%'
                          : '',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                    progressColor: Colors.red[700],
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: 200,
                    alignment: Alignment.center,
                    child: FlatButton(
                      child: Text(
                        "Donwload This " +
                            (model.kindAoV == KindAOV.Video
                                ? "Video"
                                : "Audio"),
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () {
                        model.video.kind == 'video' &&
                                (model.thisVideoNotAvailableforDownload ==
                                        true ||
                                    model.thisVideoWillDownloadWithoutSound ==
                                        true)
                            ? showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('we are sorry!!'),
                                    content: Text(model
                                            .thisVideoNotAvailableforDownload
                                        ? 'this video not available for download.'
                                        : model.thisVideoWillDownloadWithoutSound
                                            ? 'this video not available for download with its sound!'
                                            : ''),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          print(model
                                              .thisVideoNotAvailableforDownload);
                                          print(model
                                              .thisVideoWillDownloadWithoutSound);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(model
                                                .thisVideoNotAvailableforDownload
                                            ? 'okay'
                                            : 'Cancel'),
                                      ),
                                      model.thisVideoNotAvailableforDownload
                                          ? Container()
                                          : FlatButton(
                                              onPressed: () {
                                                model.downloadTasks(
                                                    onlyOneVedio: true);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Download any way'),
                                            )
                                    ],
                                  );
                                })
                            : model.downloadTasks(onlyOneVedio: true);
                      },
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: Footer(),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
