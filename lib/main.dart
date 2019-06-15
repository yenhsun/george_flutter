import 'package:flutter/material.dart';
import 'package:george_flutter/screen/map/screen_map.dart';
import 'screen/route_paths.dart';
import 'package:george_flutter/screen/sign_in/screen_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fimber/fimber.dart';

Future main() async {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  Fimber.plantTree(DebugTree());

  runApp(MaterialApp(
    title: "Sign in",
    debugShowCheckedModeBanner: false,
    initialRoute: ScreenPath.sign_in_screen,
    routes: {
      ScreenPath.sign_in_screen: (context) => SignInScreen(),
      ScreenPath.map_screen: (context) => MapScreen(),
    },
  ));
}
