import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/helper/database.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import 'package:path_provider/path_provider.dart';

class DBTest extends StatefulWidget {
  final Connectedmodel model;
  final AudioCache player = AudioCache();
  DBTest(this.model);

  @override
  State<StatefulWidget> createState() {
    return _DBTestState();
  }
}

class _DBTestState extends State<DBTest> {
  var dbHelper;
  @override
  initState() {
    super.initState();
    dbHelper = DBHelper();
  }

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
        builder: (BuildContext context, Widget child, Connectedmodel model) {
      return Scaffold(
        drawer: SideDrawer(context),
        appBar: AppBar(
          title: Container(
            child: Text("Database"),
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15),
          ),
          elevation: 0,
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 50),
            TextFormField(
              controller: controller,
            ),
            SizedBox(height: 50),
            FlatButton(
              color: Colors.green,
              child: Text(
                'Test Audios playlist',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // model.updatepath();
                // dbHelper.updateDonePlaylist('Short n Sweet');
                model.getPlaylistOfAudiosFromDB();
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text(
                'Test',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // model.openDB();
                // model.insertVideoIntoDB();
                // model.dbHelper
                //     .cancleTask('ad2717eb-7bf8-40b8-8cfa-e60f16c115fb');
                // model.getSDCardPath();
                //  var x = await PathProviderEx.getStorageInfo();
                // model.getTest();
                //  print(x.length);
                //  for(var i in x){
                //    print(x[1].rootDir);
                //  }
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text(
                'get from DB!!',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // model.openDB();
                // model.getAudiosFromDB();
                // dbHelper.insertV();
                model.getVideosFromDB(playlistKey: 'Shortn Sweet');
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text(
                'get Playlist Title',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                model.dbtest =
                    await model.getPlaylistTitle(controller.text.toString());
              },
            ),
            FlatButton(
              color: Colors.redAccent,
              child: Text(
                'get Playlist Data',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await dbHelper.getPlayListData();
              },
            ),
            FlatButton(
              color: Colors.grey,
              child: Text(
                'get Data',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                dbHelper.getData();
              },
            ),
            FlatButton(
              color: Colors.grey,
              child: Text(
                'get SD card path',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                var path = await getExternalStorageDirectory();
                print(path);
              },
            ),
            SizedBox(height: 50),
            Text(
              model.dbtest,
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            // FlatButton(
            //   color: Colors.red,
            //   child: Text('test Audio', style: TextStyle(color: Colors.white)),
            //   onPressed: () async{
            //    await widget.player.play('/storage/emulated/0/VDownloader/audios/Queen - We Are The Champions (Official Video).mp3');
            //   },
            // )
          ],
        ),
      );
    });
  }
}
