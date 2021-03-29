import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/parts/svg.dart';
import 'package:flutter_app/screens/registerModal.dart';
import 'package:flutter_app/screens/restoreModal.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:flutter_app/ui/input.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/modal.dart';
import 'package:flutter_svg/svg.dart';

import '../globals.dart';

class LoginModal extends StatefulWidget {
  final Function onLogin;
  final Function onRegister;

  LoginModal({this.onLogin, this.onRegister});

  @override
  State<StatefulWidget> createState() {
    return LoginModalState();
  }
}

class LoginModalState extends State<LoginModal> {
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
          SvgPicture.string(SvgIcons.logo),
          SizedBox(
            height: 40,
          ),
          Text('Добро пожаловать',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          SizedBox(
            height: 24,
          ),
          Text(
            'Войдите, чтобы начать читать книги, создавать свои коллекции и многое другое...',
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
              _login(context);
            },
            child: Text('Войти',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              showCupertinoModal(context,
                  child: RestoreModal(
                    onLogin: this.widget.onLogin,
                    onRegister: this.widget.onRegister,
                  ));
            },
            child: Text.rich(TextSpan(
                text: 'Вы ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: 'забыли пароль?',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline),
                  ),
                ])),
          ),
          SizedBox(height: 54),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showCupertinoModal(context, child: RegisterModal(
                onRegistered: () {
                  this.widget.onRegister();
                },
              ), dismissable: false);
            },
            child: Text.rich(TextSpan(
                text: 'У вас нет аккаунта? ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                      text: 'Создайть сейчас',
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

  _login(context) {
    if (_signUpFormKey.currentState.validate()) {
      UiLoader.showLoader(context);
      serverApi
          .login(emailController.text, passwordController.text)
          .then((result) async {
        if (result == true) {
          await UiLoader.doneLoader(context);
          Navigator.pop(context);
          widget.onLogin();
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
