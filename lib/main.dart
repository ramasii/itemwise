import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';
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
      splashColor: Color.fromARGB(255, 183, 223, 255),
      canvasColor: Colors.white,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
      ),
      appBarTheme: _appBarTheme(),
    );
  }

  AppBarTheme _appBarTheme() {
    return const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: "Montserrat", fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blue),
        color: Colors.white,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        elevation: 0,
      );
  }
}

