import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import 'package:v_downloader/widgets/videoCard.dart';

class Videos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VideosState();
  }
}

class _VideosState extends State<Videos> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
        builder: (BuildContext context, Widget child, Connectedmodel model) {
      return Scaffold(
        drawer: SideDrawer(context),
        appBar: AppBar(
          title: Container(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.20),
            child: Text('Videos'),
          ),
        ),
        body: model.selectedVideos.length == 0
            ? Container(
                alignment: Alignment.center,
                child: Text(
                  'No Videos Downloaded.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(0),
                itemBuilder: (BuildContext context, int index) {
                  return VideoCard(model.selectedVideos[index].title,
                      model.selectedVideos[index].videoPathOnDevice);
                },
                itemCount: model.selectedVideos.length,
              ),
        bottomNavigationBar: Footer(),
      );
    });
  }
}
