import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/parts/scrollBooks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/parts/startScreenSlider.dart';
import 'package:flutter_app/screens/registerModal.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../utils/modal.dart';
import 'loginModal.dart';

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
                      // widget.goTo('signup');
                      showCupertinoModal(context,
                          child: RegisterModal(
                            onRegistered: () {
                              this.widget.goTo('genres');
                            },
                            onLogin: () {
                              this.widget.goTo('home');
                            },
                          ),
                          dismissable: false);
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
            UiButton(
              onPressed: () {
                print('Subscription');
              },
              padding: EdgeInsets.symmetric(vertical: 15),
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
            ),
            SizedBox(height: 20),
            UiButton(
              onPressed: () {
                showCupertinoModal(context,
                    child: LoginModal(
                      onRegister: () {
                        this.widget.goTo('genres');
                      },
                      onLogin: () {
                        this.widget.goTo('home');
                      },
                    ),
                    dismissable: false);
              },
              child: Text('У меня есть аккаунт',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff161616))),
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
                'Библиотека, которая насчитывает более 253.000 книг и 48.000 аудиокниг всех жанров. Книги можно читать и слушать онлайн и офлайн. Чтобы слушать в приложении, надо оформить подписку. Если вы подтвердите ваше согласие на оформление пробного периода, то за 24 часа до его окончания мы автоматически продлим подписку на 1 месяц. При этом с вашего аккаунта iTunes будет снята стоимость подписки на 1 месяц. Если вы не хотите оплачивать подписку, вы можете выключить автоматическое продление по крайней мере за 24 часа до окончания пробного периода. Отключить платное автопродление можно в настройках учетной записи iTunes в любой момент. Если вы купите подписку во время действия пробного периода, неиспользованное время пробного периода сгорит. Оформляя подписку, вы соглашаетесь с условиями использования и политикой конфиденциальности.',
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
