// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteItem _$FavoriteItemFromJson(Map<String, dynamic> json) {
  return FavoriteItem()
    ..addedUserId = json['addedUserId'] as String
    ..placeId = json['placeId'] as String
    ..displayName = json['displayName'] as String
    ..priceLevel = _$enumDecodeNullable(_$PriceLevelEnumMap, json['priceLevel'])
    ..rating = json['rating'] as num
    ..isFavorite = json['isFavorite'] as bool
    ..address = json['address'] as String
    ..photos = (json['photos'] as List)?.map((e) => e as String)?.toList()
    ..lat = (json['lat'] as num)?.toDouble()
    ..lng = (json['lng'] as num)?.toDouble()
    ..permanentlyClosed = json['permanentlyClosed'] as bool
    ..scope = json['scope'] as String;
}

Map<String, dynamic> _$FavoriteItemToJson(FavoriteItem instance) =>
    <String, dynamic>{
      'addedUserId': instance.addedUserId,
      'placeId': instance.placeId,
      'displayName': instance.displayName,
      'priceLevel': _$PriceLevelEnumMap[instance.priceLevel],
      'rating': instance.rating,
      'isFavorite': instance.isFavorite,
      'address': instance.address,
      'photos': instance.photos,
      'lat': instance.lat,
      'lng': instance.lng,
      'permanentlyClosed': instance.permanentlyClosed,
      'scope': instance.scope
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$PriceLevelEnumMap = <PriceLevel, dynamic>{
  PriceLevel.free: 'free',
  PriceLevel.inexpensive: 'inexpensive',
  PriceLevel.moderate: 'moderate',
  PriceLevel.expensive: 'expensive',
  PriceLevel.veryExpensive: 'veryExpensive'
};
