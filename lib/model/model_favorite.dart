import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:json_annotation/json_annotation.dart';

import '../main.dart';

part 'model_favorite.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class OpeningHours {
  List<OpeningHoursPeriod> periods = List();

  OpeningHours();

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);

  Map<String, dynamic> toJson() => _$OpeningHoursToJson(this);
}

@JsonSerializable()
class OpeningHoursPeriod {
  String open;
  String close;
  int day;

  OpeningHoursPeriod(this.open, this.close, this.day);

  factory OpeningHoursPeriod.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$OpeningHoursPeriodToJson(this);
}

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

  String formattedPhoneNumber;
  String internationalPhoneNumber;
  String website;
  String url;

  OpeningHours openingHours;

  List<String> types = List();

  @JsonKey(ignore: true)
  List<Review> reviews;

  @JsonKey(ignore: true)
  bool openNow;

  FavoriteItem();

  void apply(PlaceDetails details) {
    if (this.types == null) {
      this.types = List();
    } else {
      this.types.clear();
    }
    this.types.addAll(details.types);
    this.formattedPhoneNumber = details.formattedPhoneNumber;
    this.internationalPhoneNumber = details.internationalPhoneNumber;
    this.website = details.website;
    this.url = details.url;

    this.openingHours = OpeningHours();
    details.openingHours.periods.forEach((period) {
      this.openingHours.periods.add(OpeningHoursPeriod(
          period.open.time, period.close.time, period.open.day));
    });
    this.openNow = details.openingHours.openNow;
    this.reviews = details.reviews;

    if (details.photos != null) {
      photos.clear();
      details.photos.forEach((photo) {
        photos.add(
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photo.photoReference}&key=$kGoogleApiKey");
      });
    }
  }

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
    item.openNow = result.openingHours.openNow;

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
