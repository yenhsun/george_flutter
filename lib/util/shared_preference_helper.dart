import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static final String keyFindPlaceDistance = "keyFindPlaceDistance";
  static final String keyFindPlaceType = "keyFindPlaceType";
}

Observable<String> getString(String key, String defaultValue) {
  return Observable.fromFuture(SharedPreferences.getInstance())
      .map((preference) {
    final rtn = preference.getString(key);
    return rtn != null ? rtn : defaultValue;
  });
}

Observable<bool> putString(String key, String value) {
  return Observable.fromFuture(SharedPreferences.getInstance())
      .flatMap((preference) {
    return Observable.fromFuture(preference.setString(key, value));
  });
}
