import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';

class AudioPlaylists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
        builder: (BuildContext context, Widget child, Connectedmodel model) {
      return model.selectedPlaylistOfAudios.length == 0
          ? Container(
              alignment: Alignment.center,
              child: Text(
                'there is no audios playlists downloaded yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(index.toString()),
                  ),
                  title:
                      Text(model.selectedPlaylistOfAudios[index].playlistName),
                  onTap: () async {
                    await model.getAudiosFromDB(
                        playlistKey:
                            model.selectedPlaylistOfAudios[index].playlistName);
                    model.getAudios();
                    model.retrieveFavorites();
                    Navigator.pushNamed(context, '/audios');
                  },
                );
              },
              itemCount: model.selectedPlaylistOfAudios.length,
            );
    });
  }
}
