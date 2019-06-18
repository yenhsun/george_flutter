import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:json_annotation/json_annotation.dart';

import '../main.dart';

part 'model_favorite.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class FavoriteItem {
  String addedUserId;
  String placeId;
  String displayName;
  PriceLevel priceLevel;
  num rating;
  bool isFavorite = false;
  String address;
  List<String> photos = List<String>();

  double lat;
  double lng;
  bool permanentlyClosed;
  String scope;

  FavoriteItem();

  factory FavoriteItem.fromPlacesSearchResult(
      PlacesSearchResult result, bool isFavorite) {
    FavoriteItem item = FavoriteItem();
    item.displayName = result.name;
    item.placeId = result.placeId;
    item.priceLevel = result.priceLevel;
    item.rating = result.rating;
    item.address = result.vicinity;
    item.lat = result.geometry.location.lat;
    item.lng = result.geometry.location.lng;
    item.permanentlyClosed = result.permanentlyClosed;
    item.scope = result.scope;

    if (result.photos != null) {
      result.photos.forEach((photo) {
        item.photos.add(
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photo.photoReference}&key=$kGoogleApiKey");
      });
    }

    item.isFavorite = isFavorite;
    return item;
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteItemFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteItemToJson(this);
}
