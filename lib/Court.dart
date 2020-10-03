import 'package:flutter/material.dart';

import 'Player.dart';

class CourtSize extends InheritedWidget {
  final double courtSize;
  final Widget child;
  CourtSize({@required this.courtSize, this.child}) : super(child: child);

  @override
  bool updateShouldNotify(CourtSize old) => old.courtSize != courtSize;

  static double of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(CourtSize) as CourtSize)
        .courtSize;
  }
}

class Court extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double courtSide = CourtSize.of(context);

    var players = <Widget>[
      Player(0),
      Player(1),
      Player(2),
      Player(3),
      Player(4),
      Player(5),
    ];

    return Stack(
      children: <Widget>[
        Container(
          height: courtSide,
          width: courtSide,
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            border: Border.all(),
          ),
        ),
        Positioned(
          top: courtSide / 3,
          child: Container(
            height: 10,
            width: courtSide,
            color: Colors.white,
          ),
        ),
        ...players,
      ],
    );
  }
}
