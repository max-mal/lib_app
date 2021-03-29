import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../colors.dart';
import '../globals.dart';

class SignUpScreen extends StatefulWidget {
  final Function goTo;

  const SignUpScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _signUpFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return new Container(
      child: SingleChildScrollView(
        child: new Column(
          children: [
            this.signUpText(),
            this.signUpDescriptionText(),
            this.signUpForm(),
            this.haveAccountText(),
          ],
        ),
      ),
    );
  }

  Widget signUpText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.2),
      child: new Center(
        child:
        new Text(
          'Прежде чем начнете',
          style: new TextStyle(
              fontSize: 32
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget signUpDescriptionText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
      child: new Center(
        child:
        new Text(
          'Создайте аккаунт для чтения книг, создайте\n коллекции и многое другое...',
          style: new TextStyle(
              fontSize: 14
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget haveAccountText()
  {
    return new Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.1, bottom: 10),
        child: new Center(
            child:
            new RawMaterialButton(
                onPressed: () {
                  widget.goTo('welcome');
                },
                child: new Text(
                  'У вас есть аккаунт? Войдите прямо сейчас',
                  style: new TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                )
            )
        )
    );
  }

  Widget signUpForm()
  {
    return new Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05, left: 24, right: 24),
        child: new Form(
            key: _signUpFormKey,
            child: Column(
              children: [
                new Container(
                  margin: EdgeInsets.only(top: 24),
                  child: this.signUpFormEmail(),
                ),
                new Container(
                  margin: EdgeInsets.only(top: 24),
                  child: this.signUpFormPassword(),
                ),
                new Container(
                  margin: EdgeInsets.only(top: 24),
                  child: this.signUpFormPasswordConfirm(),
                ),
                new Container(
                  margin: EdgeInsets.only(top: 24),
                  child: this.signUpFormSubmit(),
                )
              ],
            )
        )
    );
  }

  Widget signUpFormEmail () {
    return new TextFormField(
      controller: emailController,
      decoration: new InputDecoration(
        hintText: 'Введите электронную почту',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      validator: (value) {
        if (!EmailValidator.validate(value)) {
          return 'Введите корректный email';
        }
        return null;
      },
    );
  }

  Widget signUpFormPassword () {
    return new TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: new InputDecoration(
          hintText: 'Введите пароль',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Введите пароль';
        }
        return null;
      },
    );
  }
  Widget signUpFormPasswordConfirm () {
    return new TextFormField(
      controller: confirmationController,
      obscureText: true,
      decoration: new InputDecoration(
          hintText: 'Подтвердите пароль',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Введите подтверждение';
        }
        if(passwordController.text != confirmationController.text) {
          return 'Пароли не совпадают';
        }
        return null;
      },
    );
  }

  Widget signUpFormSubmit() {
    return new ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.primary),
            padding: MaterialStateProperty.all(EdgeInsets.all(10))
          ),
          onPressed: () {
            if (_signUpFormKey.currentState.validate()) {
              serverApi.register(emailController.text, passwordController.text).then((result) {
                if (result == true) {
                  this.widget.goTo('genres');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                }
              });
            }
          },
          child: new Text('Создать аккаунт', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          )),
        )
    );
  }

}