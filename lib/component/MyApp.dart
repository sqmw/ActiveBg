import 'dart:convert';
import 'dart:ui';
import 'package:active_bg/component/HomeMain/HomeMain.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: "ActiveBackground",
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(155, 154, 154, 1.0),
        ),
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeMain(),
    );
  }
}
