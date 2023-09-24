import 'package:flutter/material.dart';

ThemeData defaultTheme = ThemeData(
    primaryColor: const Color.fromARGB(255, 0, 173, 181),
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 0, 173, 181),
      background: Color.fromARGB(255, 238, 238, 238),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Color.fromARGB(255, 34, 40, 49),
      ),
      bodySmall: TextStyle(
        color: Color.fromARGB(255, 34, 40, 49),
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color.fromARGB(255, 0, 173, 181),
      textTheme: ButtonTextTheme.primary,
    ));
