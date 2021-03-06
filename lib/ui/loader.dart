import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/parts/svg.dart';
import 'package:flutter_svg/svg.dart';

ValueNotifier loaderValue = ValueNotifier('working');

class UiLoader extends StatefulWidget {
  UiLoader({key});

  @override
  createState() {
    return UiLoaderState();
  }

  static showLoader(BuildContext context) async {
    loaderValue.value = 'working';
    await showDialog(
        builder: (context) => UiLoader(), context: context, barrierDismissible: false);
  }

  static doneLoader(BuildContext context) async {
    loaderValue.value = 'done';
    await Future.delayed(Duration(milliseconds: 900));
    Navigator.pop(context);
  }

  static errorLoader(BuildContext context) async {
    loaderValue.value = 'error';
    await Future.delayed(Duration(milliseconds: 900));
    Navigator.pop(context);
  }
}

class UiLoaderState extends State<UiLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0x77161616),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: ValueListenableBuilder(
              builder: (context, value, w) {
                Widget retWidget;
                if (value == 'working') {
                  retWidget = CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xffFF8A71)),
                  );
                }

                if (value == 'done') {
                  retWidget = SvgPicture.string(SvgIcons.spinnerMark);
                }

                if (value == 'error') {
                  retWidget = SvgPicture.string(SvgIcons.spinnerError);
                }
                return AnimatedSwitcher(
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                  duration: Duration(milliseconds: 300),
                  child: retWidget,
                );
              },
              valueListenable: loaderValue,
            ),
          ),
        ),
      ),
    );
  }
}
