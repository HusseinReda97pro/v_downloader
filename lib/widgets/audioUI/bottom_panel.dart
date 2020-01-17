import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/common/music_icons.dart';
import 'package:v_downloader/models/playerstate.dart';

class BottomPanel extends StatelessWidget {
  final PanelController _controller;

  BottomPanel({@required PanelController controller})
      : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: StreamBuilder<MapEntry<AudioPlayerState, Song>>(
            stream: model.playerState$,
            builder: (BuildContext context,
                AsyncSnapshot<MapEntry<AudioPlayerState, Song>> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final AudioPlayerState _state = snapshot.data.key;
              final Song _currentSong = snapshot.data.value;
              final String _artists = getArtists(_currentSong);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              if (_currentSong.uri == null) {
                                return;
                              }
                              if (AudioPlayerState.paused == _state) {
                                model.playMusic(_currentSong);
                              } else {
                                model.pauseMusic(_currentSong);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: _state == AudioPlayerState.playing
                                  ? PauseIcon(
                                      color: Colors.white,
                                    )
                                  : PlayIcon(
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _currentSong.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Divider(
                                    height: 10,
                                    color: Colors.transparent,
                                  ),
                                  Text(
                                    _artists.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => _controller.open(),
                              child: ShowIcon(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                          ),
                        ),
                        Flexible(
                          flex: 12,
                          child: StreamBuilder<Duration>(
                              stream: model.position$,
                              builder: (BuildContext context,
                                  AsyncSnapshot<Duration> snapshot) {
                                if (_state == AudioPlayerState.stopped ||
                                    !snapshot.hasData) {
                                  return Slider(
                                    value: 0,
                                    onChanged: (double value) => null,
                                    activeColor: Colors.transparent,
                                    inactiveColor: Colors.transparent,
                                  );
                                }
                                final Duration _currentDuration = snapshot.data;
                                final int _millseconds =
                                    _currentDuration.inMilliseconds;
                                final int _songDurationInMilliseconds =
                                    _currentSong.duration;
                                return Slider(
                                  min: 0,
                                  max: _songDurationInMilliseconds.toDouble(),
                                  value: _songDurationInMilliseconds >
                                          _millseconds
                                      ? _millseconds.toDouble()
                                      : _songDurationInMilliseconds.toDouble(),
                                  onChangeStart: (double value) => model.invertSeekingState(),
                                  onChanged: (double value) {
                                    final Duration _duration = Duration(
                                      milliseconds: value.toInt(),
                                    );
                                    model.updatePosition(_duration);
                                  },
                                  onChangeEnd: (double value) {
                                    model.invertSeekingState();
                                    model.audioSeek(value / 1000);
                                  },
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white.withOpacity(0.5),
                                );
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String getArtists(Song song) {
    return song.artist.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }
}
