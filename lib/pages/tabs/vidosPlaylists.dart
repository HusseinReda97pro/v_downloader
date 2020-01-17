import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';

class VideosPlaylists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
        builder: (BuildContext context, Widget child, Connectedmodel model) {
      return model.selectedPlaylistOfVideos.length == 0
          ? Container(
              alignment: Alignment.center,
              child: Text(
                'there is no videos playlists downloaded yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : model.playlistsLoading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(index.toString()),
                      ),
                      title: Text(
                          model.selectedPlaylistOfVideos[index].playlistName),
                      onTap: () async {
                        await model.getVideosFromDB(
                            playlistKey: model
                                .selectedPlaylistOfVideos[index].playlistName);
                        Navigator.pushNamed(context, '/videos');
                      },
                    );
                  },
                  itemCount: model.selectedPlaylistOfVideos.length,
                );
    });
  }
}
