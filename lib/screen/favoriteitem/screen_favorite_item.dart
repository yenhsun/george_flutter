import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/model/model_favorite.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
import 'package:george_flutter/util/view/favorite_item_row.dart';
import 'package:george_flutter/util/firebase_helper.dart';
import 'package:george_flutter/util/view/loading.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../route_paths.dart';

class FavoriteItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FavoriteItemScreenContainer(
        ModalRoute.of(context).settings.arguments);
  }
}

class _FavoriteItemScreenContainer extends StatefulWidget {
  final FavoriteList _favoriteList;

  _FavoriteItemScreenContainer(this._favoriteList);

  @override
  State<StatefulWidget> createState() {
    return _FavoriteItemScreenContainerState(_favoriteList);
  }
}

class _FavoriteItemScreenContainerState
    extends State<_FavoriteItemScreenContainer> {
  final FavoriteList _favoriteList;
  final List<FavoriteItem> _favoriteItems = List();
  PublishSubject<FavoriteItem> _addToFavoriteIntent =
      PublishSubject<FavoriteItem>();
  PublishSubject<FavoriteItem> _removeFromFavoriteIntent =
      PublishSubject<FavoriteItem>();
  PublishSubject<FavoriteItem> _clickFavoriteIntent =
      PublishSubject<FavoriteItem>();

  _FavoriteItemScreenContainerState(this._favoriteList);

  @override
  void dispose() {
    super.dispose();
    _addToFavoriteIntent.close();
    _removeFromFavoriteIntent.close();
    _clickFavoriteIntent.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              _favoriteList.snapshot.data[FireStoreConstants.favoriteListName]),
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: Expanded(
                child: _FavoriteItemScreenContainerBranch(
                    _favoriteItems,
                    this._addToFavoriteIntent,
                    this._removeFromFavoriteIntent,
                    this._clickFavoriteIntent,
                    _favoriteList),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                textColor: Colors.white,
                color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4),
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Text("Find new place"),
                onPressed: () {
                  var future = Navigator.pushNamed(
                      context, ScreenPath.find_place_screen,
                      arguments: _favoriteList);
                  future.then((dynamic) {
                    _refreshFavoriteItemList();
                  });
                },
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    _refreshFavoriteItemList();

    _removeFromFavoriteIntent.listen((item) {
      Observable.fromFuture(_favoriteList.snapshot.reference
              .collection(FireStoreConstants.collectionFavoriteItem)
              .document(item.placeId)
              .delete())
          .listen((dynamic) {
        debugPrint("delete done, ${item.placeId}");

        setState(() {
          _favoriteItems.remove(item);
        });
      });
    });

    _clickFavoriteIntent.listen((item) {
      _refreshFavoriteItemList();
    });
  }

  void _refreshFavoriteItemList() {
    Observable.fromFuture(_favoriteList.snapshot.reference
            .collection(FireStoreConstants.collectionFavoriteItem)
            .getDocuments())
        .listen((querySnapshot) {
      setState(() {
        _favoriteItems.clear();
        querySnapshot.documents.forEach((document) {
          var item = FavoriteItem.fromJson(document.data);
          item.isFavorite = true;
          _favoriteItems.add(item);
        });
      });
    });
  }
}

class _FavoriteItemScreenContainerBranch extends StatelessWidget {
  final List<FavoriteItem> _favoriteItems;
  final PublishSubject<FavoriteItem> _addToFavoriteIntent;
  final PublishSubject<FavoriteItem> _removeFromFavoriteIntent;
  final PublishSubject<FavoriteItem> _clickIntent;
  final FavoriteList _favoriteList;

  _FavoriteItemScreenContainerBranch(
      this._favoriteItems,
      this._addToFavoriteIntent,
      this._removeFromFavoriteIntent,
      this._clickIntent,
      this._favoriteList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return FavoriteItemRow(
          _favoriteItems[index],
          _addToFavoriteIntent,
          _removeFromFavoriteIntent,
          _favoriteList,
          clickIntent: _clickIntent,
        );
      },
      itemCount: _favoriteItems.length,
    );
  }
}
