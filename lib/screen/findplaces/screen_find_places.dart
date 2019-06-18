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

class FindPlaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FindPlaceScreenContainer(ModalRoute.of(context).settings.arguments);
  }
}

class _FindPlaceScreenContainer extends StatefulWidget {
  final FavoriteList _favoriteList;

  _FindPlaceScreenContainer(this._favoriteList);

  @override
  State<StatefulWidget> createState() {
    return _FindPlaceScreenContainerState(_favoriteList);
  }
}

class _UpdatableDialog extends StatefulWidget {
  final FindPlacesParameter parameter;

  _UpdatableDialog(this.parameter);

  @override
  _UpdatableDialogState createState() => new _UpdatableDialogState(parameter);
}

class _UpdatableDialogState extends State<_UpdatableDialog> {
  FindPlacesParameter parameter;
  bool updated = false;

  _UpdatableDialogState(this.parameter);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Find places settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Distance"),
              Container(
                width: 110,
                child: DropdownButton(
                  items: <String>[
                    '500',
                    '1000',
                    '1500',
                    '2000',
                    FindPlacesParameter.DISTANCE_NONE
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (data) {
                    setState(() {
                      updated = true;
                      parameter.distance = data;
                    });
                  },
                  isExpanded: true,
                  value: parameter.distance,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Search type"),
              Container(
                width: 110,
                child: DropdownButton(
                  items: <String>[
                    FindPlacesParameter.TYPE_RESTAURANT,
                    FindPlacesParameter.TYPE_FOOD,
                    FindPlacesParameter.TYPE_STORE,
                    FindPlacesParameter.TYPE_DELIVERY,
                    FindPlacesParameter.TYPE_TAKE_AWAY
                  ].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (data) {
                    setState(() {
                      updated = true;
                      parameter.type = data;
                    });
                  },
                  isExpanded: true,
                  value: parameter.type,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            if (updated) {
              Navigator.of(context).pop(parameter);
            } else {
              Navigator.of(context).pop(null);
            }
          },
          child: Text("Ok"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}

class _FindPlaceScreenContainerState extends State<_FindPlaceScreenContainer> {
  TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<FavoriteItem> _favoriteItemList = List();
  String _nextPageToken;
  PublishSubject<dynamic> _loadMoreIntent = PublishSubject<dynamic>();
  PublishSubject<FavoriteItem> _addToFavoriteIntent =
      PublishSubject<FavoriteItem>();
  PublishSubject<FavoriteItem> _removeFromFavoriteIntent =
      PublishSubject<FavoriteItem>();
  final FavoriteList _favoriteList;

  StreamSubscription _loadingDataDisposable;

  List<String> favoriteItemId = List();

  _FindPlaceScreenContainerState(this._favoriteList);

  Future<FindPlacesParameter> _showSettingsDialog(
      BuildContext context, FindPlacesParameter parameter) {
    return showDialog(
        context: context,
        builder: (context) {
          return _UpdatableDialog(parameter);
        });
  }

  @override
  void dispose() {
    super.dispose();
    _loadMoreIntent.close();
    _addToFavoriteIntent.close();
    _removeFromFavoriteIntent.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find new place"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              MapHelper.getSavedFindPlacesParameter().listen((parameter) {
                Observable.fromFuture(_showSettingsDialog(context, parameter))
                    .listen((data) {
                  debugPrint("data: $data");
                  if (data != null) {
                    data.save().listen((result) {
                      Toast.show("Paremeters are saved", context);
                    });
                  }
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8),
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "place to find around...",
                contentPadding: EdgeInsets.only(left: 16.0, top: 12),
                alignLabelWithHint: true,
                prefixText:
                    "${_favoriteList.snapshot.data[FireStoreConstants.favoriteListName]}: ",
                suffixIcon: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.search,
                    size: 24,
                  ),
                  onPressed: () {
                    _loadData(_controller.text);
                  },
                )),
            controller: _controller,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
          ),
          Expanded(
            child: _FindPlacesScreenContainerBranch(
                _isLoading,
                _favoriteItemList,
                _loadMoreIntent,
                _nextPageToken,
                _isLoadingMore,
                _addToFavoriteIntent,
                _removeFromFavoriteIntent),
          )
        ],
      ),
    );
  }

  void _loadData(String keyword, {String pageToken}) {
    if (_loadingDataDisposable != null) {
      _loadingDataDisposable.cancel();
      _loadingDataDisposable = null;
    }
    _loadingDataDisposable =
        MapHelper.getSavedFindPlacesParameter().doOnListen(() {
      setState(() {
        if (pageToken == null) {
          _favoriteItemList.clear();
          _isLoading = true;
          _isLoadingMore = false;
        } else {
          _isLoadingMore = true;
          _isLoading = false;
        }
      });
    }).listen((data) {
      data.search(keyword: keyword, pageToken: pageToken).doOnData((response) {
        if (!response.isInvalid) {
          _nextPageToken = response.nextPageToken;
        }
      }).map((response) {
        var result = List<FavoriteItem>();
        if (!response.hasNoResults) {
          response.results.forEach((placesResult) {
            if (placesResult.types.contains(data.placeSearchType)) {
              result.add(FavoriteItem.fromPlacesSearchResult(
                  placesResult, favoriteItemId.contains(placesResult.placeId)));
            }
          });
        }
        return result;
      }).listen((data) {
        setState(() {
          _favoriteItemList.addAll(data);
          _isLoading = false;
          _isLoadingMore = false;
        });
      });
    });
  }

  void _preloadSavedDocuments() {
    if (_favoriteList != null) {
      Observable.fromFuture(_favoriteList.snapshot.reference
              .collection(FireStoreConstants.collectionFavoriteItem)
              .getDocuments())
          .doOnListen(() {
        favoriteItemId.clear();
      }).listen((snapshot) {
        if (snapshot != null) {
          snapshot.documents.forEach((data) {
            favoriteItemId.add(data.documentID);
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();

    _preloadSavedDocuments();
  }

  void _init() {
    _loadMoreIntent.listen((any) {
      _loadData(_controller.text, pageToken: _nextPageToken);
    });
    _addToFavoriteIntent.listen((item) {
      item.isFavorite = true;
      Observable.fromFuture(_favoriteList.snapshot.reference
              .collection(FireStoreConstants.collectionFavoriteItem)
              .document(item.placeId)
              .setData(item.toJson(), merge: true))
          .listen((snapshot) {
        debugPrint("add done, ${item.placeId}");

        setState(() {
          favoriteItemId.add(item.placeId);
        });
      });
    });
    _removeFromFavoriteIntent.listen((item) {
      Observable.fromFuture(_favoriteList.snapshot.reference
          .collection(FireStoreConstants.collectionFavoriteItem)
          .document(item.placeId)
          .delete())
          .listen((dynamic) {
        debugPrint("delete done, ${item.placeId}");

        setState(() {
          item.isFavorite = false;
          favoriteItemId.remove(item.placeId);
        });
      });
    });
  }
}

class _FindPlacesScreenContainerBranch extends StatelessWidget {
  final bool _isLoading;
  final List<FavoriteItem> _favoriteItemList;
  final PublishSubject<dynamic> _loadMoreIntent;
  final String _nextPageToken;
  final bool _isLoadingMore;
  final PublishSubject<FavoriteItem> _addToFavoriteIntent;
  final PublishSubject<FavoriteItem> _removeFromFavoriteIntent;

  _FindPlacesScreenContainerBranch(
      this._isLoading,
      this._favoriteItemList,
      this._loadMoreIntent,
      this._nextPageToken,
      this._isLoadingMore,
      this._addToFavoriteIntent,
      this._removeFromFavoriteIntent);

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _favoriteItemList.isEmpty) {
      return CircularProgressBar(text: "Request near by data...");
    } else if (_favoriteItemList.isNotEmpty) {
      return _FavoriteItemList(
          _favoriteItemList,
          _loadMoreIntent,
          _nextPageToken,
          _isLoadingMore,
          _addToFavoriteIntent,
          _removeFromFavoriteIntent);
    } else {
      return Center(
        child: Text("Empty result"),
      );
    }
  }
}

class _FavoriteItemList extends StatelessWidget {
  final List<FavoriteItem> _favoriteItemList;
  final PublishSubject<dynamic> _loadMoreIntent;
  final String _nextPageToken;
  final bool _isLoadingMore;
  final PublishSubject<FavoriteItem> _addToFavoriteIntent;
  final PublishSubject<FavoriteItem> _removeFromFavoriteIntent;

  _FavoriteItemList(
      this._favoriteItemList,
      this._loadMoreIntent,
      this._nextPageToken,
      this._isLoadingMore,
      this._addToFavoriteIntent,
      this._removeFromFavoriteIntent);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < _favoriteItemList.length) {
          return FavoriteItemRow(_favoriteItemList[index], _addToFavoriteIntent,
              _removeFromFavoriteIntent);
        } else {
          if (!_isLoadingMore) {
            return FlatButton(
              child: Text(
                "Load More",
                style: TextStyle(color: Color.fromARGB(0xff, 0x42, 0x85, 0xF4)),
              ),
              onPressed: () {
                _loadMoreIntent.add(Object());
              },
            );
          } else {
            return Center(
              child: Container(
                padding: EdgeInsets.all(8),
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            );
          }
        }
      },
      itemCount: _favoriteItemList.length + (_nextPageToken == null ? 0 : 1),
    );
  }
}
