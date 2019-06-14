import 'package:flutter/material.dart';
import 'screen/route_paths.dart';
import 'package:george_flutter/screen/sign_in/sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future main() async {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(MaterialApp(
    title: "Sign in",
    debugShowCheckedModeBanner: false,
    initialRoute: ScreenPath.sign_in_screen,
    routes: {
      ScreenPath.sign_in_screen: (context) => SignInScreen(),
    },
  ));
}
