import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import 'dart:io' as io;
class CurrentDownloads extends StatefulWidget {
  final Connectedmodel model;
  CurrentDownloads(this.model);
  @override
  State<StatefulWidget> createState() {
    return _CurrentDownloadsState();
  }
}

class _CurrentDownloadsState extends State<CurrentDownloads> {
  //  @override
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
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.19),
              child: Text('Downloads'),
            ),
            elevation: 0,
            actions: <Widget>[
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        label: Text('Cancel All'),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Alert !!'),
                                  content: Text(
                                      'this will remove all incomplete downloads.\nare you sure you want do that?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        model.cancelAll();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('continue any way'),
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.pause,
                          color: Colors.red,
                        ),
                        label: Text('Pause All'),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Alert !!'),
                                  content: Text(
                                      'this will Stop all downloads.\nare you sure you want do that?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        model.pauseAll();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('continue any way'),
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                    // PopupMenuItem(
                    //   child: FlatButton.icon(
                    //     icon: Icon(
                    //       Icons.refresh,
                    //       color: Colors.red,
                    //     ),
                    //     label: Text('Retry All'),
                    //     onPressed: () {
                    //       try{
                    //         model.retryAll();
                    //       }catch(_){

                    //       }
                    //     },
                    //   ),
                    // ),
                  ];
                },
              )
            ],
          ),
          body: model.currentDownloadsIsLoading
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: model.refreshDownloads,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                                leading: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.18,
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  child: CircleAvatar(
                                      backgroundImage: model
                                                  .allVideos[index].imageURL !=
                                              null
                                          ? NetworkImage(
                                              model.allVideos[index].imageURL)
                                          : AssetImage(
                                              "assets/placeholder.png")),
                                ),
                                title: Container(
                                  margin: EdgeInsets.only(bottom: 5, top: 5),
                                  child: Text(
                                    index.toString() +
                                        "\. " +
                                        model.allVideos[index].title,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                subtitle: Row(
                                  children: <Widget>[
                                    // _builedPlayButtun(context, index, model.selectedallVideos[index]s[index]),
                                    LinearPercentIndicator(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      lineHeight: 10,
                                      percent: model.videos[index].taskInfo
                                                  .progress >=
                                              0
                                          ? model.videos[index].taskInfo
                                                  .progress /
                                              100
                                          : io.Directory(model.videos[index]
                                                          .videoPathOnDevice)
                                                      .exists() !=
                                                  null
                                              ? 1.0
                                              : 0.0,
                                      center: Text(
                                        model.videos[index].taskInfo.progress >=
                                                0
                                            ? model.videos[index].taskInfo
                                                    .progress
                                                    .toString() +
                                                '%'
                                            : io.Directory(model.videos[index]
                                                            .videoPathOnDevice)
                                                        .exists() !=
                                                    null
                                                ? '100%'
                                                : '',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 8),
                                      ),
                                      progressColor: Colors.red[700],
                                    )
                                  ],
                                )
                                // ,
                                // trailing:
                                //     _builedPlayButtun(context, index, widget.vedios[index].id),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    model.cancelDownload(
                                        model.allVideos[index].taskInfo.taskId);
                                    model.cancelDownloadFromSelectList(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.pause,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    try {
                                      model.pauseDownload(model
                                          .allVideos[index].taskInfo.taskId);
                                    } catch (_) {}
                                  },
                                ),
                              ],
                            ),
                            Divider()
                          ],
                        ),
                      );
                    },
                    itemCount: model.allVideos.length,
                  ),
                ),
        );
      },
    );
  }
}
