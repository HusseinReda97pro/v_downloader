import 'dart:convert';
import 'dart:io' as io;
import 'dart:isolate';
import 'dart:ui';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_downloader/helper/database.dart';
import 'package:v_downloader/models/Kind.dart';
import 'package:v_downloader/models/Task.dart';
import 'package:v_downloader/models/playerstate.dart';
import 'package:v_downloader/models/playback.dart';
import 'package:v_downloader/models/playlistData.dart';
import 'package:v_downloader/models/vedioData.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_extractor/youtube_extractor.dart';
import '../keys.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

class Connectedmodel extends Model {
  bool isLoadingPlaylist;
  bool startDownlodisLoading = false;
  bool videisLoading;
  var imageURL;
  ListOrVedio kind;
  List<VideoData> videos = [];
  var extractor = YouTubeExtractor();
  var _videoDownloadUrl;
  var tasks;
  ReceivePort _port = ReceivePort();
  VideoData video;
  VideoData video2;
  KindAOV kindAoV;
  var dbHelper;
  List<VideoData> selectedVideos = [];
  List<VideoData> selectedAudios = [];
  List<VideoData> allVideos = [];
  List<PlaylistData> selectedPlaylistOfVideos = [];
  List<PlaylistData> selectedPlaylistOfAudios = [];
  var pathToSaveTo;
  var playlistTitle;
  bool thisVideoWillDownloadWithoutSound;
  bool thisVideoNotAvailableforDownload;
  int playlistVideosWithoutSound = 0;
  bool isSDCard = false;
  SOD deviceOrSD;
  String rootPathToSave;
  bool isAPlaylistt = false;
  bool currentDownloadsIsLoading;
  //  for audio player
  BehaviorSubject<List<Song>> _songs$;
  BehaviorSubject<MapEntry<AudioPlayerState, Song>> _playerState$;
  BehaviorSubject<MapEntry<List<Song>, List<Song>>> _playlist$;
  BehaviorSubject<Duration> _position$;
  BehaviorSubject<List<Playback>> _playback$;
  BehaviorSubject<List<Song>> _favorites$;
  BehaviorSubject<bool> _isAudioSeeking$;
  MusicFinder _audioPlayer;
  Song _defaultSong;
  BehaviorSubject<List<Song>> get songs$ => _songs$;
  BehaviorSubject<MapEntry<AudioPlayerState, Song>> get playerState$ =>
      _playerState$;
  BehaviorSubject<Duration> get position$ => _position$;
  BehaviorSubject<List<Playback>> get playback$ => _playback$;
  BehaviorSubject<List<Song>> get favorites$ => _favorites$;
  ///////////////
  Message messageType;
  bool playlistsLoading;

  ////
  // final pathChannel = MethodChannel('VDownloader/getSDCardPath');
  // Future<String> getTest() async {
  //   try {
  //     var path = await pathChannel.invokeMethod('getSDCardPath');
  //     print(path);
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  var dbtest = 'Test';

  Connectedmodel() {
    dbHelper = DBHelper();
    // clearData();
    // checkDoneForAll();
    // checkDoneForPlaylist();
    bindBackgroundIsolate();
    initializeDownloader();
    getNotCompletFromDB();
    setIsTherSDCard();
    getRootPathToSave();
    getKind();
    // for audio player
    _initDeafultSong();
    _initStreams();
    _initAudioPlayer();
  }
  void initializeDownloader() async {
    // await FlutterDownloader.initialize();
    await FlutterDownloader.registerCallback(downloadCallback);
  }

  String getListId(String url) {
    print(url);
    var listId = url.split('list=')[1];
    print(listId);
    return listId;
  }

