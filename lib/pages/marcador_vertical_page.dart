import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/models/take_out.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarcadorVerticalPage extends StatefulWidget {
  final Marker marker;
  const MarcadorVerticalPage({super.key, required this.marker});

  @override
  State<MarcadorVerticalPage> createState() => _MarcadorVerticalPageState();
}

// hola
class _MarcadorVerticalPageState extends State<MarcadorVerticalPage> {
  String _player1Name = 'Jugador 1';
  String _player2Name = 'Jugador 2';
  TakeOut takeOut = TakeOut();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Cargar datos guardados
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _player1Name = prefs.getString('player1') ?? '';
      _player2Name = prefs.getString('player2') ?? '';
      widget.marker.targetPoints = prefs.getInt('points') ?? 7;
      widget.marker.targetSets = prefs.getInt('sets') ?? 1;
    });
  }

  void _checkWinCondition() {
    if (widget.marker.player1Score >= widget.marker.targetPoints &&
        widget.marker.player1Score >= widget.marker.player2Score + 2) {
      widget.marker.incrementSet(1);
      widget.marker.resetScores();
      _showSetWinnerDialog(_player1Name);
    } else if (widget.marker.player2Score >= widget.marker.targetPoints &&
        widget.marker.player2Score >= widget.marker.player1Score + 2) {
      widget.marker.incrementSet(2);
      _showSetWinnerDialog(_player2Name);
      widget.marker.resetScores();
    }

    if (widget.marker.player1Score >= (widget.marker.targetPoints - 1) &&
        widget.marker.player2Score >= (widget.marker.targetPoints - 1)) {
      takeOut.difference = true;
    }
  }

  void _undoTakeoOut() {
    if (widget.marker.player1Score <= widget.marker.targetPoints ||
        widget.marker.player2Score <= widget.marker.targetPoints) {
      takeOut.difference = false;
    }
    setState(() {
      takeOut.decremen();
    });
  }

  void _showSetWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Set para $winner!'),
          content: Text(
            'El set ha terminado, el marcador de sets es: ${widget.marker.player1Sets} - ${widget.marker.player2Sets}.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkMatchWinner();
                setState(() {
                  takeOut.reset();
                });
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _checkMatchWinner() {
    String? matchWinner;
    if (widget.marker.player1Sets == (widget.marker.targetSets - 1) / 2 + 1) {
      matchWinner = _player1Name;
    } else if (widget.marker.player2Sets ==
        (widget.marker.targetSets - 1) / 2 + 1) {
      matchWinner = _player2Name;
    }

    if (matchWinner != null) {
      setState(() {
        widget.marker.resetAll();
        takeOut.reset();
      });
      _showMatchWinnerDialog(matchWinner);
    }
  }

  void _showMatchWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Ganador del partido: $winner!'),
          content: Text('¡Felicidades, $winner ha ganado el partido!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Empezar de nuevo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PlayerGameArea(
                  takeOut: takeOut.player1,
                  playerName: _player1Name,
                  playerNumber: 1,
                  playerScore: widget.marker.player1Score,
                  backgroundColor: MyColors.secundary,
                  onIncrement: () {
                    setState(() {
                      !takeOut.player1 && !takeOut.player2
                          ? () {}
                          : widget.marker.incrementScore(1);
                      takeOut.incremen(1);
                      _checkWinCondition();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      widget.marker.decrementScore(1);
                      _undoTakeoOut();
                    });
                  },
                ),
              ),
              Expanded(
                child: PlayerGameArea(
                  takeOut: takeOut.player2,
                  playerName: _player2Name,
                  playerNumber: 2,
                  playerScore: widget.marker.player2Score,
                  backgroundColor: MyColors.primary,
                  onIncrement: () {
                    setState(() {
                      !takeOut.player1 && !takeOut.player2
                          ? () {}
                          : widget.marker.incrementScore(2);
                      takeOut.incremen(2);
                    });
                    _checkWinCondition();
                  },
                  onDecrement: () {
                    setState(() {
                      widget.marker.decrementScore(2);
                      _undoTakeoOut();
                    });
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: CenterButtons(
              onResetScores:
                  () => setState(() {
                    widget.marker.resetScores();
                    takeOut.reset();
                  }),
              onResetAll:
                  () => setState(() {
                    widget.marker.resetAll();
                    takeOut.reset();
                  }),
              onUndo: () {
                setState(() {
                  _undoTakeoOut();
                  widget.marker.scoreHistoryUndo();
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                color: MyColors.darkContraste,
                borderRadius: BorderRadius.circular(Spacing.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.marker.player1Sets}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      color: MyColors.secundary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${widget.marker.player2Sets}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      color: MyColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
