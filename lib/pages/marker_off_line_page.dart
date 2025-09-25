import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';

class MarkerOffLinePage extends StatefulWidget {
  const MarkerOffLinePage({super.key});

  @override
  State<MarkerOffLinePage> createState() => _MarkerOffLinePageState();
}

class _MarkerOffLinePageState extends State<MarkerOffLinePage> {
  Marker marker = Marker();
  String player1Name = 'Player1';
  String player2Name = 'Player2';
  bool swap = true;

  get prefs => null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    marker.targetPoints = 7;
    marker.targetSets = 1;
    // setState(() {
    //   player1Name = prefs.getString('player1') ?? 'Player1';
    //   player2Name = prefs.getString('player2') ?? 'Player2';
    //   marker.targetPoints = prefs.getInt('points') ?? 7;
    //   marker.targetSets = prefs.getInt('sets') ?? 1;
    // });
    // marker.targetSets = 3;
    // marker.targetPoints = 11;
  }

  void _showMatchWinnerDialog(String winner) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Ganador del partido: $winner!'),
          content: Text('¡Felicidades, $winner ha ganado el partido!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo de ganador
              },
              child: const Text('Cargar partido'),
            ),
          ],
        );
      },
    );
  }

  void _checkWinCondition() {
    int jugarWin = marker.checkMatchWinner();

    if (marker.checkWinSetCondition()) {
      marker.resetScores();
    }

    if (marker.checkWinSetCondition() || jugarWin == 0) {
      setState(() {
        swap = !swap;
      });
    }

    if (jugarWin != 0) {
      if (jugarWin == 1) {
        _showMatchWinnerDialog(player1Name);
      } else {
        _showMatchWinnerDialog(player2Name);
      }
      marker.resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // reescribimos los paddings a cero
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
      ),
      child: Scaffold(
        appBar: null,
        body: Stack(
          children: [
            Flex(
              direction: Axis.horizontal,
              textDirection: swap ? TextDirection.ltr : TextDirection.rtl, //
              children: [
                Expanded(
                  child: PlayerGameArea(
                    isTournament: false,
                    takeOut: marker.playerTurn == 1,
                    playerName: player1Name,
                    playerNumber: 1,
                    playerScore: marker.player1Score,
                    backgroundColor: MyColors.secundary,
                    onIncrement: () {
                      setState(() {
                        marker.incrementScore(1);
                        _checkWinCondition();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: PlayerGameArea(
                    isTournament: false,
                    takeOut: marker.playerTurn == 2,
                    playerName: player2Name,
                    playerNumber: 2,
                    playerScore: marker.player2Score,
                    backgroundColor: MyColors.primary,
                    onIncrement: () {
                      setState(() {
                        marker.incrementScore(2);
                      });
                      _checkWinCondition();
                    },
                  ),
                ),
              ],
            ),
            Flex(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.vertical,
              children: [
                SetsPoints(
                  player1Sets: marker.player1Sets,
                  player2Sets: marker.player2Sets,
                ),
                CenterButtons(
                  onResetScores:
                      () => setState(() {
                        marker.resetScores();
                      }),
                  onResetAll:
                      () => setState(() {
                        marker.resetAll();
                      }),
                  onUndo: () {
                    setState(() {
                      marker.scoreHistoryUndo();
                    });
                  },
                  onSwap: () {
                    setState(() {
                      swap = !swap;
                    });
                  },
                  onEvent: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.settings);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
