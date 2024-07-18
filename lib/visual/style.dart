
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Style {
  
  static final ThemeData data = ThemeData(
    //primaryColor: pink,
    //secondaryHeaderColor: green,
    scaffoldBackgroundColor: black,
    cardTheme: const CardTheme(
      elevation: 0,
      color: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      color: blue,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        //shadowColor: green,
        minimumSize: const Size(60, 60),
        backgroundColor: Colors.white,
        foregroundColor: black,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        )
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: black,
      elevation: 0,
      extendedTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      indicatorColor: yellow,
      labelColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      )
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
  );

  static const Color pink = Color(0xffef1f93);
  static const Color blue = Color(0xff00a7e7);
  static const Color yellow = Color(0xffffed00);
  static const Color green = Color(0xff00a159);
  static const Color black = Color(0xff1d1d1b);
  static const TextStyle headerText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );


  static Color memberButtonColor(bool isCheckedIn) {
    return isCheckedIn ? pink : Colors.white;
  }
}