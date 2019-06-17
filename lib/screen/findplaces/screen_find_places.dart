import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:george_flutter/model/model_favorite.dart';
import 'package:george_flutter/screen/sign_in/util/auth.dart';
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

class FindPlaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FindPlaceScreenContainer();
  }
}

class _FindPlaceScreenContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FindPlaceScreenContainerState();
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
                width: 100,
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
                width: 100,
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
  FavoriteList _favoriteList;

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
  }

  @override
  Widget build(BuildContext context) {
    _favoriteList = ModalRoute.of(context).settings.arguments;

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
                _isLoadingMore),
          )
        ],
      ),
    );
  }

  void _loadData(String keyword, {String pageToken}) {
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
      data.search(keyword: keyword, pageToken: pageToken).map((response) {
        var result = List<FavoriteItem>();
        if (!response.hasNoResults) {
          response.results.forEach((placesResult) {
            if (placesResult.types.contains(data.placeSearchType)) {
              result.add(FavoriteItem.fromPlacesSearchResult(placesResult));
            }
          });
        }
        debugPrint("response.isInvalid: ${response.isInvalid}");
        if (!response.isInvalid) {
          _nextPageToken = response.nextPageToken;
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

  @override
  void initState() {
    super.initState();
    _init();
//    _favoriteList.snapshot.reference.collection(FireStoreConstants.collectionFavoriteItem).getDocuments()
  }

  void _init() {
    _loadMoreIntent.listen((any) {
      _loadData(_controller.text, pageToken: _nextPageToken);
    });
  }
}

class _FindPlacesScreenContainerBranch extends StatelessWidget {
  final bool _isLoading;
  final List<FavoriteItem> _favoriteItemList;
  final PublishSubject<dynamic> _loadMoreIntent;
  final String _nextPageToken;
  final bool _isLoadingMore;

  _FindPlacesScreenContainerBranch(this._isLoading, this._favoriteItemList,
      this._loadMoreIntent, this._nextPageToken, this._isLoadingMore);

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _favoriteItemList.isEmpty) {
      return CircularProgressBar(text: "Request near by data...");
    } else if (_favoriteItemList.isNotEmpty) {
      return _FavoriteItemList(
          _favoriteItemList, _loadMoreIntent, _nextPageToken, _isLoadingMore);
    } else {
      return Center(
        child: Text("Empty result"),
      );
    }
  }
}

class _FavoriteItemRow extends StatelessWidget {
  final FavoriteItem _favoriteItem;

  _FavoriteItemRow(this._favoriteItem);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            _favoriteItem.displayName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              child: Text(
                                (_favoriteItem.address == null
                                    ? ""
                                    : _favoriteItem.address),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                      ),
                      Row(
                        children: <Widget>[
                          RatingWidget(_favoriteItem.rating),
                          PriceWidget(_favoriteItem.priceLevel),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider()
              ],
            ),
          ),
          Container(
            width: 48,
            height: 64,
            padding: EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(48),
              onTap: () {},
              child: Icon(
                Icons.star_border,
                color: Colors.amberAccent,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteItemList extends StatelessWidget {
  final List<FavoriteItem> _favoriteItemList;
  final PublishSubject<dynamic> _loadMoreIntent;
  final String _nextPageToken;
  final bool _isLoadingMore;

  _FavoriteItemList(this._favoriteItemList, this._loadMoreIntent,
      this._nextPageToken, this._isLoadingMore);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < _favoriteItemList.length) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8),
              ),
              _FavoriteItemRow(_favoriteItemList[index]),
              Padding(
                padding: EdgeInsets.only(top: 8),
              ),
            ],
          );
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
