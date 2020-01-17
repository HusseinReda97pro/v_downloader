import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/widgets/audioUI/all_songs/all_songs_screen.dart';
import 'package:v_downloader/widgets/audioUI/bottom_panel.dart';
import 'package:v_downloader/widgets/audioUI/favorites/favorites_screen.dart';
import 'package:v_downloader/widgets/audioUI/now_playing/now_playing_screen.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';

class Audios extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AudiosStat();
  }
}

class _AudiosStat extends State<Audios> {
  PanelController _panelController;

  @override
  void initState() {
    _panelController = PanelController();

    super.initState();
  }

  @override
  void dispose() {
    try {
      _panelController.close();
    } catch (e) {
      print('close animtion controller in audios page');
      print(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _radius = 25.0;
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return WillPopScope(
          onWillPop: () {
            if (!_panelController.isPanelClosed()) {
              _panelController.close();
            } else {
              // _showExitDialog();
              Navigator.pop(context);
              model.dispose();
            }
            return Future<bool>.value(false);
          },
          child: Scaffold(
            drawer: SideDrawer(context),
            appBar: AppBar(
              title: Container(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.21),
                child: Text(
                  "Audios",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              elevation: 0,
            ),
            body: SlidingUpPanel(
              panel: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_radius),
                  topRight: Radius.circular(_radius),
                ),
                child: NowPlayingScreen(controller: _panelController),
              ),
              controller: _panelController,
              minHeight: 115,
              maxHeight: MediaQuery.of(context).size.height,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              collapsed: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_radius),
                    topRight: Radius.circular(_radius),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.0,
                      0.3,
                      0.7,
                      1,
                    ],
                    colors: [
                      // Color(0xFF47ACE1),
                      // Color(0xFFDF5F9D),
                      Colors.redAccent,
                      Colors.yellow[800],
                      Colors.yellow[600],
                      Colors.deepOrange[500]
                    ],
                  ),
                ),
                child: BottomPanel(controller: _panelController),
              ),
              body: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: TabBar(
                      // indicatorColor: Color(0xFFD9EAF1),
                      // labelColor: Color(0xFF274D85),
                      // unselectedLabelColor: Color(0xFF274D85).withOpacity(0.6),
                      tabs: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.music_note),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Songs",
                                style: TextStyle(fontSize: 20.0),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.favorite),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Favorites",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ],
                            )),
                      ],
                    ),
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  body: TabBarView(
                    key: UniqueKey(),
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      AllSongsScreen(),
                      FavoritesScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showExitDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           "V-Downloader",
  //           style: TextStyle(
  //             fontSize: 20,
  //           ),
  //         ),
  //         content: Text(
  //           "are you want to close the audios also?",
  //           style: TextStyle(
  //             fontSize: 18,
  //           ),
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             textColor: Colors.redAccent,
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text("NO"),
  //           ),
  //           ScopedModelDescendant<Connectedmodel>(
  //             builder:
  //                 (BuildContext context, Widget child, Connectedmodel model) {
  //               return FlatButton(
  //                 textColor: Colors.redAccent,
  //                 onPressed: () {
  //                   SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //                   model.dispose();
  //                 },
  //                 child: Text("YES"),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
