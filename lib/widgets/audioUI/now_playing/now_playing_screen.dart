import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/common/music_icons.dart';
import 'package:v_downloader/models/playerstate.dart';
import 'package:v_downloader/widgets/audioUI/now_playing/preferences_board.dart';
import 'empty_album_art.dart';
import 'music_board_controls.dart';
import 'now_playing_slider.dart';

class NowPlayingScreen extends StatelessWidget {
  final PanelController _controller;

  NowPlayingScreen({@required PanelController controller})
      : _controller = controller;

  @override
  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height;
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                height:   MediaQuery.of(context).size.height *0.46,
                child: Stack(
                  children: <Widget>[
                    EmptyAlbumArtContainer(iconSize: 150,albumArtSize: 250,radius: 25,),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MusicBoardControls(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.transparent,
                height: _screenHeight / 15,
              ),
              PreferencesBoard(),
              Divider(
                color: Colors.transparent,
                height: _screenHeight / 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 12,
                      child: Container(
                        child: StreamBuilder<MapEntry<AudioPlayerState, Song>>(
                          stream: model.playerState$,
                          builder: (BuildContext context,
                              AsyncSnapshot<MapEntry<AudioPlayerState, Song>>
                                  snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            if (snapshot.data.key == AudioPlayerState.stopped) {
                              return Container();
                            }
                            final Song _currentSong = snapshot.data.value;

                            final String _artists = _currentSong.artist
                                .split(";")
                                .reduce((String a, String b) {
                              return a + " & " + b;
                            });
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _currentSong.album.toUpperCase() +
                                      " • " +
                                      _artists.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFADB9CD),
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Divider(
                                  height: 5,
                                  color: Colors.transparent,
                                ),
                                Text(
                                  _currentSong.title,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFF4D6B9C),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => _controller.close(),
                        child: HideIcon(
                          color: Color(0xFF90A4D4),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.transparent,
                height: _screenHeight / 22,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: StreamBuilder<MapEntry<AudioPlayerState, Song>>(
                            stream: model.playerState$,
                            builder: (BuildContext context,
                                AsyncSnapshot<MapEntry<AudioPlayerState, Song>>
                                    snapshot) {
                              if (!snapshot.hasData) {
                                return Text(
                                  "0:00",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFADB9CD),
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              final Song _currentSong = snapshot.data.value;
                              final AudioPlayerState _state = snapshot.data.key;
                              if (_state == AudioPlayerState.stopped) {
                                return Text(
                                  "0:00",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFADB9CD),
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                getDuration(_currentSong),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFADB9CD),
                                  letterSpacing: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                      ),
                    ),
                    NowPlayingSlider(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getDuration(Song _song) {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      return _minutes.toString() + ":" + _seconds.toString();
    } else {
      return _minutes.toString() + ":0" + _seconds.toString();
    }
  }
}
