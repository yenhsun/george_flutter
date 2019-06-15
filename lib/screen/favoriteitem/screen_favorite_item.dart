import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:george_flutter/util/view/loading.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class FavoriteItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FavoriteList favoriteList = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Center(
        child: Text(favoriteList.snapshot.data[FireStoreConstants.favoriteListName]),
      ),
    );
  }
}
