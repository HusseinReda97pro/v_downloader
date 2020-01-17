import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folder_picker/folder_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/Kind.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';

class Settings extends StatefulWidget {
  final Connectedmodel model;
  Settings(this.model);
  @override
  State<StatefulWidget> createState() {
    return _SettingsState();
  }
}

class _SettingsState extends State<Settings> {
  var _pathToSaveTo;
  var _radioGroup = 1;
  var _radioGroupSDCard = 2;

  void getDownloadLocation() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _pathToSaveTo = Directory(prefs.get('DownloadLocation'));
      });
    } catch (_) {}
  }

  void setDownloadLocation(var path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('DownloadLocation', path);
  }

  @override
  void initState() {
    super.initState();
    getDownloadLocation();
  }

  void _folderPicker() async {
    var externalDirectory = Directory(widget.model.rootPathToSave);
    print(externalDirectory.path);
    Navigator.of(context).push<FolderPickerPage>(
        MaterialPageRoute(builder: (BuildContext context) {
      return FolderPickerPage(
        rootDirectory: externalDirectory,
        compact: true,
        pickerIcon: Icon(
          Icons.list,
          color: Colors.red,
        ),

        /// a [Directory] object
        action: (BuildContext context, Directory folder) async {
          _pathToSaveTo = folder;

          setDownloadLocation(folder.path);
          print("Picked folder $folder");
          Navigator.pop(context);
        },
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Container(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.19),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          drawer: SideDrawer(context),
          body: ListView(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: CustomPaint(painter: CurvePainter()),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              Divider(),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    value: model.deviceOrSD == SOD.DeviceStorage ? 2 : 0,
                    activeColor: Colors.red,
                    groupValue: _radioGroupSDCard,
                    onChanged: (_) {
                      setState(() {
                        model.deviceOrSD = SOD.DeviceStorage;
                        widget.model.chanageRootPath();
                      });
                    },
                  ),
                  Text(
                    'Device Storage',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  model.isSDCard == true
                      ? Radio(
                          value: model.deviceOrSD == SOD.SDCard ? 2 : 0,
                          activeColor: Colors.red,
                          groupValue: _radioGroupSDCard,
                          onChanged: (_) {
                            setState(() {
                              model.deviceOrSD = SOD.SDCard;
                              widget.model.chanageRootPath();
                            });
                          },
                        )
                      : Container(),
                  model.isSDCard == true
                      ? Text(
                          'SD Card',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      : Container(),
                ],
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          'Choose Downloads Folder',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Hint : Playlist will Create sub folder.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.13,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: 50,
                      child: RaisedButton.icon(
                          color: Colors.redAccent,
                          label: Text(
                            '',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          icon: Icon(
                            Icons.launch,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          onPressed: () {
                            _folderPicker();
                          }),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.07),
                  child: Column(
                    children: <Widget>[
                      _pathToSaveTo == null
                          ? Text(
                              'No Path was selected.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            )
                          : Text(
                              _pathToSaveTo.path == '/storage/emulated/0/'
                                  ? 'No Path was selected.'
                                  : 'selected path is : ' + _pathToSaveTo.path,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                      Container(
                        padding: EdgeInsets.only(top: 15),
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          child: Text(
                            'rest Defualt',
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            setState(() {
                              _pathToSaveTo = Directory('/storage/emulated/0/');
                              setDownloadLocation(_pathToSaveTo.path);
                            });
                          },
                        ),
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Divider(),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                    value: widget.model.kindAoV == KindAOV.Video ? 1 : 0,
                    activeColor: Colors.red,
                    groupValue: _radioGroup,
                    onChanged: (_) {
                      setState(() {
                        widget.model.kindAoV = KindAOV.Video;
                        widget.model.chanageKind();
                      });
                    },
                  ),
                  Text(
                    'Vedio',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Radio(
                    value: widget.model.kindAoV == KindAOV.Audio ? 1 : 0,
                    activeColor: Colors.red,
                    groupValue: _radioGroup,
                    onChanged: (_) {
                      setState(() {
                        widget.model.kindAoV = KindAOV.Audio;
                        widget.model.chanageKind();
                      });
                    },
                  ),
                  Text(
                    'Audio',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
          bottomNavigationBar: Footer(),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