  Future<void> getPlayListData(String playlistId) async {
    isLoadingPlaylist = true;
    notifyListeners();
    videos.clear();
    // var playlistKey = randomAlphaNumeric(15);
    var editedPlaylistName = await getPlaylistTitle(playlistId);
    playlistTitle = editPlaylistName(editedPlaylistName);
    var response = await http.get(
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=$youtubeAPIKey');
    final Map<String, dynamic> featchedData = json.decode(response.body);

    var count = 0;
    for (var item in featchedData['items']) {
      try {
        imageURL = item['snippet']['thumbnails']['default']['url'].toString();
      } catch (_) {
        imageURL = null;
      }
      final VideoData video = VideoData(
          id: item['snippet']['resourceId']['videoId'].toString(),
          title: videoTitelEnhancement(item['snippet']['title'].toString()),
          taskInfo: TaskInfo(),
          imageURL: imageURL,
          playlistKey: playlistTitle);
      count = count + 1;
      /////////////////////////
      videos.add(video);
    }
    print('total vedios is : ' + count.toString());
    try {
      var nextPageToken = featchedData['nextPageToken'];
      while (featchedData['pageInfo']['totalResults'] >= count) {
        if (nextPageToken != '') {
          var response = await http.get(
              'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=$youtubeAPIKey&pageToken=$nextPageToken');
          final Map<String, dynamic> featchedData = json.decode(response.body);
          for (var item in featchedData['items']) {
            try {
              imageURL =
                  item['snippet']['thumbnails']['default']['url'].toString();
            } catch (_) {
              imageURL = null;
            }
            final VideoData video = VideoData(
                id: item['snippet']['resourceId']['videoId'].toString(),
                title:
                    videoTitelEnhancement(item['snippet']['title'].toString()),
                imageURL: imageURL,
                playlistKey: playlistTitle,
                taskInfo: TaskInfo());
            count = count + 1;
            videos.add(video);
          }
          nextPageToken = featchedData['nextPageToken'];
        }
      }
    } catch (error) {
      print('Error : ' + error.toString());
    }

    print('total vedios after is : ' + count.toString());
    this.isLoadingPlaylist = false;
    notifyListeners();
  }

  bool validateURL(String url) {
    if (url.contains('list=')) {
      kind = ListOrVedio.PlayList;
      return true;
    } else if (url.contains('youtu.be/')) {
      kind = ListOrVedio.Video;
      return true;
    } else if (url.contains('watch?v=')) {
      kind = ListOrVedio.Video;
      return true;
    } else {
      return false;
    }
  }

  Future<void> extractAllVideosUrls() async {
    startDownlodisLoading = true;
    notifyListeners();
    playlistVideosWithoutSound = 0;
    for (var video in videos) {
      try {
        var videoUrlInfo = await extractor.getMediaStreamsAsync(video.id);
        if (kindAoV == KindAOV.Video) {
          try {
            _videoDownloadUrl = videoUrlInfo.muxed.first.url;
          } catch (e) {
            try {
              _videoDownloadUrl = videoUrlInfo.video.first.url;
              playlistVideosWithoutSound += 1;
            } catch (e) {
              try {
                _videoDownloadUrl = videoUrlInfo.audio.first.url;
                playlistVideosWithoutSound += 1;
              } catch (e) {}
            }
          }
          video.title = video.title;
          video.title = video.title + '.mp4';
          video.kind = 'video';
        } else {
          if (kindAoV == KindAOV.Audio) {
            try {
              _videoDownloadUrl = videoUrlInfo.audio.first.url;
            } catch (e) {
              print(e);
            }
            video.kind = 'audio';
            video.title = video.title + '.mp3';
          }
        }
        video.taskInfo.link = _videoDownloadUrl;
      } catch (erorr) {
        print('FFFFFFFFFFFFFFFFFFF');
        print(erorr);
        print('FFFFFFFFFFFFFFFFFFF');
        // video.taskInfo.link = null;
      }
    }
    startDownlodisLoading = false;
    notifyListeners();
  }

  void downloadTasks({bool onlyOneVedio = false}) async {
    var hasPermation = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (hasPermation.value == 0) {
      // Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      downloadAfterPermission(onlyOneVedio: onlyOneVedio);
    } else {
      downloadAfterPermission(onlyOneVedio: onlyOneVedio);
    }
  }

  void downloadAfterPermission({bool onlyOneVedio = false}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      pathToSaveTo = prefs.get('DownloadLocation');
      if (pathToSaveTo == null || pathToSaveTo == rootPathToSave) {
        if (!await io.Directory(rootPathToSave + 'VDownloader').exists()) {
          await io.Directory(rootPathToSave + 'VDownloader')
              .create()
              .then((io.Directory dir) async {
            if (kind == ListOrVedio.Video) {
              if (video.kind == 'video') {
                if (!await io.Directory(rootPathToSave + 'VDownloader/videos')
                    .exists()) {
                  await io.Directory(rootPathToSave + 'VDownloader/videos')
                      .create()
                      .then((io.Directory subdir) {
                    pathToSaveTo = subdir.path;
                  });
                } else {
                  pathToSaveTo = rootPathToSave + 'VDownloader/videos';
                }
              } else {
                if (video.kind == 'audio') {
                  if (!await io.Directory(rootPathToSave + 'VDownloader/audios')
                      .exists()) {
                    await io.Directory(rootPathToSave + 'VDownloader/audios')
                        .create()
                        .then((io.Directory subdir) {
                      pathToSaveTo = subdir.path;
                    });
                  } else {
                    pathToSaveTo = rootPathToSave + 'VDownloader/audios';
                  }
                }
              }
            } else {
              if (kind == ListOrVedio.PlayList) {
                if (!await io.Directory(
                        rootPathToSave + 'VDownloader/playlists')
                    .exists()) {
                  await io.Directory(rootPathToSave + 'VDownloader/playlists')
                      .create()
                      .then((io.Directory subdir) {
                    pathToSaveTo = subdir.path;
                  });
                } else {
                  pathToSaveTo = rootPathToSave + 'VDownloader/playlists';
                }
                if (!await io.Directory(
                        rootPathToSave + 'VDownloader/playlists/$playlistTitle')
                    .exists()) {
                  await io.Directory(rootPathToSave +
                          'VDownloader/playlists/$playlistTitle')
                      .create()
                      .then((io.Directory subdir) {
                    pathToSaveTo = subdir.path;
                  });
                } else {
                  pathToSaveTo =
                      rootPathToSave + 'VDownloader/playlists/$playlistTitle';
                }
              }
            }
          });
        } else {
          print(kind == ListOrVedio.Video);
          if (kind == ListOrVedio.Video) {
            if (video.kind == 'video') {
              if (!await io.Directory(rootPathToSave + 'VDownloader/videos')
                  .exists()) {
                await io.Directory(rootPathToSave + 'VDownloader/videos')
                    .create()
                    .then((io.Directory subdir) {
                  pathToSaveTo = subdir.path;
                });
              } else {
                pathToSaveTo = rootPathToSave + 'VDownloader/videos';
              }
            } else {
              if (video.kind == 'audio') {
                if (!await io.Directory(rootPathToSave + 'VDownloader/audios')
                    .exists()) {
                  await io.Directory(rootPathToSave + 'VDownloader/audios')
                      .create()
                      .then((io.Directory subdir) {
                    pathToSaveTo = subdir.path;
                  });
                } else {
                  pathToSaveTo = rootPathToSave + 'VDownloader/audios';
                }
              }
            }
          } else {
            if (kind == ListOrVedio.PlayList) {
              if (!await io.Directory(rootPathToSave + 'VDownloader/playlists')
                  .exists()) {
                await io.Directory(rootPathToSave + 'VDownloader/playlists')
                    .create()
                    .then((io.Directory subdir) {
                  pathToSaveTo = subdir.path;
                });
              } else {
                pathToSaveTo = rootPathToSave + 'VDownloader/playlists';
              }
              if (!await io.Directory(
                      rootPathToSave + 'VDownloader/playlists/$playlistTitle')
                  .exists()) {
                await io.Directory(
                        rootPathToSave + 'VDownloader/playlists/$playlistTitle')
                    .create()
                    .then((io.Directory subdir) {
                  pathToSaveTo = subdir.path;
                });
              } else {
                pathToSaveTo =
                    rootPathToSave + 'VDownloader/playlists/$playlistTitle';
              }
            }
          }
        }
      } else {
        if (kind == ListOrVedio.Video) {
        } else {
          if (kind == ListOrVedio.PlayList) {
            if (!await io.Directory('$pathToSaveTo/$playlistTitle').exists()) {
              await io.Directory('$pathToSaveTo/$playlistTitle')
                  .create()
                  .then((io.Directory subdir) {
                pathToSaveTo = subdir.path;
              });
            } else {
              pathToSaveTo = '$pathToSaveTo/$playlistTitle';
            }
          }
        }
      }
    } catch (_) {
      pathToSaveTo = rootPathToSave;
    }
    if (onlyOneVedio) {
      final taskId = await FlutterDownloader.enqueue(
        fileName: video.title,
        url: video.taskInfo.link,
        savedDir: pathToSaveTo,
        showNotification:
            false, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      video.taskInfo.taskId = taskId;
      video.videoPathOnDevice = pathToSaveTo + '/' + video.title;
      video.taskInfo.name = video.title;
      allVideos.add(video);
      var x = await dbHelper.insert(video);
      print('inserted result' + x.toString());
    } else {
      for (var video in videos) {
        final taskId = await FlutterDownloader.enqueue(
          fileName: video.title,
          url: video.taskInfo.link,
          savedDir: pathToSaveTo,
          showNotification:
              false, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
        );
        video.taskInfo.taskId = taskId;
        video.taskInfo.name = video.title;
        video.videoPathOnDevice = pathToSaveTo + '/' + video.title;
        await dbHelper.insert(video);
      }
      await copyList();
      PlaylistData playlistData = PlaylistData(
          playlistName: playlistTitle,
          totalsize: getPlaylistSize(),
          kind: kindAoV == KindAOV.Video ? 'video' : 'audio');
      await dbHelper.insertPlaylistData(playlistData);
    }

    tasks = await FlutterDownloader.loadTasks();
  }

  Future<void> cancelDownload(taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    dbHelper.cancleTask(taskId);
  }

  void cancelDownloadFromSelectList(index) {
    selectedVideos.remove(index);
  }

  Future<void> cancelAll() async {
    currentDownloadsIsLoading = true;
    notifyListeners();
    await FlutterDownloader.cancelAll();
    for (var video in allVideos) {
      dbHelper.cancleTask(video.taskInfo.taskId);
    }
    allVideos.clear();
    currentDownloadsIsLoading = false;
    notifyListeners();
  }

  Future<void> pauseDownload(taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
    // dbHelper.cancleTask(taskId);
  }

  Future<void> retryDownload(taskId) async {
    await FlutterDownloader.retry(taskId: taskId);
    // dbHelper.cancleTask(taskId);
  }

  Future<void> pauseAll() async {
    try {
      for (var download in allVideos) {
        try {
          await FlutterDownloader.pause(taskId: download.taskInfo.taskId);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> retryAll() async {
    currentDownloadsIsLoading = true;
    notifyListeners();
    for (var video in allVideos) {
      final taskId = await FlutterDownloader.enqueue(
        fileName: video.title,
        url: video.taskInfo.link,
        savedDir: video.videoPathOnDevice.replaceAll(video.title, ''),
        showNotification:
            false, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      video.taskInfo.taskId = taskId;
      await dbHelper.updateTaskId(video.taskInfo.taskId, taskId);
    }
    tasks = await FlutterDownloader.loadTasks();
    currentDownloadsIsLoading = false;
    notifyListeners();
  }

  Future<void> downloadVideoData(String videoId) async {
    videisLoading = true;
    notifyListeners();
    var response = await http.get(
        'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$youtubeAPIKey&part=snippet');
    var videoResponseData = json.decode(response.body);
    video = VideoData(
        id: videoResponseData['items'][0]['id'],
        imageURL: videoResponseData['items'][0]['snippet']['thumbnails']
            ['default']['url'],
        title: videoTitelEnhancement(
            videoResponseData['items'][0]['snippet']['title']),
        taskInfo: TaskInfo());
    try {
      var videoUrlInfo = await extractor.getMediaStreamsAsync(video.id);
      if (kindAoV == KindAOV.Video) {
        try {
          _videoDownloadUrl = videoUrlInfo.muxed.first.url;
          thisVideoWillDownloadWithoutSound = false;
          thisVideoNotAvailableforDownload = false;
        } catch (e) {
          try {
            _videoDownloadUrl = videoUrlInfo.video.first.url;
            thisVideoWillDownloadWithoutSound = true;
            thisVideoNotAvailableforDownload = true;
          } catch (e) {
            thisVideoNotAvailableforDownload = true;
          }
        }
        video.kind = 'video';
        video.title = video.title;
        video.title = video.title + '.mp4';
      } else {
        if (kindAoV == KindAOV.Audio) {
          try {
            _videoDownloadUrl = videoUrlInfo.audio.first.url;
          } catch (e) {
            print(e);
          }
          video.kind = 'audio';
          video.title = video.title + '.mp3';
        }
      }
      video.taskInfo.link = _videoDownloadUrl;
      print(_videoDownloadUrl);
    } catch (erorr) {
      video.taskInfo.link = null;
    }
    this.video = video;
    videisLoading = false;
    notifyListeners();
  }

  void bindBackgroundIsolate() {
    print('Entered Bind');
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      print('UI Isolate Callback: $data');
      String id = data[0];
      // DownloadTaskStatus status = data[1];
      int progress = data[2];
      try {
        if (kind == ListOrVedio.PlayList) {
          try {
            video = videos.firstWhere((video) => video.taskInfo.taskId == id);
          } catch (_) {}
          video2 = allVideos.firstWhere((video) => video.taskInfo.taskId == id);
        } else {
          video = this.video;
          video2 = this.video;
        }
      } catch (_) {}
      try {
        video.taskInfo.progress = progress;
      } catch (_) {}
      video2.taskInfo.progress = progress;
      notifyListeners();
      dbHelper.updateProgress(video2.id, progress);
      if (progress == 100 && await io.File(video2.videoPathOnDevice).exists()) {
        video.done = 'yes';
        video2.done = 'yes';
        allVideos.remove(video);
        print('removed');
        notifyListeners();
        dbHelper.updateDone(video2.id);
        // if (kind == ListOrVedio.PlayList) {
        //   await dbHelper.incrementDownloadSize(video2.playlistKey);
        //   var done = await dbHelper.checkifDone(video2.playlistKey);
        //   if (done) {
        //     await dbHelper.updateDonePlaylist(video2.playlistKey);
        //   }
        // }
      }
    });
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    // _port.close();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void getKind() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var recentKind = prefs.get('DownloadKind');
      if (recentKind == 'vedio') {
        kindAoV = KindAOV.Video;
        notifyListeners();
      } else if (recentKind == 'audio') {
        kindAoV = KindAOV.Audio;
        notifyListeners();
      } else {
        kindAoV = KindAOV.Video;
        notifyListeners();
      }
    } catch (_) {}
  }

  void getRootPathToSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var recentRoot = prefs.get('RootPathToSave');
      if (recentRoot == 'card') {
        deviceOrSD = SOD.SDCard;
        rootPathToSave = await getSDCardPath();
        notifyListeners();
      } else if (recentRoot == 'device') {
        deviceOrSD = SOD.DeviceStorage;
        rootPathToSave = await getDevicePath();
        notifyListeners();
      } else {
        deviceOrSD = SOD.DeviceStorage;
        rootPathToSave = await getDevicePath();
        notifyListeners();
      }
    } catch (_) {
      deviceOrSD = SOD.DeviceStorage;
      rootPathToSave = await getDevicePath();
    }
  }

  void chanageKind() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'DownloadKind', kindAoV == KindAOV.Audio ? 'audio' : 'vedio');
  }

  void chanageRootPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'RootPathToSave', deviceOrSD == SOD.DeviceStorage ? 'device' : 'card');
    deviceOrSD == SOD.DeviceStorage
        ? rootPathToSave = await getDevicePath()
        : rootPathToSave = await getSDCardPath();
  }

  void deb(id) async {
    var videoUrlInfo = await extractor.getMediaStreamsAsync(video.id);
    _videoDownloadUrl = videoUrlInfo.muxed.first.url;
  }

  Future<String> getPlaylistTitle(playlistID) async {
    String title;
    var response = await http.get(
        'https://www.googleapis.com/youtube/v3/playlists?part=snippet&id=$playlistID&key=$youtubeAPIKey');
    var resopnseData = json.decode(response.body);
    title = resopnseData['items'][0]['snippet']['title'];
    return title;
  }

