import 'package:flutter/material.dart';

import 'globals.dart';

class AppColors {

  static Color primary = readerNightMode? DarkTheme.primary : WhiteTheme.primary;
  static Color grey = readerNightMode? DarkTheme.grey : WhiteTheme.grey;
  static Color secondary = readerNightMode? DarkTheme.secondary : WhiteTheme.secondary;
  static Color fold = readerNightMode? DarkTheme.fold : WhiteTheme.fold;
  static Color foldA = readerNightMode? DarkTheme.foldA : WhiteTheme.foldA;

  static Color background = readerNightMode? DarkTheme.background : WhiteTheme.background;

  static Color getColor(color) {
    switch (color) {
      case 'background':
        return readerNightMode? DarkTheme.background : WhiteTheme.background;
      case 'primary':
        return readerNightMode? DarkTheme.primary : WhiteTheme.primary;
      case 'secondary':
        return readerNightMode? DarkTheme.secondary : WhiteTheme.secondary;
      case 'settingsFold':
        return readerNightMode? DarkTheme.settingsFold : WhiteTheme.grey;
      case 'white':
        return readerNightMode? DarkTheme.black : WhiteTheme.white;
      case 'black':
        return readerNightMode? DarkTheme.white : WhiteTheme.black;
    }
  }

}

class WhiteTheme {
  static Color primary = Color.fromRGBO(255, 211, 193, 1);
  static Color grey = Color.fromRGBO(159, 159, 159, 1);
  static Color secondary = Colors.red;
  static Color fold = Color.fromRGBO(244, 246, 247, 1);
  static Color foldA = Color.fromRGBO(159, 159, 159, 1);
  static Color background = Colors.white;
  static Color white = Colors.white;
  static Color black = Colors.black;
}

class DarkTheme {
  static Color primary = Color.fromRGBO(255, 211, 193, 1);
  static Color grey = Color.fromRGBO(159, 159, 159, 1);
  static Color secondary = Colors.red;
  static Color fold = Color.fromRGBO(244, 246, 247, 1);
  static Color foldA = Color.fromRGBO(159, 159, 159, 1);
  static Color background = Colors.black;
  static Color settingsFold = Color.fromRGBO(159, 159, 159, 0.5);
  static Color black = Colors.black;
  static Color white = Colors.white;
}
