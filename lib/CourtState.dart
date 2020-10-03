import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:volleyball_rotations/Rotation51.dart';

import 'Player.dart';

class CourtState with ChangeNotifier {
  static final frontRow = 1 / 4;
  static final backRow = 3 / 4;

  static final leftCol = 1 / 4;
  static final middleCol = 1 / 2;
  static final rightCol = 3 / 4;

  static final defaultPlayerStates = [
    PlayerState(Offset(rightCol, backRow), 0),
    PlayerState(Offset(rightCol, frontRow), 3),
    PlayerState(Offset(middleCol, frontRow), 2),
    PlayerState(Offset(leftCol, frontRow), 4),
    PlayerState(Offset(leftCol, backRow), 3),
    PlayerState(Offset(middleCol, backRow), 1),
  ];

  // Use a copy of the default player states as the initial state
  // Not using a copy would change the defaultPlayerState when changing the current one
  List<PlayerState> _playerStates =
      defaultPlayerStates.map((state) => state.copy()).toList();

  int rotationNumber = 0;
  bool checkingRotation = false;

  List<PlayerState> get playerStates => UnmodifiableListView(_playerStates);

  // TODO: Remove this function
  void adjustPlayerPosition(int id, Offset movementOffset) {
    _playerStates[id].position += movementOffset;
    notifyListeners();
  }

  void changePlayerType(int id) {
    _playerStates[id].playerType =
        (_playerStates[id].playerType + 1) % Player.positions.length;
    notifyListeners();
  }

  void rotateLeft() {
    // Update the rotation
    rotationNumber = (rotationNumber - 1) % 6;

    // Make an array of the player's position
    final playerPositions =
        _playerStates.map((playerState) => playerState.position).toList();

    // Rotate the array counter-clockwise
    final firstElement = playerPositions.removeAt(0);
    playerPositions.add(firstElement);

    // Set the new position
    _playerStates
        .asMap()
        .forEach((i, playerState) => playerState.position = playerPositions[i]);

    notifyListeners();
  }

  void rotateRight() {
    // Update the rotation
    rotationNumber = (rotationNumber + 1) % 6;

    // Make an array of the player's position
    final playerPositions =
        _playerStates.map((playerState) => playerState.position).toList();

    // Rotate the array clockwise
    final lastElement = playerPositions.removeLast();
    playerPositions.insert(0, lastElement);

    // Set the new position
    _playerStates
        .asMap()
        .forEach((i, playerState) => playerState.position = playerPositions[i]);

    notifyListeners();
  }

  void hidePlayer(int id) {
    _playerStates[id].visible = false;
    notifyListeners();
  }

  void showPlayer(int id) {
    _playerStates[id].visible = true;
    notifyListeners();
  }

  void adjustAndShow(int id, Offset movementOffset) {
    setAllPlayersInRotation();
    _playerStates[id].visible = true;

    final newPosition = _playerStates[id].position + movementOffset;

    if (newPosition.dx < 0 || newPosition.dx > 1) {
      notifyListeners();
      return;
    }

    if (newPosition.dy < 0 || newPosition.dy > 1) {
      notifyListeners();
      return;
    }

    _playerStates[id].shouldAnimate = false;
    _playerStates[id].position = newPosition;

    if (checkingRotation){
      checkRotation();
    }

    notifyListeners();
  }

  void animateAllPlayers() {
    _playerStates.forEach((playerState) => playerState.shouldAnimate = true);
  }

  void setAllPlayersInRotation(){
    _playerStates.forEach((playerState) => playerState.isInRotation = true);
  }

  void reset() {
    // Place the players on the court according to the current rotation
    _playerStates.asMap().forEach((i, playerState) {
      _playerStates[i].position =
          defaultPlayerStates[(i - rotationNumber) % 6].position;
    });

    notifyListeners();
  }

  void moveTo51() {
    _playerStates = Rotation51.rotations[rotationNumber]
        .map((pState) => pState.copy())
        .toList();
    notifyListeners();
  }

  int getPlayerIdForCourtPosition(int courtPosition) {
    // Returns the id of the player in the given courtPosition in the current rotation
    // 'courtPosition' can be 1, 2, 3, 4, 5 or 6

    // subtract 1 because court positions are not 0-indexed
    return (courtPosition - 1 + rotationNumber) % 6;
  }

  List<int> getOutOfRotationPlayersPositions() {
    final List<int> wrongPlayers = [];

    final p1 = _playerStates[getPlayerIdForCourtPosition(1)];
    final p2 = _playerStates[getPlayerIdForCourtPosition(2)];
    final p3 = _playerStates[getPlayerIdForCourtPosition(3)];
    final p4 = _playerStates[getPlayerIdForCourtPosition(4)];
    final p5 = _playerStates[getPlayerIdForCourtPosition(5)];
    final p6 = _playerStates[getPlayerIdForCourtPosition(6)];

    if (p1.isInFront(p2)) {
      wrongPlayers.addAll([1, 2]);
    }
    if (p6.isInFront(p3)) {
      wrongPlayers.addAll([6, 3]);
    }
    if (p5.isInFront(p4)) {
      wrongPlayers.addAll([5, 4]);
    }

    if (p4.isToTheRight(p3)) {
      wrongPlayers.addAll([4, 3]);
    }
    if (p3.isToTheRight(p2)) {
      wrongPlayers.addAll([3, 2]);
    }

    if (p5.isToTheRight(p6)) {
      wrongPlayers.addAll([5, 6]);
    }
    if (p6.isToTheRight(p1)) {
      wrongPlayers.addAll([6, 1]);
    }

    return wrongPlayers;
  }

  bool isInRotation() => getOutOfRotationPlayersPositions().isEmpty;

  void checkRotation() {

    final badPlayers = getOutOfRotationPlayersPositions();

    if (badPlayers.isEmpty){return;}

    badPlayers.map(getPlayerIdForCourtPosition).forEach((id){
      _playerStates[id].isInRotation = false;
    });

  }

  void startCheckingRotation() {
    checkingRotation = true;
    checkRotation();
    notifyListeners();
  }

  void stopCheckingRotation() {
    checkingRotation = false;
    setAllPlayersInRotation();
    notifyListeners();
  }
}
