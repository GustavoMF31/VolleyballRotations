import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volleyball_rotations/CourtState.dart';

import 'Court.dart';
import 'PlayerPosition.dart';

class Player extends StatelessWidget {
  static final positions = [
    PlayerPosition(Colors.blue, "L"), // Setter
    PlayerPosition(Colors.red[500], "Li"), // Libero
    PlayerPosition(Colors.green[500], "M"), // Middle
    PlayerPosition(Colors.yellowAccent, "P"), // Outside Hitter
    PlayerPosition(Colors.black, "O", Colors.white) // Opposite
  ];

  final int id;
  Player(this.id);

  @override
  Widget build(BuildContext context) {
    final double courtSize = CourtSize.of(context);
    final double playerRadius = courtSize * 1 / 14;

    return Consumer<CourtState>(
      builder: (buildContext, courtState, _) {
        final state = courtState.playerStates[id];

        final position = state.position;
        final playerType = state.playerType;
        final visible = state.visible;

        return AnimatedPositioned(
          duration: Duration(seconds: state.shouldAnimate ? 1 : 0),
          curve: Curves.fastLinearToSlowEaseIn,
          left: position.dx * courtSize - playerRadius,
          top: position.dy * courtSize - playerRadius,
          child: GestureDetector(
            child: Draggable(
              child: visible
                  ? PlayerIcon(
                      position: Player.positions[playerType],
                      playerRadius: playerRadius,
                      withError: !state.isInRotation,
                    )
                  : Container(),
              feedback: PlayerIcon(
                position: Player.positions[playerType],
                playerRadius: playerRadius,
                withError: !state.isInRotation,
              ),
              onDraggableCanceled: (velocity, offset) {
                final adjustedOffset = (context.findRenderObject() as RenderBox)
                        .globalToLocal(offset) /
                    courtSize;

                courtState.adjustAndShow(id, adjustedOffset);
              },
              onDragStarted: () {
                courtState.hidePlayer(id);
              },
            ),
            onTap: () {
              courtState.changePlayerType(id);
            },
          ),
        );
      },
    );
  }
}

class PlayerState {
  Offset position;
  int playerType; // Index to [Player.positions]. Means Setter / Libero / Middle, etc
  bool visible;
  bool shouldAnimate;
  bool isInRotation; // Is correctly placed in the court according to the current rotation

  PlayerState(this.position, this.playerType,
      [this.visible = true,
      this.shouldAnimate = true,
      this.isInRotation = true]);

  PlayerState copy() {
    return PlayerState(position = position, playerType = playerType,
        visible = visible, shouldAnimate = shouldAnimate);
  }

  bool isBehind(PlayerState other) => position.dy > other.position.dy;
  bool isInFront(PlayerState other) => position.dy < other.position.dy;
  bool isToTheLeft(PlayerState other) => position.dx < other.position.dx;
  bool isToTheRight(PlayerState other) => position.dx > other.position.dx;

  String toString() {
    return "PlayerState(Offset(${position.dx}, ${position.dy}), $playerType)";
  }
}

class PlayerIcon extends StatelessWidget {
  final PlayerPosition position;
  final double playerRadius;
  final bool withError;

  const PlayerIcon({
    @required this.position,
    @required this.playerRadius,
    @required this.withError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Text(
        position.nameCode,

        // Setting inherit to false prevents the text from changing when being dragged
        style:
            TextStyle(fontSize: 30, color: position.textColor, inherit: false),
      )),
      height: playerRadius * 2,
      width: playerRadius * 2,
      decoration: BoxDecoration(
        color: position.color,
        shape: BoxShape.circle,
        border: withError ? Border.all(color: Colors.red[700], width: 5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(-2, 2),
            blurRadius: 5,
          )
        ],
      ),
    );
  }
}
