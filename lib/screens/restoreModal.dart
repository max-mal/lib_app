import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/parts/svg.dart';
import 'package:flutter_app/screens/registerModal.dart';
import 'package:flutter_app/ui/button.dart';
import 'package:flutter_app/ui/input.dart';
import 'package:flutter_app/ui/loader.dart';
import 'package:flutter_app/utils/modal.dart';
import 'package:flutter_svg/svg.dart';


class RestoreModal extends StatefulWidget {
  final Function onLogin;
  final Function onRegister;

  RestoreModal({this.onLogin, this.onRegister});

  @override
  State<StatefulWidget> createState() {
    return RestoreModalState();
  }
}

class RestoreModalState extends State<RestoreModal> {
  bool privacyAccepted = false;
  GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

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
          Text('Восстановление',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          SizedBox(
            height: 24,
          ),
          Text(
            'Для восстановления пароля введите данные, которые помните',
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
                ],
              )),
          SizedBox(height: 24),
          UiButton(
            onPressed: () async {
              if (_signUpFormKey.currentState.validate()) {
                UiLoader.showLoader(context);
                await Future.delayed(Duration(milliseconds: 500));
                await UiLoader.doneLoader(context);
                Navigator.pop(context);
              }
            },
            child: Text('Сбросить пароль',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),          
          SizedBox(height: 54),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
}
