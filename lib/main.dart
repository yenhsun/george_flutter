import 'package:flutter/material.dart';
import 'screen/route_paths.dart';
import 'package:george_flutter/screen/sign_in/sign_in.dart';

Future main() async {
  runApp(MaterialApp(
    title: "Sign in",
    debugShowCheckedModeBanner: false,
    initialRoute: ScreenPath.sign_in_screen,
    routes: {
      ScreenPath.sign_in_screen: (context) => SignInScreen(),
    },
  ));
}
