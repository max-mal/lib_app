import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/parts/scrollBooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/parts/startScreenSlider.dart';
import 'package:flutter_app/screens/registerModal.dart';
import 'package:flutter_app/ui/button.dart';
import '../utils/modal.dart';
import 'loginModal.dart';

class StartScreen extends StatefulWidget {
  final Function goTo;

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
                  child: TextButton(
                    onPressed: () {                                       
                      showCupertinoModal(context,
                          child: RegisterModal(
                            onRegistered: () {
                              this.widget.goTo('afterRegister');
                            },
                            onLogin: () {
                              this.widget.goTo('home');
                            },
                          ),
                          dismissable: false);
                    },
                    child: Text('Пропустить',
                      style: TextStyle(color: Colors.black)
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(12.0)
                        )
                      )
                    ),     
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
            StartScreenSlider(slides: [
              Slide(
                  title: 'MeowBooks - МяуБиблиотека',
                  description:
                      'Библиотека только для Мяу и Мурр...',
                      bottomWidget: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Image(
                          image: AssetImage("assets/logo.png"),
                          height: 55,
                        ),
                      )),
              Slide(
                  title: 'Берите с собой',
                  description:
                      'Читайте и слушайте где угодно. Дома, в\nдороге - интернет не нужен.',
                      bottomWidget: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Icon(Icons.wifi_off, color: AppColors.grey, size: 40,),
                      )),
              Slide(
                  title: 'Слушайте TTS',
                  description:
                      'Книги можно слушать,\nиспользуя технологию text-to-speach',
                      bottomWidget: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Icon(Icons.volume_up, color: AppColors.grey, size: 40,),
                      )),
              Slide(
                  title: 'Подскажем, что выбрать',
                  description: 'Система рекоммендаций, только для Вас',
                  bottomWidget: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Icon(Icons.favorite_border, color: AppColors.grey, size: 40,),
                  )
              ),
            ]),
            SizedBox(height: 30),
            UiButton(
              onPressed: () {
                showCupertinoModal(context,
                  child: RegisterModal(
                    onRegistered: () {
                      this.widget.goTo('afterRegister');
                    },
                    onLogin: () {
                      this.widget.goTo('home');
                    },
                  ),
                  dismissable: false);
              },
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Зарегистрироваться',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,                        
                          color: Colors.white)),
                  SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text('🐈', style: TextStyle(
                      fontSize: 22
                    )),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            UiButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: () {
                showCupertinoModal(context,
                    child: LoginModal(
                      onRegister: () {
                        this.widget.goTo('afterRegister');
                      },
                      onLogin: () {
                        this.widget.goTo('home');
                      },
                    ),
                    dismissable: false);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('У меня есть аккаунт',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff161616))),

                  SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text('🐱', style: TextStyle(
                      fontSize: 22
                    )),
                  )
                ],
              ),
              backgroundColor: UiButtonColors.secondaryColor,
              borderColor: UiButtonColors.secondaryBorderColor,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              margin: EdgeInsets.only(bottom: 40),
              child: Text(
                'Библиотека, которая насчитывает более 🐈 книг всех жанров. Книги можно читать и слушать онлайн и офлайн. Чтобы слушать в приложении, надо офо🐈 Мяу Мурр Мяу. \n\nНикаких подписок и всякой 🐈. Просто читайте и слушайте. Спасибо проекту flibusta.is за книги в открытом доступе. \n\nМяу!',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
