import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class PriceWidget extends StatelessWidget {
  final PriceLevel _priceLevel;

  PriceWidget(this._priceLevel);

  @override
  Widget build(BuildContext context) {
    final widgetList = List<Widget>();
    int count = 0;
    if (_priceLevel == PriceLevel.free) {
      count = 1;
    } else if (_priceLevel == PriceLevel.inexpensive) {
      count = 2;
    } else if (_priceLevel == PriceLevel.moderate) {
      count = 3;
    } else if (_priceLevel == PriceLevel.expensive) {
      count = 4;
    } else if (_priceLevel == PriceLevel.veryExpensive) {
      count = 5;
    }
    widgetList.add(Padding(padding: EdgeInsets.only(left: 20)));

    final double size = 12;
    for (int i = 0; i < count; ++i) {
      widgetList.add(Icon(
        Icons.attach_money,
        color: Colors.green,
        size: size,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgetList,
    );
  }
}
