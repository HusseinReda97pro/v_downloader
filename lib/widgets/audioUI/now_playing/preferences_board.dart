import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/playback.dart';
import 'package:v_downloader/models/playerstate.dart';

class PreferencesBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<
                MapEntry<MapEntry<AudioPlayerState, Song>, List<Song>>>(
              stream: Observable.combineLatest2(
                model.playerState$,
                model.favorites$,
                (a, b) => MapEntry(a, b),
              ),
              builder: (BuildContext context,
                  AsyncSnapshot<
                          MapEntry<MapEntry<AudioPlayerState, Song>,
                              List<Song>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Icon(
                    Icons.favorite,
                    size: 35,
                    color: Color(0xFFC7D2E3),
                  );
                }
                final AudioPlayerState _state = snapshot.data.key.key;
                if (_state == AudioPlayerState.stopped) {
                  return Icon(
                    Icons.favorite,
                    size: 35,
                    color: Color(0xFFC7D2E3),
                  );
                }
                final Song _currentSong = snapshot.data.key.value;
                final List<Song> _favorites = snapshot.data.value;
                final bool _isFavorited = _favorites.contains(_currentSong);
                return IconButton(
                  onPressed: () {
                    if (_isFavorited) {
                      model.removeFromFavorites(_currentSong);
                    } else {
                      model.addToFavorites(_currentSong);
                    }
                  },
                  icon: Icon(
                    Icons.favorite,
                    size: 35,
                    color:
                        !_isFavorited ? Color(0xFFC7D2E3) : Colors.redAccent,
                  ),
                );
              },
            ),
            StreamBuilder<List<Playback>>(
              stream: model.playback$,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Playback>> snapshot) {
                if (!snapshot.hasData) {
                  return Icon(
                    Icons.loop,
                    size: 35,
                    color: Color(0xFFC7D2E3),
                  );
                }
                final List<Playback> _playbackList = snapshot.data;
                final bool _isSelected =
                    _playbackList.contains(Playback.repeatSong);
                return IconButton(
                  onPressed: () {
                    if (!_isSelected) {
                      model.updatePlayback(Playback.repeatSong);
                    } else {
                      model.removePlayback(Playback.repeatSong);
                    }
                  },
                  icon: Icon(
                    Icons.loop,
                    size: 35,
                    color: !_isSelected ? Color(0xFFC7D2E3) : Colors.redAccent,
                  ),
                );
              },
            ),
            StreamBuilder<List<Playback>>(
              stream: model.playback$,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Playback>> snapshot) {
                if (!snapshot.hasData) {
                  return Icon(
                    Icons.loop,
                    size: 35,
                    color: Color(0xFFC7D2E3),
                  );
                }
                final List<Playback> _playbackList = snapshot.data;
                final bool _isSelected =
                    _playbackList.contains(Playback.shuffle);
                return IconButton(
                  onPressed: () {
                    if (!_isSelected) {
                      model.updatePlayback(Playback.shuffle);
                    } else {
                      model.removePlayback(Playback.shuffle);
                    }
                  },
                  icon: Icon(
                    Icons.shuffle,
                    size: 35,
                    color: !_isSelected ? Color(0xFFC7D2E3) : Colors.redAccent,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
