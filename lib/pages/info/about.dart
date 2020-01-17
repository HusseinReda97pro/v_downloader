import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:v_downloader/widgets/footer.dart';
import 'package:v_downloader/widgets/sideDrawer.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final sendMail = TapGestureRecognizer()
    ..onTap = () async {
      final url = 'mailto:pro.hussein.reda@gmail.com';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch';
      }
    };
  final upworkProfilePage = TapGestureRecognizer()
    ..onTap = () async {
      print('ssssssssssssssssssssssssssssssssssssss');
      final url = 'https://www.upwork.com/freelancers/~01329937a2178fc839';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch';
      }
    };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(context),
      appBar: AppBar(
        title: Container(
          child: Text("About"),
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.25),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: CustomPaint(painter: CurvePainter()),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.09,
          ),
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text(
                'this app for download youtube videos and playlists as videos (.mp4) files or just sounds (.mp3) files.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              )),
          Divider(),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Text(
              'warning this app is beta version, it maybe sometimes crashes, or show unwanted behaviors, so kindly if you faced any issues let me know to solve it as soon as possible (by sending the issue form "report an issue tab" in the menu).',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  'all rights reserved @ 2019 for Hussein Reda who developed this app.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                Text.rich(
                  TextSpan(
                      text: 'you can contact me by email',
                      children: <TextSpan>[
                        TextSpan(
                            text: ' Pro.hussein.reda@gmail.com ',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                            recognizer: sendMail),
                        TextSpan(
                          text: ' or my ',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        TextSpan(
                            text: ' upwork ',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                            recognizer: upworkProfilePage),
                        TextSpan(
                          text: ' account ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: ' if you need me for a freelance job. ',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ]),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // BottomNavigationBar(
          //   items: <BottomNavigationBarItem>[
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.announcement), title: Text("Announcements")),
          //     BottomNavigationBarItem(
          //         icon: Icon(Icons.cake), title: Text("Birthdays")),
          //   ],
          // )
        ],
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
