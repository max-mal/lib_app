import 'package:flutter/material.dart';

class UiButtonColors {
  static const Color primaryColor = Color(0xffFF8A71);
  static const Color secondaryColor = Colors.white;
  static const Color secondaryBorderColor = Color(0xffEAEEF2);
}

class UiButton extends StatelessWidget {
  Color backgroundColor;
  Color borderColor;
  Widget child;
  Function onPressed;
  EdgeInsets padding;

  UiButton(
      {this.backgroundColor = UiButtonColors.primaryColor,
      this.borderColor = Colors.transparent,
      this.child,
      this.padding,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: backgroundColor,
      shape: new RoundedRectangleBorder(
          side: BorderSide(color: borderColor),
          borderRadius: new BorderRadius.circular(14.0)),
      onPressed: onPressed,
      minWidth: MediaQuery.of(context).size.width - 50,
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 20),
        child: child,
      ),
    );
  }
}
