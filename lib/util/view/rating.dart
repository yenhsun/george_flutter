import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final num _rating;

  RatingWidget(this._rating);

  @override
  Widget build(BuildContext context) {
    var starData = List<IconData>();
    if (_rating <= 0) {
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating < 1) {
      starData.add(Icons.star_half);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating == 1) {
      starData.add(Icons.star);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating < 2) {
      starData.add(Icons.star);
      starData.add(Icons.star_half);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating == 2) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating < 3) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_half);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating == 3) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_border);
      starData.add(Icons.star_border);
    } else if (_rating < 4) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_half);
      starData.add(Icons.star_border);
    } else if (_rating == 4) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_border);
    } else if (_rating < 5) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star_half);
    } else if (_rating == 5) {
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
      starData.add(Icons.star);
    }
    final double size = 12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          starData[0],
          color: Colors.orangeAccent,
          size: size,
        ),
        Icon(
          starData[1],
          color: Colors.orangeAccent,
          size: size,
        ),
        Icon(
          starData[2],
          color: Colors.orangeAccent,
          size: size,
        ),
        Icon(
          starData[3],
          color: Colors.orangeAccent,
          size: size,
        ),
        Icon(
          starData[4],
          color: Colors.orangeAccent,
          size: size,
        ),
      ],
    );
  }
}
