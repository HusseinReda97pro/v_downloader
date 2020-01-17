import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/playerstate.dart';
import 'package:v_downloader/widgets/audioUI/all_songs/song_tile.dart';

class AllSongsScreen extends StatelessWidget {
  AllSongsScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Scaffold(
          body: StreamBuilder<List<Song>>(
            stream: model.songs$,
            builder:
                (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final List<Song> _songs = snapshot.data;
              if (_songs.length == 0) {
                return Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height *0.28),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "ther is no audios.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                key: PageStorageKey<String>("All Songs"),
                padding: const EdgeInsets.only(bottom: 150.0),
                physics: BouncingScrollPhysics(),
                itemCount: _songs.length,
                itemExtent: 110,
                itemBuilder: (BuildContext context, int index) {
                  return StreamBuilder<MapEntry<AudioPlayerState, Song>>(
                    stream: model.playerState$,
                    builder: (BuildContext context,
                        AsyncSnapshot<MapEntry<AudioPlayerState, Song>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      final AudioPlayerState _state = snapshot.data.key;
                      final Song _currentSong = snapshot.data.value;
                      final bool _isSelectedSong =
                          _currentSong == _songs[index];
                      return GestureDetector(
                        onTap: () {
                          model.updatePlaylist(_songs);
                          switch (_state) {
                            case AudioPlayerState.playing:
                              if (_isSelectedSong) {
                                model.pauseMusic(_currentSong);
                              } else {
                                model.stopMusic();
                                model.playMusic(
                                  _songs[index],
                                );
                              }
                              break;
                            case AudioPlayerState.paused:
                              if (_isSelectedSong) {
                                model.playMusic(_songs[index]);
                              } else {
                                model.stopMusic();
                                model.playMusic(
                                  _songs[index],
                                );
                              }
                              break;
                            case AudioPlayerState.stopped:
                              model.playMusic(_songs[index]);
                              break;
                            default:
                              break;
                          }
                        },
                        child: SongTile(
                          song: _songs[index],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
