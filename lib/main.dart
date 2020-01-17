import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/pages/SplashScreen.dart';
import 'package:v_downloader/pages/audios.dart';
import 'package:v_downloader/pages/currentDownloads.dart';
import 'package:v_downloader/pages/home.dart';
import 'package:v_downloader/pages/info/about.dart';
import 'package:v_downloader/pages/info/send.dart';
import 'package:v_downloader/pages/playlists.dart';
import 'package:v_downloader/pages/settings.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/pages/testdb.dart';
import 'package:v_downloader/pages/videos.dart';

void main() async {
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Connectedmodel _model = Connectedmodel();
  @override
  Widget build(BuildContext context) {
    return ScopedModel<Connectedmodel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: SplashScreen(),
        routes: {
          '/home': (BuildContext context) => Home(_model),
          '/settings': (BuildContext context) => Settings(_model),
          '/DBtest': (BuildContext context) => DBTest(_model),
          '/playlists': (BuildContext context) => Playlists(),
          '/videos': (BuildContext context) => Videos(),
          '/audios': (BuildContext context) => Audios(),
          '/about': (BuildContext context) => About(),
          '/send': (BuildContext context) => Send(),
          '/currentDownloads': (BuildContext context) =>
              CurrentDownloads(_model),
        },
      ),
    );
  }
}
