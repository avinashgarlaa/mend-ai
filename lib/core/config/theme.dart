import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.teal,
  ).copyWith(secondary: Colors.orangeAccent),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
);
