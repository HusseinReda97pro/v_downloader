import 'package:flutter/material.dart';
import 'package:v_downloader/pages/tabs/audioPlaylists.dart';
import 'package:v_downloader/pages/tabs/vidosPlaylists.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';

class Playlists extends StatelessWidget {
  final title = 'Playlists';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: SideDrawer(context),
        appBar: AppBar(
          title: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.all(2.0),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.video_library),
              ),
              Tab(
                icon: Icon(Icons.audiotrack),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            VideosPlaylists(),
            AudioPlaylists(),
          ],
        ),
        bottomNavigationBar: Footer(),
      ),
    );
  }
}
