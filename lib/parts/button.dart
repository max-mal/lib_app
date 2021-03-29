import 'package:flutter/material.dart';


class AppButtonWidget extends StatelessWidget {

  final String text;
  final Color color;
  final Color textColor;
  final Function onPress;
  final Border border;
  const AppButtonWidget({
    Key key,
    this.text,
    this.color,
    this.onPress,
    this.textColor,
    this.border,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
          border: border,
        ),
        height: 52,
        width: MediaQuery.of(context).size.width - 48,
        child: Center(
          child: new Text(text, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          ),
        ),
      ),
    );
  }
}
