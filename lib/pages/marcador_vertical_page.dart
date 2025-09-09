import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/services/marcador.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarcadorVerticalPage extends StatefulWidget {
  const MarcadorVerticalPage({super.key});

  @override
  State<MarcadorVerticalPage> createState() => _MarcadorVerticalPageState();
}

// hola
class _MarcadorVerticalPageState extends State<MarcadorVerticalPage> {
  String _player1Name = 'Jugador 1';
  String _player2Name = 'Jugador 2';
  Marcador marcador = Marcador();

  // _scoreHistoryUndo() {
  //   if (_scoreHistory.isNotEmpty) {
  //     int lastScore = _scoreHistory.removeLast();
  //     if (lastScore == 1 && _player1Score > 0) {
  //       _player1Score--;
  //     } else if (lastScore == 2 && _player2Score > 0) {
  //       _player2Score--;
  //     }

  //     if (lastScore == -1 && _player1Score < _targetPoints) {
  //       _player1Score++;
  //     } else if (lastScore == -2 && _player2Score < _targetPoints) {
  //       _player2Score++;
  //     }
  //   }
  // }

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
      marcador.targetPoints = prefs.getInt('points') ?? 7;
      marcador.targetSets = prefs.getInt('sets') ?? 1;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Forzar la orientación de la pantalla a horizontal al entrar
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);
  // }

  // @override
  // void dispose() {
  //   // Volver a la orientación vertical por defecto al salir
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  //   super.dispose();
  // }

  // void incrementScore(int player) {
  //   setState(() {
  //     if (player == 1) {
  //       _player1Score++;
  //     } else {
  //       _player2Score++;
  //     }
  //     _scoreHistoryAdd(player);
  //     _checkWinCondition();
  //   });
  // }

  void _checkWinCondition() {
    if (marcador.player1Score >= marcador.targetPoints &&
        marcador.player1Score >= marcador.player2Score + 2) {
      marcador.incrementSet(1);
      marcador.resetScores();
      _showSetWinnerDialog(_player1Name);
    } else if (marcador.player2Score >= marcador.targetPoints &&
        marcador.player2Score >= marcador.player1Score + 2) {
      marcador.incrementSet(2);
      _showSetWinnerDialog(_player2Name);
      marcador.resetScores();
    }
  }

  // void decrementScore(int player) {
  //   setState(() {
  //     if (player == 1 && _player1Score > 0) {
  //       _player1Score--;
  //     } else if (player == 2 && _player2Score > 0) {
  //       _player2Score--;
  //     }
  //     _scoreHistoryAdd(-player);
  //   });
  // }

  // void _resetScores() {
  //   setState(() {
  //     _player1Score = 0;
  //     _player2Score = 0;
  //     _scoreHistory.clear();
  //   });
  // }

  // void _resetAll() {
  //   setState(() {
  //     _player1Score = 0;
  //     _player2Score = 0;
  //     _player1Sets = 0;
  //     _player2Sets = 0;
  //     _scoreHistory.clear();
  //   });
  // }

  void _showSetWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Set para $winner!'),
          content: Text(
            'El set ha terminado, el marcador de sets es: ${marcador.player1Sets} - ${marcador.player2Sets}.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkMatchWinner();
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
    if (marcador.player1Sets == (marcador.targetSets - 1) / 2 + 1) {
      matchWinner = _player1Name;
    } else if (marcador.player2Sets == (marcador.targetSets - 1) / 2 + 1) {
      matchWinner = _player2Name;
    }

    if (matchWinner != null) {
      setState(() {
        marcador.resetAll();
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

  // hola
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PlayerGameArea(
                  playerName: _player1Name,
                  playerNumber: 1,
                  playerScore: marcador.player1Score,
                  backgroundColor: MyColors.primary,
                  onIncrement: () {
                    setState(() {
                      marcador.incrementScore(1);
                      _checkWinCondition();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      marcador.decrementScore(1);
                    });
                  },
                ),
              ),
              Expanded(
                child: PlayerGameArea(
                  playerName: _player2Name,
                  playerNumber: 2,
                  playerScore: marcador.player2Score,
                  backgroundColor: MyColors.secundary,
                  onIncrement: () {
                    setState(() {
                      marcador.incrementScore(2);
                    });
                    _checkWinCondition();
                  },
                  onDecrement: () {
                    setState(() {
                      marcador.decrementScore(2);
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
                    marcador.resetScores();
                  }),
              onResetAll:
                  () => setState(() {
                    marcador.resetAll();
                  }),
              onUndo: () {
                setState(() {
                  marcador.scoreHistoryUndo();
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
                    '${marcador.player1Sets}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      color: MyColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${marcador.player2Sets}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      color: MyColors.secundary,
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
