import 'package:flutter/material.dart';

ThemeData darkTheme(context) => ThemeData(
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey[900],
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)))),
      appBarTheme:
          const AppBarTheme(color: Color.fromARGB(255, 0, 0, 0), elevation: 0),
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'RobotoCondensed',
      primaryTextTheme: const TextTheme(
          titleMedium: TextStyle(
        color: Colors.white,
      )),
      inputDecorationTheme: InputDecorationTheme(
        //filled: true,
        fillColor: Colors.white,
        prefixIconColor: Colors.white,
        suffixIconColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(20)),
      ),
      primarySwatch: Colors.purple,
      secondaryHeaderColor: Colors.white,
      primaryColor: Colors.black,
      highlightColor: Colors.grey[900],
      hoverColor: Colors.grey[800],
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );





ThemeData lightTheme(context) => ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'RobotoCondensed',
      inputDecorationTheme: InputDecorationTheme(
        //filled: true,
        //fillColor: Colors.black,
        prefixIconColor: Colors.black,
        suffixIconColor: Colors.black,
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(20)),
      ),

      primarySwatch: Colors.purple,
      secondaryHeaderColor: Colors.black,
      primaryColor: Colors.white,

      ///Color.fromARGB(255, 224, 224, 224),
      highlightColor: const Color.fromARGB(255, 224, 224, 224),
      hoverColor: Colors.grey[400],
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color.fromARGB(255, 224, 224, 224),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)))),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
