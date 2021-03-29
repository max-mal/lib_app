import 'package:flutter/material.dart';

class UiButtonColors {
  static const Color primaryColor = Color(0xffFF8A71);
  static const Color secondaryColor = Colors.white;
  static const Color secondaryBorderColor = Color(0xffEAEEF2);
}

class UiButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final Function onPressed;
  final EdgeInsets padding;

  UiButton(
      {this.backgroundColor = UiButtonColors.primaryColor,
      this.borderColor = Colors.transparent,
      this.child,
      this.padding,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          side: BorderSide(color: borderColor),
          borderRadius: new BorderRadius.circular(14.0))
        ),
        minimumSize: MaterialStateProperty.all(Size.fromWidth(MediaQuery.of(context).size.width - 50))
      ),
      onPressed: onPressed,      
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 20),
        child: child,
      ),
    );
  }
}
