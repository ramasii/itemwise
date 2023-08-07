import 'package:flutter/material.dart';
import './pages/pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Wise',
      theme: ThemeData(
        fontFamily: "Montserrat",
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.lightBlue,
        splashColor: Color.fromARGB(255, 183, 223, 255),
        canvasColor: Colors.white,
        // accentColor: Colors.lightBlue,
        // backgroundColor: Colors.white,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(fontFamily: "Montserrat", fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blue),
          color: Colors.white,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          elevation: 0,
          // brightness: Brightness.light,.
        ),
      ),
      home: SplashPage(),
    );
  }
}

