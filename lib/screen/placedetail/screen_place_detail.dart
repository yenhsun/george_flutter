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
  static const double MIN_CONTAINER_HEIGHT = 150;
  static const double MAX_CONTAINER_HEIGHT = 600;
  Completer<GoogleMapController> _controller = Completer();
  final FavoriteItem _favoriteItem;
  bool _isLoading = false;
  PublishSubject<void> _moveMyLocationToCenterIntent = PublishSubject();
  Set<Marker> _markers = Set();
  double _containerHeight = MIN_CONTAINER_HEIGHT;

  _PlaceDetailScreenState(this._favoriteItem);

  @override
  Widget build(BuildContext context) {
    debugPrint("build, _markers size: ${_markers.length}");
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
                  _PlaceDetailBody(_isLoading, _favoriteItem),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> openHoursWidget = List();
    Map<num, Widget> openHoursMap = Map();

    _favoriteItem.openingHours.periods.forEach((period) {
      String day;
      if (period.day == 0) {
        day = "Sun";
      } else if (period.day == 1) {
        day = "Mon";
      } else if (period.day == 2) {
        day = "Tue";
      } else if (period.day == 3) {
        day = "Wed";
      } else if (period.day == 4) {
        day = "Thr";
      } else if (period.day == 5) {
        day = "Fri";
      } else if (period.day == 6) {
        day = "Sat";
      }
      openHoursMap[period.day] = Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 80),
          ),
          Expanded(
              child: Text(
            "$day     ${period.open} ~ ${period.close}",
            style: TextStyle(fontSize: 16),
          )),
        ],
      );
    });

    for (int day = 0; day < 7; ++day) {
      Widget dayWidget = openHoursMap[day];
      if (dayWidget == null) {
        String dayString;
        if (day == 0) {
          dayString = "Sun";
        } else if (day == 1) {
          dayString = "Mon";
        } else if (day == 2) {
          dayString = "Tue";
        } else if (day == 3) {
          dayString = "Wed";
        } else if (day == 4) {
          dayString = "Thr";
        } else if (day == 5) {
          dayString = "Fri";
        } else if (day == 6) {
          dayString = "Sat";
        }
        dayWidget = Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 80),
            ),
            Expanded(
                child: Text(
              "$dayString     Closed",
              style: TextStyle(fontSize: 16),
            )),
          ],
        );
      }
      openHoursWidget.add(dayWidget);
    }

    return Column(
      children: <Widget>[
        MaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            setState(() {
              if (_expandHeight == 0) {
                _expandHeight = 300;
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

  _PlaceInfoRow(this._text, this._icon, this._click);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: _click,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(_icon, color: Colors.blue),
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
            placeholder: Container(
              width: 100,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )),
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
