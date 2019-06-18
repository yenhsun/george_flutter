// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) {
  return OpeningHours()
    ..periods = (json['periods'] as List)
        ?.map((e) => e == null
            ? null
            : OpeningHoursPeriod.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{'periods': instance.periods};

OpeningHoursPeriod _$OpeningHoursPeriodFromJson(Map<String, dynamic> json) {
  return OpeningHoursPeriod(
      json['open'] as String, json['close'] as String, json['day'] as int);
}

Map<String, dynamic> _$OpeningHoursPeriodToJson(OpeningHoursPeriod instance) =>
    <String, dynamic>{
      'open': instance.open,
      'close': instance.close,
      'day': instance.day
    };

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
    ..scope = json['scope'] as String
    ..formattedPhoneNumber = json['formattedPhoneNumber'] as String
    ..internationalPhoneNumber = json['internationalPhoneNumber'] as String
    ..website = json['website'] as String
    ..url = json['url'] as String
    ..openingHours = json['openingHours'] == null
        ? null
        : OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>)
    ..types = (json['types'] as List)?.map((e) => e as String)?.toList();
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
      'scope': instance.scope,
      'formattedPhoneNumber': instance.formattedPhoneNumber,
      'internationalPhoneNumber': instance.internationalPhoneNumber,
      'website': instance.website,
      'url': instance.url,
      'openingHours': instance.openingHours,
      'types': instance.types
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
