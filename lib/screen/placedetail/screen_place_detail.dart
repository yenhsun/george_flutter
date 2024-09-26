import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:toast/toast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  static const KEY_FAVORITE_LIST = "KEY_FAVORITE_LIST";
  static const KEY_FAVORITE_ITEM = "KEY_FAVORITE_ITEM";

  @override
  Widget build(BuildContext context) {
    Map<String, Object> map = ModalRoute.of(context).settings.arguments;
    FavoriteItem item = map[KEY_FAVORITE_ITEM];
    FavoriteList list = map[KEY_FAVORITE_LIST];
    return _PlaceDetailScreenContainer(item, list);
  }
}

class _PlaceDetailScreenContainer extends StatefulWidget {
  final FavoriteItem _favoriteItem;
  final FavoriteList _favoriteList;

  _PlaceDetailScreenContainer(this._favoriteItem, this._favoriteList);

  @override
  State<StatefulWidget> createState() {
    return _PlaceDetailScreenState(_favoriteItem, _favoriteList);
  }
}

class _IsFavoriteContainer extends StatefulWidget {
  final FavoriteItem _favoriteItem;
  final FavoriteList _favoriteList;

  _IsFavoriteContainer(this._favoriteItem, this._favoriteList);

  @override
  State<StatefulWidget> createState() {
    return _IsFavoriteState(_favoriteItem, _favoriteList);
  }
}

class _IsFavoriteState extends State<_IsFavoriteContainer> {
  final FavoriteItem _favoriteItem;
  final FavoriteList _favoriteList;

  _IsFavoriteState(this._favoriteItem, this._favoriteList);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        _PlaceInfoRow(_favoriteItem.isFavorite ? "Favorite" : "add to Favorite",
            _favoriteItem.isFavorite ? Icons.star : Icons.star_border, () {
          debugPrint("${_favoriteList.snapshot.reference.path}");
          if (_favoriteItem.isFavorite) {
            removeFavoriteItem(_favoriteList, _favoriteItem).listen((data) {
              setState(() {
                _favoriteItem.isFavorite = false;
              });
            });
          } else {
            addNewFavoriteItem(_favoriteList, _favoriteItem).listen((data) {
              setState(() {
                _favoriteItem.isFavorite = true;
              });
            });
          }
        }, color: Colors.amber),
      ],
    );
  }
}

class _PlaceDetailScreenState extends State<_PlaceDetailScreenContainer> {
  static const double MIN_CONTAINER_HEIGHT = 150;
  static const double MAX_CONTAINER_HEIGHT = 460;
  Completer<GoogleMapController> _controller = Completer();
  final FavoriteItem _favoriteItem;
  final FavoriteList _favoriteList;
  bool _isLoading = false;
  PublishSubject<void> _moveMyLocationToCenterIntent = PublishSubject();
  Set<Marker> _markers = Set();
  double _containerHeight = MIN_CONTAINER_HEIGHT;

  _PlaceDetailScreenState(this._favoriteItem, this._favoriteList);

  @override
  Widget build(BuildContext context) {
    debugPrint("build, _markers size: ${_markers.length}");
    debugPrint("_favoriteItem, ${_favoriteItem.isFavorite}");
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
            child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
              target: LatLng(_favoriteItem.lat, _favoriteItem.lng), zoom: 16.0),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _markers,
        )),
        _MyLocationButton(_moveMyLocationToCenterIntent),
        Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              color: Colors.white,
              height: _containerHeight,
              duration: Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _containerHeight =
                                  _containerHeight > MIN_CONTAINER_HEIGHT
                                      ? MIN_CONTAINER_HEIGHT
                                      : MAX_CONTAINER_HEIGHT;
                            });
                          },
                          child: Icon((_containerHeight == MAX_CONTAINER_HEIGHT
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up)),
                        ),
                      )
                    ],
                  ),
                  _PlaceDetailBody(_isLoading, _favoriteItem, _favoriteList),
                ],
              ),
            )),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();

    MapHelper.getPlaceDetail(_favoriteItem.placeId).doOnListen(() {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(_favoriteItem.placeId),
          position: LatLng(_favoriteItem.lat, _favoriteItem.lng),
          infoWindow: InfoWindow(title: _favoriteItem.displayName),
        ));
        _isLoading = true;
      });
    }).listen((detailResponse) {
      _favoriteItem.apply(detailResponse.result);
    }, onDone: () {
      setState(() {
        _isLoading = false;
      });
    });

    _moveMyLocationToCenterIntent.listen((dynamic) {
      MapHelper.getUserLocation().listen((latLng) {
        Observable.fromFuture(_controller.future).listen((data) {
          data.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 16.0)));
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _moveMyLocationToCenterIntent.close();
  }
}

class _PlaceDetailBody extends StatelessWidget {
  final FavoriteItem _favoriteItem;
  final FavoriteList _favoriteList;
  final bool _isLoading;

  _PlaceDetailBody(this._isLoading, this._favoriteItem, this._favoriteList);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: CircularProgressBar(
            text: "Loading ${_favoriteItem.displayName} information...",
          ),
        ),
      );
    } else {
      return Expanded(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: _PlaceImageList(_favoriteItem.photos),
                      ),
                      _IsFavoriteContainer(_favoriteItem, _favoriteList),
                      _PlaceDetails(_favoriteItem),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _Reviews extends StatefulWidget {
  final FavoriteItem _favoriteItem;

  _Reviews(this._favoriteItem);

  @override
  State<StatefulWidget> createState() {
    return _ReviewsState(_favoriteItem);
  }
}

class _ReviewsState extends State<_Reviews> {
  final FavoriteItem _favoriteItem;
  double _expandHeight = 0;

  _ReviewsState(this._favoriteItem);

  List<Widget> reviewWidgets = List();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            setState(() {
              if (_expandHeight == 0) {
                _expandHeight = 200;
              } else {
                _expandHeight = 0;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.textsms, color: Colors.blue),
              Padding(padding: EdgeInsets.only(left: 40)),
              Flexible(
                child: Text(
                  "Review",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(_expandHeight == 0
                  ? Icons.arrow_drop_down
                  : Icons.arrow_drop_up)
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: _expandHeight,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Divider(),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                      ),
                      Flexible(
                        child: Text(
                          "${_favoriteItem.reviews[index].text}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                      ),
                    ],
                  ),
                ],
              );
            },
            itemCount: _favoriteItem.reviews.length,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint("size: ${_favoriteItem.reviews.length}");

    _favoriteItem.reviews.forEach((review) {
      reviewWidgets.add(Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16),
          ),
          Flexible(
            child: Text(
              "${review.text}",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
          ),
        ],
      ));
      reviewWidgets.add(Divider());
    });
    reviewWidgets.add(Padding(padding: EdgeInsets.only(bottom: 60)));
  }
}