// Data base section ////////////////////////////////////
// open the database
  void openDB() async {
    DBHelper ob = DBHelper();
    var database = await ob.db;
    print(database);
  }

  void insertVideoIntoDB() async {
    var value = await dbHelper.insertV();

    print(value);
  }

  Future<dynamic> getAudiosFromDB({playlistKey}) async {
    var audios = await dbHelper.getDownloadedData(
        playlistKey: playlistKey, done: 'yes', kind: 'audio');
    selectedAudios.clear();
    try {
      for (var audio in audios) {
        selectedAudios.add(audio);
        print(audio.videoPathOnDevice);
        print(audio.done);
      }
    } catch (e) {}

    print(selectedAudios);
  }

  Future<dynamic> getVideosFromDB({playlistKey}) async {
    var videosData = await dbHelper.getDownloadedData(
        playlistKey: playlistKey, done: 'yes', kind: 'video');
    selectedVideos.clear();
    try {
      for (var video in videosData) {
        selectedVideos.add(video);
        print(video.videoPathOnDevice);
        print(video.done);
        print(video.playlistKey);
      }
    } catch (e) {}

    print(selectedVideos.length);
  }

  Future<void> getPlaylistOfVideosFromDB() async {
    playlistsLoading = true;
    notifyListeners();
    var lists = await dbHelper.getDownloadedPlaylistData('video');
    selectedPlaylistOfVideos.clear();
    for (var list in lists) {
      selectedPlaylistOfVideos.add(list);
      playlistsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPlaylistOfAudiosFromDB() async {
    playlistsLoading = true;
    notifyListeners();
    var lists = await dbHelper.getDownloadedPlaylistData('audio');
    selectedPlaylistOfAudios.clear();
    for (var list in lists) {
      selectedPlaylistOfAudios.add(list);
      playlistsLoading = false;
      notifyListeners();
    }
  }

  void updatepath() async {
    await dbHelper.updatepath();
    print(selectedAudios);
  }

  int getPlaylistSize() {
    return videos.length;
  }

  // for audio player
  Future<void> fetchSongs({audios = false}) async {
    await MusicFinder.allSongs().then(
      (data) {
        if (audios) {
          for (var song in data) {
            for (var audio in selectedAudios) {
              if (song.uri == audio.videoPathOnDevice) {
                _songs$.add(song);
              }
            }
          }
        } else {
          for (var s in data) {
            print(s.uri);
            print(s.duration);
          }
          _songs$.add(data);
        }
      },
    );
  }

  void getAudios() {
    List<Song> _songs = [];
    int id = 0;
    int albumId = 0;
    for (var audio in selectedAudios) {
      int duration = getDuratin(audio.taskInfo.link);
      Song _song = Song(id, audio.videoPathOnDevice, audio.title, '', albumId,
          duration, audio.videoPathOnDevice, '');
      _songs.add(_song);
      id += 1;
    }

    _songs$.add(_songs);
  }

  void playMusic(Song song) {
    _audioPlayer.play(song.uri);
    updatePlayerState(AudioPlayerState.playing, song);
  }

  void pauseMusic(Song song) {
    _audioPlayer.pause();
    updatePlayerState(AudioPlayerState.paused, song);
  }

  void stopMusic() {
    _audioPlayer.stop();
  }

  void updatePlayerState(AudioPlayerState state, Song song) {
    _playerState$.add(MapEntry(state, song));
  }

  void updatePosition(Duration duration) {
    _position$.add(duration);
  }

  void updatePlaylist(List<Song> normalPlaylist) {
    List<Song> _shufflePlaylist = []..addAll(normalPlaylist);
    _shufflePlaylist.shuffle();
    _playlist$.add(MapEntry(normalPlaylist, _shufflePlaylist));
  }

  void playNextSong() {
    if (_playerState$.value.key == AudioPlayerState.stopped) {
      return;
    }
    final Song _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Song> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == _playlist.length - 1) {
      _index = 0;
    } else {
      _index++;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void playPreviousSong() {
    if (_playerState$.value.key == AudioPlayerState.stopped) {
      return;
    }
    final Song _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Song> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == 0) {
      _index = _playlist.length - 1;
    } else {
      _index--;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void _playSameSong() {
    final Song _currentSong = _playerState$.value.value;
    stopMusic();
    playMusic(_currentSong);
  }

  void _onSongComplete() {
    final List<Playback> _playback = _playback$.value;
    if (_playback.contains(Playback.repeatSong)) {
      _playSameSong();
      return;
    }
    playNextSong();
  }

  void audioSeek(double seconds) {
    _audioPlayer.seek(seconds);
  }

  void addToFavorites(Song song) async {
    List<Song> _favorites = _favorites$.value;
    _favorites.add(song);
    _favorites$.add(_favorites);
    await saveFavorites();
  }

  void removeFromFavorites(Song song) async {
    List<Song> _favorites = _favorites$.value;
    _favorites.remove(song);
    _favorites$.add(_favorites);
    await saveFavorites();
  }

  void invertSeekingState() {
    final _value = _isAudioSeeking$.value;
    _isAudioSeeking$.add(!_value);
  }

  void updatePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    if (playback == Playback.shuffle) {
      final List<Song> _normalPlaylist = _playlist$.value.key;
      updatePlaylist(_normalPlaylist);
    }
    _value.add(playback);
    _playback$.add(_value);
  }

  void removePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    _value.remove(playback);
    _playback$.add(_value);
  }

  Future<void> saveFavorites() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final List<Song> _favorites = _favorites$.value;
    List<String> _encodedStrings = [];
    for (Song song in _favorites) {
      _encodedStrings.add(_encodeSongToJson(song));
    }
    _prefs.setStringList("favorites", _encodedStrings);
  }

  void retrieveFavorites() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final List<Song> _fetchedSongs = _songs$.value;
    List<String> _savedStrings = _prefs.getStringList("favorites") ?? [];
    List<Song> _favorites = [];
    for (String data in _savedStrings) {
      final Song song = _decodeSongFromJson(data);
      for (var fetchedSong in _fetchedSongs) {
        if (song.id == fetchedSong.id) {
          _favorites.add(fetchedSong);
        }
      }
    }
    _favorites$.add(_favorites);
  }

  String _encodeSongToJson(Song song) {
    final _songMap = songToMap(song);
    final data = json.encode(_songMap);
    return data;
  }

  Song _decodeSongFromJson(String ecodedSong) {
    final _songMap = json.decode(ecodedSong);
    final Song _song = Song.fromMap(_songMap);
    return _song;
  }

  Map<String, dynamic> songToMap(Song song) {
    Map<String, dynamic> _map = {};
    _map["album"] = song.album;
    _map["id"] = song.id;
    _map["artist"] = song.artist;
    _map["title"] = song.title;
    _map["albumId"] = song.albumId;
    _map["duration"] = song.duration;
    _map["uri"] = song.uri;
    _map["albumArt"] = song.albumArt;
    return _map;
  }

  void _initDeafultSong() {
    _defaultSong = Song(
      null,
      " ",
      " ",
      " ",
      null,
      null,
      null,
      null,
    );
  }

  void _initStreams() {
    _isAudioSeeking$ = BehaviorSubject<bool>.seeded(false);
    _songs$ = BehaviorSubject<List<Song>>();
    _position$ = BehaviorSubject<Duration>();
    _playlist$ = BehaviorSubject<MapEntry<List<Song>, List<Song>>>();
    _playback$ = BehaviorSubject<List<Playback>>.seeded([]);
    _favorites$ = BehaviorSubject<List<Song>>.seeded([]);
    _playerState$ = BehaviorSubject<MapEntry<AudioPlayerState, Song>>.seeded(
      MapEntry(
        AudioPlayerState.stopped,
        _defaultSong,
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = MusicFinder();
    _audioPlayer.setPositionHandler(
      (Duration duration) {
        final bool _isAudioSeeking = _isAudioSeeking$.value;
        if (!_isAudioSeeking) {
          updatePosition(duration);
        }
      },
    );
    _audioPlayer.setCompletionHandler(
      () {
        _onSongComplete();
      },
    );
  }

  // end audio player               /////////////////
  int getDuratin(String taskLink) {
    print(taskLink);
    var x1 = taskLink.split('&dur=')[1];
    print(x1);
    var x2 = x1.split('&')[0];
    print(x2);
    var duration = double.parse(x2) * 1000;
    return duration.floor();
  }

  String editPlaylistName(playlistTitle) {
    var v1 = playlistTitle.toString().replaceAll('"', "");
    var v2 = v1.replaceAll("'", "");
    return v2;
  }

  String videoTitelEnhancement(title) {
    print('title ' + title);
    var v1 = title.toString().replaceAll('"', "");
    print(v1);
    var v2 = v1.replaceAll("'", "");
    print(v2);
    var v3 = v2.replaceAll('/', '_');
    print(v3);
    return v3;
  }

  Future<bool> isTherASDCard() async {
    var ex = await PathProviderEx.getStorageInfo();
    if (ex.length > 1) {
      return true;
    } else {
      return false;
    }
  }

  void setIsTherSDCard() async {
    isSDCard = await isTherASDCard();
  }

  Future<String> getSDCardPath() async {
    var ex = await PathProviderEx.getStorageInfo();
    return ex[1].appFilesDir + '/';
  }

  Future<String> getDevicePath() async {
    var ex = await PathProviderEx.getStorageInfo();
    return ex[0].rootDir + '/';
  }

  Future<bool> send(message) async {
    final Map<String, dynamic> messageMap = {'message': message};
    String cat = messageType == Message.FeadBack ? 'FeadBack' : 'Issue';
    try {
      var x = await http.post(
          'https://vdownloader-72574.firebaseio.com/$cat.json',
          body: json.encode(messageMap));
      print(x);
      return true;
    } catch (e) {
      print('e');
      return false;
    }
  }

  Future<void> checkDoneForAll() async {
    var donelist = await dbHelper.getData();
    try {
      for (var video in donelist) {
        if (video.done == 'no' &&
            await io.File(video.videoPathOnDevice).exists()) {
          var r = await dbHelper.updateDone(video.id);
          print('video ' + video.videoPathOnDevice + ' update to be done');
          print('reslut is ' + r.toString());
        }
      }
    } catch (e) {
      print('error while updating Done');
      print(e);
    }
  }

  Future<void> checkDoneForPlaylist() async {
    var donelist = await dbHelper.getPlayListData();
    for (var list in donelist) {
      if (list.done == 'no') {
        var tof = await dbHelper.checkIfPlaylistComplete();
        if (tof) {
          var r = await dbHelper.updateDonePlaylist(list.playlistName);
          print('video ' + list.playlistName + ' update to be done');
          print('reslut is ' + r.toString());
        }
      }
    }
  }

  Future<void> clearData() async {
    var clearList = await dbHelper.getData(true);
    try {
      for (var video in clearList) {
        if (!await io.File(video.videoPathOnDevice).exists()) {
          var r = await dbHelper.deleteById(video.videoPathOnDevice);
          print('video ' + video.videoPathOnDevice + ' Deleted');
          print('reslut is ' + r.toString());
        }
      }
    } catch (e) {
      print('error while cleaning');
      print(e);
    }
  }

  Future<dynamic> getNotCompletFromDB() async {
    currentDownloadsIsLoading = true;
    notifyListeners();
    var videosData = await dbHelper.getNotComplet();
    allVideos.clear();
    try {
      for (var video in videosData) {
        allVideos.add(video);
      }
    } catch (e) {}
    currentDownloadsIsLoading = false;
    notifyListeners();
  }

  Future<void> copyList() async {
    int cont = 0;
    for (var video in videos) {
      allVideos.add(video);
      cont += 1;
    }
    print('total copyed : ' + cont.toString());
  }

  Future<void> refreshDownloads() async {
    await checkDoneForAll();
    await getNotCompletFromDB();
  }

  void dispose() {
    stopMusic();
    _isAudioSeeking$.close();
    _songs$.close();
    _playerState$.close();
    _playlist$.close();
    _position$.close();
    _playback$.close();
    _favorites$.close();
  }
}
