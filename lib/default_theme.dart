import 'package:flutter/material.dart';

ThemeData defaultTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 0, 173, 181),
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 0, 173, 181),
      background: Color.fromARGB(255, 238, 238, 238),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Color.fromARGB(255, 57, 62, 70),
          fontSize: 30.0,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w900),
      bodySmall: TextStyle(
        color: Color.fromARGB(255, 57, 62, 70),
        fontSize: 12,
        fontFamily: 'Manrope',
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 0, 173, 181),
      textTheme: ButtonTextTheme.primary,
    ));
