import 'package:flutter/material.dart';
import 'package:george_flutter/model/model_favorite.dart';
import 'package:george_flutter/util/view/price.dart';
import 'package:george_flutter/util/view/rating.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteItemRow extends StatelessWidget {
  final FavoriteItem _favoriteItem;
  final PublishSubject<FavoriteItem> _addToFavoriteIntent;
  final PublishSubject<FavoriteItem> _removeFromFavoriteIntent;

  FavoriteItemRow(this._favoriteItem, this._addToFavoriteIntent,
      this._removeFromFavoriteIntent);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                _favoriteItem.displayName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  child: Text(
                                    (_favoriteItem.address == null
                                        ? ""
                                        : _favoriteItem.address),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                          ),
                          Row(
                            children: <Widget>[
                              RatingWidget(_favoriteItem.rating),
                              PriceWidget(_favoriteItem.priceLevel),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 64,
                padding: EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(48),
                  onTap: () {
                    if (_favoriteItem.isFavorite) {
                      _removeFromFavoriteIntent.add(_favoriteItem);
                    } else {
                      _addToFavoriteIntent.add(_favoriteItem);
                    }
                  },
                  child: Icon(
                    (_favoriteItem.isFavorite ? Icons.star : Icons.star_border),
                    color: Colors.amberAccent,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
        ),
      ],
    );
  }
}
