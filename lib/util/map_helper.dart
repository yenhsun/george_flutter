import 'dart:async';
import 'dart:io';
import 'package:george_flutter/model/model_favorite.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:rxdart/rxdart.dart';
import 'package:george_flutter/util/shared_preference_helper.dart'
    as SharedPreferenceHelper;

import '../main.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

Observable<LatLng> getUserLocation() {
  return Observable.fromFuture(LocationManager.Location().getLocation())
      .map((data) {
    final lat = data["latitude"];
    final lng = data["longitude"];
    debugPrint("lat: $lat, lng: $lng");
    final center = LatLng(lat, lng);
    return center;
  }).onErrorReturn(LatLng(0, 0));
}

Observable<PlacesSearchResponse> findNearBy(LatLng center,
    {int radius = 2000,
    String type,
    String pageToken,
    String keyword,
    String language = "zh-tw"}) {
  return Observable.fromFuture(_places.searchNearbyWithRadius(
      Location(center.latitude, center.longitude), radius,
      type: type, pagetoken: pageToken, language: language, keyword: keyword));
}

class FindPlacesParameter {
  static const String TYPE_RESTAURANT = "Restaurant";
  static const String TYPE_FOOD = "Food";
  static const String TYPE_STORE = "Store";
  static const String TYPE_DELIVERY = "Delivery";
  static const String TYPE_TAKE_AWAY = "Take away";
  static const String TYPE_CAFE = "Cafe";

  static const String DISTANCE_NONE = "None";

  String distance;
  String type;
  String placeSearchType;

  FindPlacesParameter(this.distance, this.type);

  Observable<bool> save() {
    return Observable.zip2(
        SharedPreferenceHelper.putString(
            SharedPreferenceHelper.Constants.keyFindPlaceDistance, distance),
        SharedPreferenceHelper.putString(
            SharedPreferenceHelper.Constants.keyFindPlaceType, type),
        (success1, success2) {
      return success1 && success2;
    });
  }

  Observable<PlacesSearchResponse> search(
      {String pageToken, String keyword, String language = "zh-tw"}) {
    var radius = distance == DISTANCE_NONE ? 5000 : int.parse(distance);
    return getUserLocation().flatMap((latLng) {
      if (type == TYPE_FOOD) {
        placeSearchType = "food";
      } else if (type == TYPE_RESTAURANT) {
        placeSearchType = "restaurant";
      } else if (type == TYPE_DELIVERY) {
        placeSearchType = "meal_delivery";
      } else if (type == TYPE_TAKE_AWAY) {
        placeSearchType = "meal_takeaway";
      } else if (type == TYPE_STORE) {
        placeSearchType = "store";
      } else if (type == TYPE_CAFE) {
        placeSearchType = "cafe";
      }
      return findNearBy(latLng,
          radius: radius,
          type: placeSearchType,
          pageToken: pageToken,
          language: language,
          keyword: keyword);
    });
  }
}

Observable<FindPlacesParameter> getSavedFindPlacesParameter() {
  return Observable.zip2(
      SharedPreferenceHelper.getString(
          SharedPreferenceHelper.Constants.keyFindPlaceDistance, "1000"),
      SharedPreferenceHelper.getString(
          SharedPreferenceHelper.Constants.keyFindPlaceType,
          FindPlacesParameter.TYPE_RESTAURANT), (distance, type) {
    return FindPlacesParameter(distance, type);
  });
}

Observable<PlacesDetailsResponse> getPlaceDetail(String placeId,
    {String language = "zh-tw"}) {
  return Observable.fromFuture(
      _places.getDetailsByPlaceId(placeId, language: language));
}
