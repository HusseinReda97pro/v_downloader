import 'dart:io' as io;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/models/vedioData.dart';
import 'package:v_downloader/pages/vedioPlayer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';

class Download extends StatefulWidget {
  final Connectedmodel model;
  Download(this.model);
  @override
  State<StatefulWidget> createState() {
    return _DownloadState();
  }
}

class _DownloadState extends State<Download> with WidgetsBindingObserver {
  Widget _builedPlayButtun(BuildContext context, int index, VideoData video) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.08,
        child: IconButton(
          icon: Icon(Icons.play_arrow),
          color: Colors.red[400],
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return VideoPlayer(widget.model);
                },
              ),
            );
          },
        ));
  }

  // @override
  // void initState() {
  //   try {
  //     widget.model.bindBackgroundIsolate();
  //     widget.model.initializeDownloader();
  //   } catch (e) {
  //     print('****************************       Erorr       **********');
  //     print(e);
  //   }
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   // widget.model.unbindBackgroundIsolate();
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
            child: Text("V-Downloader"),
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15),
          ),
          elevation: 0,
          actions: <Widget>[
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Icon(
                Icons.file_download,
                color: Colors.white,
              ),
              onPressed: () async {
                await model.extractAllVideosUrls();
                model.playlistVideosWithoutSound > 0
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Something Went Wrong!!'),
                            content: Text(
                                'due to issues with download links, there is ' +
                                    model.playlistVideosWithoutSound
                                        .toString() +
                                    ' video will download without sound'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  model.downloadTasks();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Download any way'),
                              )
                            ],
                          );
                        })
                    : model.downloadTasks();
              },
            ),
            // RaisedButton(
            //     color: Theme.of(context).primaryColor,
            //     child: Icon(
            //       Icons.scanner,
            //       color: Colors.white,
            //     ),
            //     onPressed: ()async {
            //       // print(model.allVideos[4].taskInfo.link);
            //       // print(model.videos[6].taskInfo.link);
            //                       await model.extractAllVideosUrls();

            //     })
          ],
        ),
        body: model.isLoadingPlaylist
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Column(children: <Widget>[
                    model.startDownlodisLoading && index == 0
                        ? Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                          )
                        : Container(),
                    ListTile(
                        leading: Container(
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.height * 0.09,
                          child: CircleAvatar(
                              backgroundImage: model.videos[index].imageURL !=
                                      null
                                  ? NetworkImage(model.videos[index].imageURL)
                                  : AssetImage("assets/placeholder.png")),
                        ),
                        title: Container(
                          margin: EdgeInsets.only(bottom: 5, top: 5),
                          child: Text(
                            index.toString() +
                                "\. " +
                                model.videos[index].title,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        subtitle: Row(
                          children: <Widget>[
                            _builedPlayButtun(
                                context, index, model.videos[index]),
                            LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width * 0.6,
                              lineHeight: 10,
                              percent: model.videos[index].taskInfo.progress >=
                                      0
                                  ? model.videos[index].taskInfo.progress / 100
                                  : io.Directory(model.videos[index]
                                                  .videoPathOnDevice)
                                              .exists() !=
                                          null
                                      ? 1.0
                                      : 0.0,
                              center: Text(
                                model.videos[index].taskInfo.progress >= 0
                                    ? model.videos[index].taskInfo.progress
                                            .toString() +
                                        '%'
                                    : io.Directory(model.videos[index]
                                                    .videoPathOnDevice)
                                                .exists() !=
                                            null
                                        ? '100%'
                                        : '',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 8),
                              ),
                              progressColor: Colors.red[700],
                            )
                          ],
                        )
                        // ,
                        // trailing:
                        //     _builedPlayButtun(context, index, widget.vedios[index].id),
                        ),
                    Divider()
                  ]);
                },
                itemCount: model.videos.length,
              ),
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
