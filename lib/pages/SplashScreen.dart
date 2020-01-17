import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5),
        () => Navigator.pushReplacementNamed(context, '/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //       colors: [Colors.black, Colors.grey],
            //       begin: FractionalOffset.topLeft,
            //       end: FractionalOffset.bottomRight,
            //       stops: [0, 0, 1, 0],
            //       tileMode: TileMode.clamp),
            // color: Colors.black
            // ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.1, 0.4, 0.85, 0.95],
                colors: [
                  Colors.red[800],
                  Colors.yellow[700],
                  Colors.red[600],
                  Colors.yellow[800],
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Image.asset(
                            "assets/icon/logo.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text("Download All You Want!!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
