import 'package:flutter/material.dart';
import 'dart:math' as math;

class StartScreenSlider extends StatefulWidget {
  List<Slide> slides = [];

  StartScreenSlider({this.slides});

  @override
  State<StatefulWidget> createState() {
    return StartScreenSliderState();
  }
}

class StartScreenSliderState extends State<StartScreenSlider>
    with SingleTickerProviderStateMixin {
  int currentSlide = 0;
  AnimationController circleController;
  var animation;
  bool finished = false;

  @override
  void initState() {
    super.initState();

    circleController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    circleController.addListener(() {
      if (circleController.isCompleted) {
        changeSlide();
      }
    });

    animation = Tween<double>(begin: 0.0, end: 7.0).animate(circleController);

    circleController.forward();
  }

  changeSlide() async {
    if (finished) {
      return;
    }

    setState(() {
      currentSlide += 1;
      if (currentSlide > widget.slides.length - 1) {
        currentSlide = widget.slides.length - 1;
      }
    });
    print('Here!');

    await Future.delayed(Duration(milliseconds: 400));

    circleController.reset();
    circleController.forward();

    if (widget.slides.length - 1 == currentSlide) {
      finished = true;
    }
  }

  List<Widget> sliderDots = [];
  List<Widget> sliderDotsInner = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: 150),
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: Column(
                  children: [
                    Text(widget.slides[currentSlide].title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        )),
                    SizedBox(height: 15),
                    Text(widget.slides[currentSlide].description,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        )),
                    widget.slides[currentSlide].bottomWidget ?? Container(),
                    SizedBox(height: 30),
                  ],
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.slides.map((e) {
              Widget child;

              if (widget.slides.indexOf(e) == currentSlide) {
                child = AnimatedBuilder(
                    key: ValueKey(
                        widget.slides.indexOf(e).toString() + '-current'),
                    animation: animation,
                    builder: (context, child) {
                      return MyArc(part: animation.value);
                    });
              } else {
                child = Container(
                  key: ValueKey(widget.slides.indexOf(e).toString()),
                  margin: EdgeInsets.all(7),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffEAEEF2),
                  ),
                );
              }

              return AnimatedSwitcher(
                  duration: Duration(milliseconds: 400), child: child);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class Slide {
  Slide({this.title, this.description, this.bottomWidget});

  String title;
  String description;
  Widget bottomWidget = Container();
}

class MyArc extends StatelessWidget {
  final double diameter;
  final double part;

  const MyArc({Key key, this.diameter = 20, this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(),
      foregroundPainter: CirclePartPainter(part: part),
      size: Size(diameter, diameter),
    );
  }
}

// This is the Painter class
class CirclePartPainter extends CustomPainter {
  double part = 1;
  double oldPart = 1;

  CirclePartPainter({this.part});

  @override
  void paint(Canvas canvas, Size size) {
    oldPart = part;
    Paint paint = Paint()..color = Color(0xffFF8A71);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width / 2),
        height: size.height,
        width: size.width,
      ),
      1,
      part,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldPart != part;
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.height / 2, size.width / 2), 6, paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
