import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/model/model_favorite.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:george_flutter/util/view/favorite_item_row.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:george_flutter/util/map_helper.dart' as MapHelper;
import 'package:george_flutter/util/map_helper.dart';
import 'package:george_flutter/util/shared_preference_helper.dart'
    as SharedPreferenceHelper;
import 'package:george_flutter/util/view/loading.dart';
import 'package:george_flutter/util/view/price.dart';
import 'package:george_flutter/util/view/rating.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';

class PlaceDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FavoriteItem item = ModalRoute.of(context).settings.arguments;
    return _PlaceDetailScreenContainer(item);
  }
}

class _PlaceDetailScreenContainer extends StatefulWidget {
  final FavoriteItem _favoriteItem;

  _PlaceDetailScreenContainer(this._favoriteItem);

  @override
  State<StatefulWidget> createState() {
    return _PlaceDetailScreenState(_favoriteItem);
  }
}

class _PlaceDetailScreenState extends State<_PlaceDetailScreenContainer> {
  final FavoriteItem _favoriteItem;
  bool _isLoading = false;

  _PlaceDetailScreenState(this._favoriteItem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_favoriteItem.displayName}"),
      ),
      body: _PlaceDetailBody(_isLoading, _favoriteItem),
    );
  }

  @override
  void initState() {
    super.initState();

    MapHelper.getPlaceDetail(_favoriteItem.placeId).doOnListen(() {
      setState(() {
        _isLoading = true;
      });
    }).listen((detailResponse) {
      _favoriteItem.apply(detailResponse.result);
    }, onDone: () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _PlaceDetailBody extends StatelessWidget {
  final FavoriteItem _favoriteItem;
  final bool _isLoading;

  _PlaceDetailBody(this._isLoading, this._favoriteItem);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressBar(
          text: "Loading ${_favoriteItem.displayName} information...",
        ),
      );
    } else {
      return Text("done");
    }
  }
}