class _PlaceDetails extends StatelessWidget {
  final FavoriteItem _favoriteItem;

  _PlaceDetails(this._favoriteItem);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        _PlaceInfoRow(_favoriteItem.address, Icons.place, () {}),
        Divider(),
        _PlaceInfoRow(_favoriteItem.internationalPhoneNumber, Icons.dialpad,
            () {
          launch("tel://${_favoriteItem.internationalPhoneNumber}");
        }),
        Divider(),
        _PlaceInfoRow(_favoriteItem.website, Icons.language, () {
          launch("${_favoriteItem.website}");
        }),
        Divider(),
        _OpeningHours(_favoriteItem),
        Divider(),
        _Reviews(_favoriteItem),
      ],
    );
  }
}

class _OpeningHours extends StatefulWidget {
  final FavoriteItem _favoriteItem;

  _OpeningHours(this._favoriteItem);

  @override
  State<StatefulWidget> createState() {
    return _OpeningHoursState(_favoriteItem);
  }
}

class _OpeningHoursState extends State<_OpeningHours> {
  final FavoriteItem _favoriteItem;
  double _expandHeight = 0;

  _OpeningHoursState(this._favoriteItem);

  String getWeekDayString(num day) {
    if (day == 0) {
      return "Sun";
    } else if (day == 1) {
      return "Mon";
    } else if (day == 2) {
      return "Tue";
    } else if (day == 3) {
      return "Wed";
    } else if (day == 4) {
      return "Thr";
    } else if (day == 5) {
      return "Fri";
    } else if (day == 6) {
      return "Sat";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> openHoursWidget = List();
    Map<num, Widget> openHoursMap = Map();

    _favoriteItem.openingHours.periods.forEach((period) {
      String day = getWeekDayString(period.day);
      openHoursMap[period.day] = Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 80),
          ),
          Container(
              width: 60,
              child: Text(
                "$day",
                style: TextStyle(fontSize: 16),
              )),
          Flexible(
            child: Text(
              "${period.open} ~ ${period.close}",
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      );
    });

    for (int day = 0; day < 7; ++day) {
      Widget dayWidget = openHoursMap[day];
      if (dayWidget == null) {
        String dayString = getWeekDayString(day);
        dayWidget = Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 80),
            ),
            Container(
                width: 60,
                child: Text(
                  "$dayString",
                  style: TextStyle(fontSize: 16),
                )),
            Flexible(
              child: Text(
                "Closed",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      }
      openHoursWidget.add(dayWidget);
      if (day < 6) {
        openHoursWidget.add(Divider());
      }
    }

    return Column(
      children: <Widget>[
        MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            setState(() {
              if (_expandHeight == 0) {
                _expandHeight = 250;
              } else {
                _expandHeight = 0;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.access_time, color: Colors.blue),
              Padding(padding: EdgeInsets.only(left: 40)),
              Flexible(
                child: Text(
                  _favoriteItem.openNow ? "Open Now" : "Closed",
                  style: TextStyle(
                      fontSize: 16,
                      color: _favoriteItem.openNow ? Colors.black : Colors.red),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(_expandHeight == 0
                  ? Icons.arrow_drop_down
                  : Icons.arrow_drop_up)
            ],
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: _expandHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: openHoursWidget,
          ),
        )
      ],
    );
  }
}

class _PlaceInfoRow extends StatelessWidget {
  final String _text;
  final IconData _icon;
  final Function _click;
  final Color color;

  _PlaceInfoRow(this._text, this._icon, this._click,
      {this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: _click,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(_icon, color: color),
          Padding(padding: EdgeInsets.only(left: 40)),
          Flexible(
            child: Text(
              _text,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceImageList extends StatelessWidget {
  final List<String> _photos;

  _PlaceImageList(this._photos);

  @override
  Widget build(BuildContext context) {
    List<Widget> placeImages = List();
    _photos.forEach((url) {
      placeImages.add(
        CachedNetworkImage(
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          imageUrl: url,
          placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        ),
      );
    });

    return ListView(
      scrollDirection: Axis.horizontal,
      children: placeImages,
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  final PublishSubject<void> _moveMyLocationToCenterIntent;

  _MyLocationButton(this._moveMyLocationToCenterIntent);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: RawMaterialButton(
            onPressed: () {
              _moveMyLocationToCenterIntent.add(Object());
            },
            child: Icon(
              Icons.location_searching,
              color: Colors.blue,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: EdgeInsets.all(5.0),
          ),
        ));
  }
}
