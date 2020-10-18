import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/core/models/preferences.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/platform/screen.dart';

import '../colors.dart';
import '../globals.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    Key key,
  }) : super(key: key);


  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {

  String loadingStatus = '';

  @override
  void initState() {
    super.initState();
    initApp();
  }

  initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    setState(() { loadingStatus = 'Инициализация базы данных...'; });

    serverApi.token = await Preferences.get('token');
    setState(() { loadingStatus = 'Проверка соединения с сервером...'; });
    await serverApi.probe();

    setState(() { loadingStatus = 'Вход в систему...'; });
    if (serverApi.token == null) {
      List<dynamic> users =await new User().all();

      for (User user in users) {
        user.remove();
      }
    } else {
      user = await User.getUser();
    }

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      serverApi.probe();
    });
    setState(() { loadingStatus = 'Запуск приложения...'; });

    Timer(Duration(seconds: 1), (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppScreen()));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                const Color(0xFF3366FF),
                const Color(0xFF00CCFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text('SUNNA_BOOK', style: TextStyle(fontSize: 25, color: Colors.white),),
                  ),
                  Container(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: LinearProgressIndicator()
                  ),
                ],
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              bottom: 10,
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(loadingStatus, style: TextStyle(color: Colors.white),)
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}