import 'package:flutter/material.dart';
import 'package:flutter_app/screens/userPreferences.dart';
import 'package:flutter_app/ui/button.dart';

class AfterRegisterScreen extends StatelessWidget {

  final Function goTo;

  AfterRegisterScreen({this.goTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          Image(
            image: AssetImage("assets/logo.png"),
            width: 100,
          ),
          SizedBox(
            height: 40,
          ),
          Text('Регистрация завершена',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          SizedBox(
            height: 24,
          ),
          Text(
            'Настройте свои предпочтения, чтобы мы🐈 могли подобрать Вам интересные книги',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          UiButton(
            backgroundColor: Colors.white,
            borderColor: UiButtonColors.secondaryBorderColor,
            child: Text('Настроить предпочтения',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xff161616)
              )
            ),
            onPressed: () {
              UserPreferencesScreen.open(context);
            },
          ),
          SizedBox(
            height: 20,
          ),
          UiButton(
            child: Text('Продолжить',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white
              )
            ),
            onPressed: () {
              goTo('home');
            },
          ),
        ],
      )
    );
  }
}