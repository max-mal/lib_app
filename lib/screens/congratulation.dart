import 'package:flutter/material.dart';

import '../colors.dart';

class CongratulationScreen extends StatefulWidget {
  final Function goTo;

  const CongratulationScreen({
    Key key,
    this.goTo
  }) : super(key: key);

  _CongratulationScreenState createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<CongratulationScreen> {


  @override
  Widget build(BuildContext context) {

    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // or something simular :)
          child: Stack(
            children: [
              new Column(
                children: [
                  this.congratulationText(),
                  this.congratulationDescriptionText(),
                  new Container(
                      child: this.goHome(),
                      margin: EdgeInsets.only(top: 32),
                  )
                ],
              ),
            ],
          ) ,
        ),
      ),
    );
  }

  Widget congratulationText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.2),
      child: new Center(
        child:
        new Text(
          'Поздравляем!',
          style: new TextStyle(
              fontSize: 32
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget congratulationDescriptionText()
  {
    return new Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
      child: new Center(
        child:
        new Text(
          'Регистрация завершена. Теперь вы можете\n начать открывать для себя любимые книги и\n надемся вам понравится это приложение!',
          style: new TextStyle(
              fontSize: 14
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget goHome()
  {
    return new ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 52,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.primary),
            padding: MaterialStateProperty.all(EdgeInsets.all(10))
          ),          
          onPressed: () {
              widget.goTo('home');
          },
          child: new Text('Перейти к приложению', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
          )),
        )
    );
  }


}