import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';

class MarkerTournamentPage extends StatefulWidget {
  final Match match;
  const MarkerTournamentPage({super.key, required this.match});

  @override
  State<MarkerTournamentPage> createState() => _MarkerTournamentPageState();
}

class _MarkerTournamentPageState extends State<MarkerTournamentPage> {
  Marker marker = Marker();
  final List<SetResult> _sets = [];
  String _player1Name = '';
  String _player2Name = '';
  bool swap = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _player1Name = widget.match.nombre1 ?? 'Jugador 1';
    _player2Name = widget.match.nombre2 ?? 'Jugador 2';
    marker.targetSets = widget.match.setsSelected ?? 3;
    marker.targetPoints = widget.match.pointsSelected ?? 11;
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
                Navigator.of(context).pop();
                _sets.removeLast();
                setState(() {
                  winner == _player1Name
                      ? marker.player1Sets--
                      : marker.player2Sets--;
                });
              },
              child: const Text('cancelar'),
            ),
            TextButton(
              onPressed: () async {
                
                //actualiza el macth
                await ApiService().putMatch(widget.match);
                // guarda los sets
                for (final set in _sets) {
                  await ApiService().postSet(set);
                }

                // Cerrar el diálogo de confirmación
                Navigator.of(context).pop();
                // Cerrar marcador
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '¡Ganador del partido: $winner! | partido guardado exitosamente',
                    ),
                  ),
                );
                setState(() {
                  marker.resetAll();
                });
                // Cerrar el diálogo de confirmación
              },

              child: const Text('Cargar partido'),
            ),
          ],
        );
      },
    );
  }

  void _checkWinCondition() {
    int jugarWin = marker.checkWinSetCondition();

    if (marker.checkWinSetCondition() != 0) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Set para $jugarWin!'),
            content: Text(
              'El set ha terminado, el marcador de sets es: ${marker.player1Sets} - ${marker.player2Sets}.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    marker.scoreHistoryUndo();
                  });
                },
                child: const Text('cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _guardarSet(jugarWin);
                  marker.incrementSet(jugarWin);
                  _checkMatchWinner();
                  setState(() {
                    swap = !swap;
                  });
                  marker.resetScores();
                },
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _guardarSet(int jugarWin) {
    final p1Score = marker.player1Score;
    final p2Score = marker.player2Score;

    final setResult = SetResult(
      matchId: widget.match.matchId ?? 0,
      setNumber: marker.totalSetsPlayed,
      scoreParticipant1: p1Score,
      scoreParticipant2: p2Score,
    );
    _sets.add(setResult);

    String winner = jugarWin == 1 ? _player1Name : _player2Name;
    String sets = swap ? '$p1Score - $p2Score' : '$p2Score - $p1Score';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ganador: $winner | '
          'Set guardado: $sets',
        ),
      ),
    );
  }

  void _checkMatchWinner() {
    int jugarWin = marker.checkMatchWinner();
    if (jugarWin != 0) {

      final fechaLocal = DateTime.now();
      final fechaAjustada = fechaLocal.subtract(Duration(hours: 4));
      final fechaIso = fechaAjustada.toIso8601String();
      widget.match.date = fechaIso;

      if (jugarWin == 1) {
        _showMatchWinnerDialog(_player1Name);
        widget.match.winnerInscriptionId = widget.match.inscription1Id;
      } else {
        _showMatchWinnerDialog(_player2Name);
        widget.match.winnerInscriptionId = widget.match.inscription2Id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Flex(
            direction: Axis.horizontal,
            textDirection: swap ? TextDirection.ltr : TextDirection.rtl,
            children: [
              Expanded(
                child: PlayerGameArea(
                  isTournament: true,
                  takeOut: marker.playerTurn == 1,
                  playerName: _player1Name,
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
                  isTournament: true,
                  takeOut: marker.playerTurn == 2,
                  playerName: _player2Name,
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
                swap: swap,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
