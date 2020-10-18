import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../api.dart';
import '../colors.dart';
import '../globals.dart';

class WelcomeScreen extends StatefulWidget {
  final Function goTo;

  const WelcomeScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  final _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return new Container(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            new Column(
              children: [
                this.welcomeText(),
                this.welcomeDescriptionText(),
                this.loginForm(),
                SizedBox(height: 100),
              ],
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: this.noAccountText(),
            )
          ],
        ),
      ),
    );
  }

  Widget welcomeText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.2),
      child: new Center(
        child:
          new Text(
            'Добро пожаловать',
            style: new TextStyle(
              fontSize: 32
            ),
            textAlign: TextAlign.center,
          ),
        ),
    );
  }
  Widget welcomeDescriptionText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
      child: new Center(
        child:
        new Text(
          'Войдите, чтобы начать читать книги,\n создавать свои коллекции и многое другое...',
          style: new TextStyle(
              fontSize: 14
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget noAccountText()
  {
    return new Container(
//      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.15, bottom: 10),
      child: new Center(
        child:
        new RawMaterialButton(
          onPressed: () {
            widget.goTo('signup');
          },
          child: new Text(
            'У вас нет аккаунта? Создать сейчас',
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

  Widget loginForm()
  {
    return new Container(
      margin: EdgeInsets.only(top: 40, left: 24, right: 24),
      child: new Form(
        key: _loginFormKey,
        child: Column(
          children: [
            new Container(
              margin: EdgeInsets.only(top: 24),
              child: this.loginFormEmail(),
            ),
            new Container(
              margin: EdgeInsets.only(top: 24),
              child: this.loginFormPassword(),
            ),
            new Container(
              margin: EdgeInsets.only(top: 24),
              child: this.loginFormSubmit(),
            )
          ],
        )
      )
    );
  }

  Widget loginFormEmail () {
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

  Widget loginFormPassword () {
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

  Widget loginFormSubmit() {
    return new ButtonTheme(
      minWidth: MediaQuery.of(context).size.width,
      height: 52,
      child: FlatButton(
        color: AppColors.primary,
        padding: EdgeInsets.all(10),
        onPressed: () {
          if (_loginFormKey.currentState.validate()) {
            serverApi.login(emailController.text, passwordController.text).then((result) {
              if (result == true) {
                this.widget.goTo('home');
              } else {
                print(result);
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(result)));
              }
            });
          }
        },
        child: new Text('Войти', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
        )),
      )
    );
  }

}