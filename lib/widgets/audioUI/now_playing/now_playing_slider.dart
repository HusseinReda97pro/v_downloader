import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/playerstate.dart';

class NowPlayingSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return StreamBuilder<
            MapEntry<Duration, MapEntry<AudioPlayerState, Song>>>(
          stream: Observable.combineLatest2(
              model.position$, model.playerState$, (a, b) => MapEntry(a, b)),
          builder: (BuildContext context,
              AsyncSnapshot<
                      MapEntry<Duration, MapEntry<AudioPlayerState, Song>>>
                  snapshot) {
            if (!snapshot.hasData) {
              return Slider(
                value: 0,
                onChanged: (double value) => null,
                activeColor: Colors.blue,
                inactiveColor: Color(0xFFCEE3EE),
              );
            }
            if (snapshot.data.value.key == AudioPlayerState.stopped) {
              return Slider(
                value: 0,
                onChanged: (double value) => null,
                activeColor: Colors.blue,
                inactiveColor: Color(0xFFCEE3EE),
              );
            }
            final Duration _currentDuration = snapshot.data.key;
            final Song _currentSong = snapshot.data.value.value;
            final int _millseconds = _currentDuration.inMilliseconds;
            final int _songDurationInMilliseconds = _currentSong.duration;
            return Slider(
              min: 0,
              max: _songDurationInMilliseconds.toDouble(),
              value: _songDurationInMilliseconds > _millseconds
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
              activeColor: Colors.blue,
              inactiveColor: Color(0xFFCEE3EE),
            );
          },
        );
      },
    );
  }
}
