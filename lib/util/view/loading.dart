import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  final String text;

  CircularProgressBar({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 16)),
        Text(text),
      ],
    );
  }
}
