import 'package:google_maps_webservice/places.dart';

class FavoriteItem {
  String addedUserId;
  String placeId;
  String displayName;
  PriceLevel priceLevel;
  num rating;
  bool isFavorite;
  String address;
  List<Photo> photos;

  FavoriteItem();

  factory FavoriteItem.fromPlacesSearchResult(PlacesSearchResult result) {
    FavoriteItem item = FavoriteItem();
    item.displayName = result.name;
    item.placeId = result.placeId;
    item.priceLevel = result.priceLevel;
    item.rating = result.rating;
    item.address = result.formattedAddress;
    item.photos = result.photos;
    return item;
  }
}
