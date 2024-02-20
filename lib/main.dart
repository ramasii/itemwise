import 'package:flutter/material.dart';
import 'package:itemwise/allpackages.dart';
import 'l10n/l10n.dart';
import './pages/pages.dart';

void main() {
  runApp(const MyApp());
  // ItemWise.getItems();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Item Wise',
      supportedLocales: L10n.all,
      locale: const Locale('id'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      theme: _themeData(),
      home: SplashPage(),
    );
  }

  //--------------------------------------------------------------------------------//

  ThemeData _themeData() {
    return ThemeData(
        fontFamily: "Montserrat",
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.lightBlue,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        canvasColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromARGB(255, 244, 250, 255),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0,
        ),
        appBarTheme: _appBarTheme(),
        iconTheme: const IconThemeData(color: Colors.blue, size: 35));
  }

  AppBarTheme _appBarTheme() {
    return const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
          fontFamily: "Montserrat",
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.blue),
      color: Color.fromARGB(255, 244, 250, 255),
      iconTheme: IconThemeData(color: Colors.blue),
      elevation: 0,
    );
  }
}
