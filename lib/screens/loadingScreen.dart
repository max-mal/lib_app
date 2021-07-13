import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/platform/screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

import '../globals.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    Key key,
  }) : super(key: key);

  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  dispose(){
    _controller.dispose();
    super.dispose();
  }

  initApp() async {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this, value: 0.7);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.repeat(min: 0.8, max: 1, reverse: true);

    WidgetsFlutterBinding.ensureInitialized();
    serverApi.token = await Preferences.get('token');
    await serverApi.probe();

    if (serverApi.token == null) {
      List<dynamic> users = await new User().all();

      for (User user in users) {
        user.remove();
      }
    } else {
      user = await User.getUser();
    }

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      serverApi.probe();
    });

    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppScreen()));
    });

    documentDirectory = await getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffFF8A71),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Material(
            shape: SuperellipseShape(
              borderRadius: BorderRadius.circular(90),
            ),
            color: Colors.white,
            child: Container(
              width: 150,
              height: 150,
              child: Center(
                child: Image(image: AssetImage("assets/logo.png"), width: 95,)
              ),
            ),
          ),
        ),
      ),
    );
  }
}
