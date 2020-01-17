import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:v_downloader/ShardData/conecctedDaata.dart';
import 'package:v_downloader/models/Kind.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/helper/ensure_visible.dart.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';

class Send extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SendState();
  }
}

class _SendState extends State<Send> {
  FocusNode _messageFocusNode = FocusNode();
  TextEditingController _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<Connectedmodel>(
      builder: (BuildContext context, Widget child, Connectedmodel model) {
        return Scaffold(
          drawer: SideDrawer(context),
          appBar: AppBar(
            elevation: 0,
            title: Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.2),
              child: Text(model.messageType == Message.FeadBack
                  ? 'FeadBack'
                  : 'Report Issue'),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: ListView(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: CustomPaint(painter: CurvePainter()),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                EnsureVisibleWhenFocused(
                  focusNode: _messageFocusNode,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _messageController,
                      minLines: 6,
                      maxLines: 8,
                      decoration: InputDecoration(
                          hintText: 'Your Message',
                          border: OutlineInputBorder(),
                          focusColor: Colors.blue),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.33),
                  child: RaisedButton.icon(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Send',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onPressed: () async {
                      if (_messageController.text.length > 0) {
                        bool sended = await model.send(_messageController.text);
                        if (sended) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('message sent successfuly.'),
                                  content: Text('Thanks for your co-opration.'),
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
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Something went wrong!'),
                                  content: Text(
                                      'Sorry, there is something  wrong, and your message didn\'t snt.'),
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
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('You didn\'t type any thing!!'),
                                content: Text(
                                    'plase enter your message and try again.'),
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
                  ),
                ),
                
              ],
            ),
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

