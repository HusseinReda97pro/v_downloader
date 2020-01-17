import 'package:flutter/material.dart';
import 'package:v_downloader/pages/vedioPlayer.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import '../widgets/helper/ensure_visible.dart.dart';
import 'download.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:scoped_model/scoped_model.dart';

class Home extends StatefulWidget {
  final Connectedmodel model;
  Home(this.model);
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var urlController = TextEditingController();
  final _urlFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildPlayListTextField() {
    return EnsureVisibleWhenFocused(
      focusNode: _urlFocusNode,
      child: TextFormField(
        controller: urlController,
        decoration: InputDecoration(
          labelText: 'URl',
          filled: true,
          suffix: IconButton(
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                urlController.text = '';
              });
            },
          ),
          fillColor: Colors.white,
          border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.black)),
          hintText: "Enter youtube vedio or playlist url to download",
        ),
        //obscureText: true,
        validator: (String value) {
          if (value.isEmpty) {
            return 'invalid URL';
          }
          return null;
        },
        onSaved: (String value) {},
      ),
    );
  }

  Widget _bulidSubmitButton(BuildContext context, Connectedmodel model) {
    return Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.20),
        child: RaisedButton.icon(
          icon: Icon(
            Icons.arrow_downward,
            color: Colors.white,
          ),
          label: Text(
            "Download Now",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () async {
            var tof = model.validateURL(urlController.text);
            if (_formKey.currentState.validate() && tof) {
              if (urlController.text.contains('list=')) {
                var playistId = model.getListId(urlController.text.toString());
                try {
                  model.getPlayListData(playistId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Download(widget.model)));
                } catch (e) {
                  print(e);
                  errorMessage();
                }
              } else {
                if (urlController.text.contains('youtu.be/')) {
                  try {
                    var videoId = urlController.text.split('youtu.be/')[1];
                    print(videoId);
                    await model.downloadVideoData(videoId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return VideoPlayer(widget.model);
                        },
                      ),
                    );
                  } catch (e) {
                    print(e);
                    errorMessage();
                  }
                } else {
                  if (urlController.text.contains('watch?v=')) {
                    try {
                      var videoId = urlController.text.split('watch?v=')[1];
                      model.downloadVideoData(videoId);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return VideoPlayer(widget.model);
                          },
                        ),
                      );
                    } catch (e) {
                      print(e);
                      errorMessage();
                    }
                  }
                }
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Something Went Wrong!!'),
                      content: Text('Url invalid or An unkown Error Occurred!'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Okay'),
                        )
                      ],
                    );
                  });
            }
          },
        ));
  }

  void errorMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Something Went Wrong!!'),
            content: Text('Url invalid or An unkown Error Occurred!'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(context),
      appBar: AppBar(
        title: Container(
          child: Text("V-Downloader"),
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15),
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: CustomPaint(painter: CurvePainter()),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: _buildPlayListTextField(),
              ),
              SizedBox(
                height: 10.0,
              ),
              ScopedModelDescendant<Connectedmodel>(builder:
                  (BuildContext context, Widget child, Connectedmodel model) {
                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: _bulidSubmitButton(context, model),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
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
