import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:george_flutter/util/view/loading.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

import '../route_paths.dart';

class FavoriteItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FavoriteItemScreenContainer();
  }
}

class _FavoriteItemScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoriteItemScreenContainerState();
  }
}

class _FavoriteItemScreenContainerState
    extends State<_FavoriteItemScreenContainer> {
  @override
  Widget build(BuildContext context) {
    final FavoriteList favoriteList = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            favoriteList.snapshot.data[FireStoreConstants.favoriteListName]),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _FavoriteItemScreenContainerBranch(),
                ],
              ),
            ],
          ),
          new SizedBox(
            width: double.infinity,
            child: RaisedButton(
              textColor: Colors.white,
              color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4),
              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Text("Find new place"),
              onPressed: () {
                Navigator.pushNamed(context, ScreenPath.find_place_screen, arguments: favoriteList);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class _FavoriteItemScreenContainerBranch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("favorite items");
  }
}
