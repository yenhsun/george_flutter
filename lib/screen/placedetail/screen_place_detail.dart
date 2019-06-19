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
    // TODO: implement build
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                ),
              ),
              Icon(
                Icons.phone,
                color: Colors.blue,
              ),
              Padding(
                padding: EdgeInsets.only(left: 40),
              ),
              Flexible(
                child: Text(
                  _favoriteItem.internationalPhoneNumber,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text("123"),
        Text("123"),
        Text("123"),
      ],
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
