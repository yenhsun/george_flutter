import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model_favorite.g.dart';

// flutter pub run build_runner build

@JsonSerializable()
class FavoriteItem {
  String addedUserId;
  String placeId;
  String displayName;
  PriceLevel priceLevel;
  num rating;
  bool isFavorite = false;
  String address;

  FavoriteItem();

  factory FavoriteItem.fromPlacesSearchResult(
      PlacesSearchResult result, bool isFavorite) {
    FavoriteItem item = FavoriteItem();
    item.displayName = result.name;
    item.placeId = result.placeId;
    item.priceLevel = result.priceLevel;
    item.rating = result.rating;
    item.address = result.vicinity;
    item.isFavorite = isFavorite;
//    debugPrint("-----${result.name}-----");
//    result.types.forEach((data){
//      debugPrint("type: $data");
//    });
    return item;
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => _$FavoriteItemFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteItemToJson(this);
}
