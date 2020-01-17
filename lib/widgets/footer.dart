import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      color: Color(0xFFF).withOpacity(0.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      child: CustomPaint(
          painter: CurvePainterFooter(Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * .1))),
    );
  }
}

class CurvePainterFooter extends CustomPainter {
  Size s;
  CurvePainterFooter(this.s);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;

    var path = Path();
    size = s;
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.5, size.height * 0.87);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9584,
        size.width * 1.0, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
