import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'Court.dart';
import 'CourtState.dart';
import 'TransparentCanvas.dart';

void main() {
  // TODO: Use provider for the transparent canvas
  // TODO: Make a TransparentCourt class that provides a CourtState and a future 'CanvasState'
  // TODO: Make a class for 'CourtButton'
  // (And prevent the buttons from rebuilding in the process)

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  SystemChrome.setEnabledSystemUIOverlays([]).then((_) => runApp(App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Rotations',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
      body: CourtSize(
        courtSize: data.size.height,
        child: ChangeNotifierProvider<CourtState>(
          builder: (_) => CourtState(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TransparentCanvas(
                points: points,
                child: Court(),
                onNewPoint: (Offset point) {
                  setState(() {
                    points.add(point);
                  });
                },
                onLineEnd: () {
                  points.add(null);
                },
              ),

              // BUTTONS
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Clear button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        points.clear();
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),

                  // Rotate right button
                  Consumer<CourtState>(
                    // TODO: Have this guy not rebuild on state changes
                    builder: (_, courtState, __) => IconButton(
                      icon: Icon(Icons.rotate_right),
                      onPressed: () {
                        courtState.animateAllPlayers();
                        courtState.rotateRight();
                      },
                    ),
                  ),

                  // Rotate left button
                  Consumer<CourtState>(
                    // TODO: Have this guy not rebuild on state changes too
                    builder: (_, courtState, __) => IconButton(
                      icon: Icon(Icons.rotate_left),
                      onPressed: () {
                        courtState.animateAllPlayers();
                        courtState.rotateLeft();
                      },
                    ),
                  ),

                  // Reset button
                  Consumer<CourtState>(
                    // TODO: Have this guy not rebuild on state changes as well
                    builder: (_, courtState, __) => IconButton(
                      icon: Icon(Icons.settings_backup_restore),
                      onPressed: () {
                        courtState.animateAllPlayers();
                        courtState.reset();
                      },
                    ),
                  ),

                  // 5-1 button
                  Consumer<CourtState>(
                    // TODO: Have this guy not rebuild on state changes once more
                    builder: (_, courtState, __) => IconButton(
                      icon: Icon(Icons.slideshow),
                      onPressed: () {
                        courtState.animateAllPlayers();
                        courtState.moveTo51();
                      },
                    ),
                  ),

                  // Check rotation button
                  Selector<CourtState, bool>(
                    selector: (context, courtState) =>
                        courtState.checkingRotation,

                    builder: (buildContext, checkingRotation, __) => IconButton(
                      icon: checkingRotation
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                      onPressed: () {
                        final courtState =
                            Provider.of<CourtState>(buildContext, listen: false);

                        checkingRotation
                            ? courtState.stopCheckingRotation()
                            : courtState.startCheckingRotation();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
