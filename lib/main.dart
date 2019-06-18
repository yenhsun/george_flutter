import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/screen/favoriteitem/screen_favorite_item.dart';
import 'package:george_flutter/screen/favoritelist/screen_favorite_list.dart';
import 'package:george_flutter/screen/findplaces/screen_find_places.dart';
import 'package:george_flutter/screen/map/screen_map.dart';
import 'package:george_flutter/screen/placedetail/screen_place_detail.dart';
import 'screen/route_paths.dart';
import 'package:george_flutter/screen/sign_in/screen_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fimber/fimber.dart';

const kGoogleApiKey = "AIzaSyBuUW5HBbO_UjaRWaYeVb-p5WC_Qa4HLSc";

Future main() async {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  Fimber.plantTree(DebugTree());

  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(MaterialApp(
    title: "Sign in",
    debugShowCheckedModeBanner: false,
    initialRoute: ScreenPath.sign_in_screen,
    routes: {
      ScreenPath.sign_in_screen: (context) => SignInScreen(),
      ScreenPath.map_screen: (context) => MapScreen(),
      ScreenPath.favorite_list_screen: (context) => FavoriteListScreen(),
      ScreenPath.favorite_item_screen: (context) => FavoriteItemScreen(),
      ScreenPath.find_place_screen: (context) => FindPlaceScreen(),
      ScreenPath.place_detail_screen: (context) => PlaceDetailScreen(),
    },
  ));
}
