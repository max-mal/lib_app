import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/parts/svg.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:flutter_app/ui/checkbox.dart';
import 'package:flutter_app/ui/input.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/modal.dart';
import 'package:flutter_svg/svg.dart';

import '../globals.dart';
import 'loginModal.dart';

class RegisterModal extends StatefulWidget {
  final Function onRegistered;
  final Function onLogin;

  RegisterModal({this.onRegistered, this.onLogin});

  @override
  State<StatefulWidget> createState() {
    return RegisterModalState();
  }
}

class RegisterModalState extends State<RegisterModal> {
  bool privacyAccepted = false;
  GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
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
          Text('Прежде чем начнете',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          SizedBox(
            height: 24,
          ),
          Text(
            'Создайте аккаунт для чтения книг, создайте коллекции и многое другое...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 40),
          Form(
              key: _signUpFormKey,
              child: Column(
                children: [
                  UiFormInput(
                    controller: emailController,
                    label: 'Введите электронную почту',
                    validator: (value) {
                      if (!EmailValidator.validate(value)) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  UiFormInput(
                    controller: passwordController,
                    label: 'Введите пароль',
                    obscure: true,
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return 'Введите пароль';
                      }
                      return null;
                    },
                  ),
                ],
              )),
          SizedBox(height: 24),
          UiButton(
            onPressed: () {
              _register(context);
            },
            child: Text('Создать аккаунт',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          SizedBox(height: 24),
          UiCheckbox(
            checked: privacyAccepted,
            onChanged: (value) {
              setState(() {
                privacyAccepted = value;
              });
            },
            child: Column(
              children: [
                Text.rich(TextSpan(
                    text: 'Я соглашаюсь быть примерным ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: '🐈',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ])),
                    SizedBox(height: 6,)
              ],
            ),
          ),
          SizedBox(height: 54),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showCupertinoModal(context,
                  child: LoginModal(
                    onRegister: () {
                      this.widget.onRegistered();
                    },
                    onLogin: () {
                      this.widget.onLogin();
                    },
                  ),
                  dismissable: false);
            },
            child: Text.rich(TextSpan(
                text: 'У вас есть аккаунт? ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                      text: 'Войдите прямо сейчас',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                ])),
          ),
          SizedBox(height: 54),
        ],
      ),
    );
  }

  _register(context) {
    if (_signUpFormKey.currentState.validate()) {
      if (!privacyAccepted) {
        return showDialog(
            builder: (context) => CupertinoAlertDialog(
              title: Text('Ошибка'),
              content: Text('Примите условия соглашения'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ), context: context);
      }
      UiLoader.showLoader(context);
      serverApi
          .register(emailController.text, passwordController.text)
          .then((result) async {
        if (result == true) {
          await UiLoader.doneLoader(context);
          Navigator.pop(context);
          widget.onRegistered();
        } else {
          await UiLoader.errorLoader(context);
          showDialog(
              builder: (context) => CupertinoAlertDialog(
                title: Text('Ошибка'),
                content: Text(result.toString()),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ), context: context);
        }
      });
    }
  }
}
