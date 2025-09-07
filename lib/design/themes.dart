import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';

class Themes {
  Themes._();

  static ThemeData defaultTheme = ThemeData(
    fontFamily: 'Inter',
    primaryColor: MyColors.primary,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 150,
        fontWeight: FontWeight.w800,
        color: MyColors.lightGray,
      ),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal),
      // # news text style #
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.normal),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
      //####################
      bodyLarge: TextStyle(fontSize: 27, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    ),
  );
}
