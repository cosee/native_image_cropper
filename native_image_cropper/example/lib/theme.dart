import 'package:flutter/material.dart';

class CustomTheme {
  CustomTheme._();

  static const MaterialColor _green = MaterialColor(
    0xFF4FAF47,
    <int, Color>{
      50: Color(0xFF4FAF47),
      100: Color(0xFF4FAF47),
      200: Color(0xFF4FAF47),
      300: Color(0xFF4FAF47),
      400: Color(0xFF4FAF47),
      500: Color(0xFF4FAF47),
      600: Color(0xFF4FAF47),
      700: Color(0xFF4FAF47),
      800: Color(0xFF4FAF47),
      900: Color(0xFF4FAF47),
    },
  );

  static final ThemeData theme = ThemeData(
    primarySwatch: _green,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4FAF47),
    ),
  );
}
