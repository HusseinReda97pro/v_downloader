import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v_downloader/models/Task.dart';
import 'package:v_downloader/models/playlistData.dart';
import 'package:v_downloader/models/vedioData.dart';

class DBHelper {
  static Database _database;
  static const String TABLE = 'Downlads';
  static const String DB_NAME = 'VDownloaderDB.db';

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await initDb();
    return _database;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE "$TABLE"  ("id" INTEGER PRIMARY KEY AUTOINCREMENT,' +
            '"videoId"	TEXT,' +
            ' "title"	TEXT,' +
            '"imageURL"	TEXT,' +
            '"taskName"	TEXT,' +
            '"taskLink"	TEXT,' +
            '"taskId"	TEXT,' +
            '"taskProgress"	INTEGER,' +
            '"playlistKey"	TEXT,' +
            '"videoPathOnDevice"	TEXT,' +
            '"Done"	TEXT,	"kind"	TEXT);');
    await db.execute(
        'CREATE TABLE "playlists" ("id"	INTEGER PRIMARY KEY AUTOINCREMENT,' +
            '"playlistName"	TEXT,' +
            '"Done"	TEXT ,' +
            '"kind" TEXT,' +
            '"totalsize" INTEGER,' +
            '"dowmloadsize" INTEGER);');
  }

  Future<int> insert(VideoData video) async {    
    var dbClient = await db;   
    return await dbClient.transaction((txn) async {
      var query =
          "INSERT INTO '$TABLE' ('videoId','title','imageURL','taskName','taskLink','taskId','taskProgress','playlistKey','videoPathOnDevice','kind','Done')" +
              " VALUES ('${video.id}','${video.title}','${video.imageURL}','${video.taskInfo.name}','${video.taskInfo.link}','${video.taskInfo.taskId}','${video.taskInfo.progress}','${video.playlistKey}','${video.videoPathOnDevice}','${video.kind}','${video.done}');";
      return await txn.rawInsert(query);
    });
  }

  Future<dynamic> getDownloadedData({playlistKey, done, kind}) async {
    var dbClient = await db;
    // List<Map> maps = await dbClient.query(TABLE, columns: [ID, NAME]);
    List<Map> maps;
    // if (isPlaylist) {
    //   var playlistDoneKeys = await dbClient.rawQuery(
    //       "SELECT playlistName FROM playlists WHERE Done == '$done' And kind == '$kind'");
    //   var playlistsMap = [];
    //   if (playlistDoneKeys.length > 0) {
    //     for (var key in playlistDoneKeys) {
    //       var map = await dbClient
    //           .rawQuery("SELECT * FROM $TABLE WHERE playlistKey == '$key'");
    //       playlistsMap.add(map);
    //     }
    //     List<List<VideoData>> playlistsVideos = [];
    //     for (var playlist in playlistsMap) {
    //       List<VideoData> listVideos;
    //       for (var videoData in playlist) {
    //         VideoData video = getVideoData(videoData);
    //         listVideos.add(video);
    //       }
    //       playlistsVideos.add(listVideos);
    //     }
    //     return playlistsVideos;
    //   }
    // } else {
    maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE WHERE playlistKey = '$playlistKey' AND kind = '$kind' And Done = '$done' ;");
    List<VideoData> listVideos = [];
    if (maps.length > 0) {
      for (var map in maps) {
        VideoData video = getVideoData(map);
        listVideos.add(video);
      }
      print('totel videos is : ' + listVideos.length.toString());
      // }
      return listVideos;
    }
  }

  VideoData getVideoData(map) {
    return VideoData(
        dbID: map['id'],
        id: map['videoId'],
        title: map['title'],
        imageURL: map['imageURL'],
        taskInfo: TaskInfo(
            link: map['taskLink'],
            taskId: map['taskId'],
            progress: map['taskProgress'],
            name: map['taskName']),
        playlistKey: map['playlistKey'],
        videoPathOnDevice: map['videoPathOnDevice'],
        kind: map['kind'],
        done: map['Done']);
  }

  void updateDone(videoId) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query = "update $TABLE set Done = 'yes' where videoId ='$videoId';";
      return await txn.rawInsert(query);
    });
  }

  void updateProgress(videoId, progress) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query =
          "update $TABLE set taskProgress = $progress where videoId ='$videoId';";
      return await txn.rawInsert(query);
    });
  }

  void cancleTask(taskId) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query = 'DELETE FROM  "$TABLE"  where taskId = "$taskId"';
      return await txn.rawInsert(query);
    });
  }

  void updatepath() async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      // var query = "update $TABLE set videoPathOnDevice = '/storage/emulated/0/VDownloader/audios/Queen - We Are The Champions (Official Video).mp3' where title ='Queen - We Are The Champions (Official Video).mp3';";
      var query =
          'DELETE FROM  "$TABLE"';
      return await txn.rawInsert(query);
    });
  }

  Future<void> insertPlaylistData(PlaylistData playlistData) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      // var query = "update $TABLE set videoPathOnDevice = '/storage/emulated/0/VDownloader/audios/Queen - We Are The Champions (Official Video).mp3' where title ='Queen - We Are The Champions (Official Video).mp3';";
      var query =
          "INSERT INTO 'playlists' ('playlistName','Done','kind','totalsize','dowmloadsize') VALUES('${playlistData.playlistName}','no','${playlistData.kind}',${playlistData.totalsize},0)";
      return await txn.rawInsert(query);
    });
  }

  void incrementDownloadSize(playlistName) async {
    var dbClient = await db;
    var data = await dbClient.rawQuery(
        'SELECT dowmloadsize FROM "playlists" WHERE playlistName = "$playlistName";');
    print("size : " + data[0]['dowmloadsize'].toString());
    updteDownloadSize(playlistName, data[0]['dowmloadsize']);
  }

  void updteDownloadSize(playlistName, downloadsize) async {
    downloadsize += 1;
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query =
          "update 'playlists' set dowmloadsize = $downloadsize where playlistName ='$playlistName';";
      return await txn.rawInsert(query);
    });
  }

  Future<bool> checkifDone(playlistName) async {
    var dbClient = await db;
    var map = await dbClient.rawQuery(
        'SELECT totalsize - dowmloadsize as rest FROM "playlists" WHERE playlistName = "$playlistName";');
    print('the rest is : ' + map[0]['rest'].toString());
    int rest = map[0]['rest'];
    if (rest == 0) {
      return true;
    } else {
      return false;
    }
  }

  void updateDonePlaylist(playlistName) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query =
          "update 'playlists' set Done = 'yes' where playlistName ='$playlistName';";
      return await txn.rawInsert(query);
    });
  }

  Future<List<PlaylistData>> getDownloadedPlaylistData(kind) async {
    var dbClient = await db;
    List<PlaylistData> playlistsData = [];
    var data = await dbClient.rawQuery(
        "SELECT * FROM playlists WHERE kind == '$kind'");
    for (var list in data) {
      playlistsData.add(PlaylistData(
          playlistName: list['playlistName'],
          done: list['Done'],
          id: list['id'],
          dowmloadsize: list['dowmloadsize'],
          kind: list['kind'],
          totalsize: list['totalsize']));
    }
    return playlistsData;
  }

  // Future<int> delete(int id) async {
  //   var dbClient = await db;
  //   return await dbClient.delete(TABLE, where: 'id = ?', whereArgs: [id]);
  // }

  // Future<int> update(VideoData video) async {
  //   var dbClient = await db;
  //   // return await dbClient.update(TABLE, employee.toMap(),
  //   //     where: '$ID = ?', whereArgs: [employee.id]);
  // }
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Future<dynamic> getData({done = false}) async {
    var dbClient = await db;
    List<Map> maps;
    if (done) {
      maps = await dbClient.rawQuery("SELECT * FROM $TABLE And Done = 'yes';");
    } else {
      maps = await dbClient.rawQuery("SELECT * FROM $TABLE;");
    }
    List<VideoData> listVideos = [];
    for (var map in maps) {
      VideoData video = getVideoData(map);
      print(
          '*********************************************************************');
      print(video.id);
      print(video.title);
      print(video.imageURL);
      print(video.taskInfo.name);
      print(video.taskInfo.link);
      print(video.taskInfo.taskId);
      print(video.taskInfo.progress);
      print(video.playlistKey);
      print(video.videoPathOnDevice);
      print(video.kind);
      print(video.done);
      print('******************************************************');
      listVideos.add(video);
    }
    print('totel videos is : ' + listVideos.length.toString());
    return listVideos;
  }

  void getPlayListData() async {
    var dbClient = await db;
    var data = await dbClient.rawQuery("SELECT * FROM playlists");
    for (var list in data) {
      print('***************************************************');
      print(list['playlistName']);
      print(list['Done']);
      print(list['id']);
      print(list['dowmloadsize']);
      print(list['kind']);
      print(list['totalsize']);
      print('***************************************************');
    }
  }

  Future<void> deleteById(videoPathOnDevice) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query =
          'DELETE FROM  "$TABLE"  where videoPathOnDevice = "$videoPathOnDevice"';
      return await txn.rawInsert(query);
    });
  }

  Future<bool> checkIfPlaylistComplete(playlistKey) async {
    var dbClient = await db;
    var maps = await dbClient
        .rawQuery('SELECT FROM  "$TABLE"  where playlistKey = "$playlistKey"');
    var d = await dbClient.rawQuery(
        'SELECT totalsize FROM "playlists" WHERE playlistName = "$playlistKey";');
    if (d[0]['total'] == maps.length) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> getNotComplet() async {
    var dbClient = await db;
    List<Map> maps;
    maps =
        await dbClient.rawQuery("SELECT * FROM $TABLE WHERE   Done = 'no' ;");
    List<VideoData> listVideos = [];
    if (maps.length > 0) {
      for (var map in maps) {
        VideoData video = getVideoData(map);
        listVideos.add(video);
      }
      print('totel videos is : ' + listVideos.length.toString());
      return listVideos;
    }
  }
  void updateTaskId(oldTaskId,newtaskId) async {
    var dbClient = await db;
    return await dbClient.transaction((txn) async {
      var query = "update $TABLE set taskId = '$newtaskId' where taskId ='$oldTaskId';";
      return await txn.rawInsert(query);
    });
  }
}
