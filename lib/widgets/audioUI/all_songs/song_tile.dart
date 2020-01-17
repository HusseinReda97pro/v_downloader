import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/common/music_icons.dart';
import 'package:v_downloader/models/playerstate.dart';

class SongTile extends StatelessWidget {
  final Song _song;
  String _artists;
  String _duration;
  SongTile({Key key, @required Song song})
      : _song = song,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    parseArtists();
    parseDuration();
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return StreamBuilder<MapEntry<AudioPlayerState, Song>>(
          stream: model.playerState$,
          builder: (BuildContext context,
              AsyncSnapshot<MapEntry<AudioPlayerState, Song>> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final AudioPlayerState _state = snapshot.data.key;
            final Song _currentSong = snapshot.data.value;
            final bool _isSelectedSong = _song == _currentSong;
            return AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _isSelectedSong
                    ? LinearGradient(
                        colors: [
                          Color(0xFFDDEAF2).withOpacity(0.7),
                          Colors.white,
                        ],
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Divider(
                      color: Colors.transparent,
                      height: 0,
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: AnimatedCrossFade(
                              duration: Duration(
                                milliseconds: 150,
                              ),
                              firstChild: PauseIcon(
                                color: Color(0xFF6D84C1),
                              ),
                              secondChild: PlayIcon(
                                color: Color(0xFFA1AFBC),
                              ),
                              crossFadeState: _isSelectedSong &&
                                      _state == AudioPlayerState.playing
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
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
                                    _song.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF4D6B9C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Colors.transparent,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _artists.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFADB9CD),
                                        letterSpacing: 1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                  // Text(
                                  //   _artists.toUpperCase(),
                                  //   style: TextStyle(
                                  //     fontSize: 16,
                                  //     color: Color(0xFFADB9CD),
                                  //     letterSpacing: 1,
                                  //   ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _duration,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A6C5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _isSelectedSong
                        ? Row(
                            children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: Container(
                                  width: double.infinity,
                                ),
                              ),
                              Flexible(
                                flex: 14,
                                child: StreamBuilder<Duration>(
                                  stream: model.position$,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Duration> snapshot) {
                                    if (!snapshot.hasData) {
                                      return Slider(
                                        value: 0,
                                        onChanged: (double value) => null,
                                        activeColor: Colors.transparent,
                                        inactiveColor: Colors.transparent,
                                      );
                                    }
                                    final Duration _currentDuration =
                                        snapshot.data;
                                    final int _millseconds =
                                        _currentDuration.inMilliseconds;
                                    final int _songDurationInMilliseconds =
                                        _currentSong.duration;
                                    return Slider(
                                      min: 0,
                                      max: _songDurationInMilliseconds
                                          .toDouble(),
                                      value: _songDurationInMilliseconds >
                                              _millseconds
                                          ? _millseconds.toDouble()
                                          : _songDurationInMilliseconds
                                              .toDouble(),
                                      onChangeStart: (double value) =>
                                          model.invertSeekingState(),
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
                                      activeColor: Colors.blue,
                                      inactiveColor: Color(0xFFCEE3EE),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void parseDuration() {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      _duration = _minutes.toString() + ":" + _seconds.toString();
    } else {
      _duration = _minutes.toString() + ":0" + _seconds.toString();
    }
  }

  void parseArtists() {
    _artists = _song.artist.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }
}
