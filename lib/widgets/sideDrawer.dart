import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/Kind.dart';

class SideDrawer extends StatelessWidget {
  final context;
  SideDrawer(this.context);
  @override
  Widget build(BuildContext context) {
    return Drawer(child: ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return ListView(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Main Menu'),
              elevation:
                  Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home Page'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.arrow_drop_down_circle),
              title: Text('current Downloads'),
              onTap: () {
                // model.getNotCompletFromDB();
                Navigator.pushReplacementNamed(context, '/currentDownloads');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Playlists'),
              onTap: () {
                model.getPlaylistOfVideosFromDB();
                model.getPlaylistOfAudiosFromDB();
                Navigator.pushReplacementNamed(context, '/playlists');
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('videos'),
              onTap: () async {
                await model.getVideosFromDB(playlistKey: 'Not');
                Navigator.pushReplacementNamed(context, '/videos');
              },
            ),
            ListTile(
              leading: Icon(Icons.audiotrack),
              title: Text('audios'),
              onTap: () async {
                await model.getAudiosFromDB(playlistKey: 'Not');
                model.getAudios();
                model.retrieveFavorites();
                Navigator.pushReplacementNamed(context, '/audios');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('About'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/about');
              },
            ),
            ListTile(
              leading: Icon(Icons.mail),
              title: Text('Send fadebcak'),
              onTap: () {
                model.messageType = Message.FeadBack;
                Navigator.pushReplacementNamed(context, '/send');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('report an issue'),
              onTap: () {
                model.messageType = Message.Issue;
                Navigator.pushReplacementNamed(context, '/send');
              },
            ),
            Divider(),
            ListTile(
                leading: Icon(Icons.music_video),
                title: Text('All Audios on your device'),
                onTap: () {
                  model.fetchSongs();
                  model.retrieveFavorites();
                  Navigator.pushReplacementNamed(context, '/audios');
                }),
            // Divider(),
            // // ListTile(
            //   leading: Icon(Icons.date_range),
            //   title: Text('Test DB'),
            //   onTap: () {
            //     Navigator.pushReplacementNamed(context, '/DBtest');
            //   },
            // ),
          ],
        );
      },
    ));
  }
}
