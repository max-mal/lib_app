import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/parts/scrollBooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/parts/startScreenSlider.dart';

class StartScreen extends StatefulWidget {
  Function goTo;

  StartScreen({this.goTo});

  @override
  State<StatefulWidget> createState() {
    return StartScreenState();
  }
}

class StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  child: ScrollBooks(),
                ),
                Positioned(
                  top: 60,
                  right: 15,
                  child: FlatButton(
                    onPressed: () {
                      print('Skipped');
                      widget.goTo('signup');
                    },
                    child: Text('Пропустить',
                        style: TextStyle(color: Colors.black)),
                    color: Colors.white,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(12.0)),
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
            StartScreenSlider(slides: [
              Slide(
                  title: 'Исламская библиотека',
                  description:
                      'Книги проходят проверку комиссией,\nсостоящей из дипломированных, шариатских\nэкспертов.'),
              Slide(
                  title: 'Берите с собой',
                  description:
                      'Читайте и слушайте где угодно. Дома, в\nдорого - интернет не нужен.'),
              Slide(
                  title: 'Слушайте по подписке',
                  description:
                      'Абонемент, в который входят все 48.000\nаудиокниг исламской библиотеки'),
              Slide(
                  title: 'Подскажем, что выбрать',
                  description: 'Все новинки, разрешите сообщать о них.',
                  bottomWidget: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: FlatButton(
                      onPressed: () {
                        print('Skipped');
                      },
                      child: Text('Разрешить уведомления',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      color: Colors.white,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(12.0)),
                    ),
                  )),
            ]),
            SizedBox(height: 30),
            FlatButton(
                minWidth: MediaQuery.of(context).size.width - 50,
                color: Color(0xffFF8A71),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(14.0)),
                onPressed: () {
                  print('Subscription');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Text('7 дней бесплатно',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Дальше - 300₽ за месяц',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                )),
            SizedBox(height: 20),
            FlatButton(
              color: Colors.white,
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xffEAEEF2)),
                  borderRadius: new BorderRadius.circular(14.0)),
              onPressed: () {
                print('Have account');
                widget.goTo('welcome');
              },
              minWidth: MediaQuery.of(context).size.width - 50,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('У меня есть аккаунт',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff161616))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
