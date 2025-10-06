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

    if (widget.match.round == 'Semifinal' || widget.match.round == 'Final') {
      marker.targetSets = 5;
      marker.targetPoints = 11;
    } else if (widget.match.round == 'Ronda 3' ||
        widget.match.round == 'Ronda 2' ||
        widget.match.round == 'Octavos de Final' ||
        widget.match.round == 'Cuartos de Final') {
      marker.targetSets = 3;
      marker.targetPoints = 11;
    } else if (widget.match.round == 'Repechaje' ||
        widget.match.round == 'Ronda 1') {
      marker.targetSets = 3;
      marker.targetPoints = 11;
    } else {
      marker.targetSets = 3;
      marker.targetPoints = 7;
    }
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
                marker.scoreHistoryUndo();
              },
              child: const Text('cancelar'),
            ),
            TextButton(
              onPressed: () {
                print("si funciono");
                Navigator.of(context).pop(); // Cerrar el diálogo de ganador
                print('Sets guardados: $_sets');
                print('Match guardado: ${widget.match.matchId}');
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar finalización del partido'),
                      content: const Text(
                        '¿Estás seguro de que quieres finalizar el partido?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // Cerrar el diálogo de confirmación
                            marker.scoreHistoryUndo();
                          },
                          child: const Text('Cancelar'),
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
                            Navigator.of(
                              context,
                            ).pop(); // Cerrar el diálogo de confirmación
                            Navigator.of(
                              context,
                            ).pop(); // Cerrar el diálogo de confirmación
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
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
                  _guardarSet();
                  marker.resetScores();
                  _checkMatchWinner();
                  marker.incrementSet(jugarWin);
                  setState(() {
                    swap = !swap;
                  });
                },
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );
      // aqui para guardar el set
      // final p1Score = marker.player1Score;
      // final p2Score = marker.player2Score;

      // final setResult = SetResult(
      //   matchId: widget.match.matchId ?? 0,
      //   setNumber: marker.totalSetsPlayed,
      //   scoreParticipant1: p1Score,
      //   scoreParticipant2: p2Score,
      // );
      // _sets.add(setResult);

      // print("marker.player1Score ${marker.player1Score}");
      // print("marker.player2Score ${marker.player2Score}");
      // print(
      //   'Set guardado: ${_sets[0].scoreParticipant1} y ${_sets[0].scoreParticipant2}',
      // );
    }

    // if (jugarWin != 0) {
    //   widget.match.status = 'Finalizado';

    //   final fechaLocal = DateTime.now();
    //   final fechaAjustada = fechaLocal.subtract(Duration(hours: 4));
    //   final fechaIso = fechaAjustada.toIso8601String();
    //   widget.match.date = fechaIso;

    //   if (jugarWin == 1) {
    //     _showMatchWinnerDialog(_player1Name);
    //     widget.match.winnerInscriptionId = widget.match.inscription1Id;
    //   } else {
    //     _showMatchWinnerDialog(_player2Name);
    //     widget.match.winnerInscriptionId = widget.match.inscription2Id;
    //   }

    //   marker.resetAll();
    // }
  }

  void _guardarSet() {
    final p1Score = marker.player1Score;
    final p2Score = marker.player2Score;

    final setResult = SetResult(
      matchId: widget.match.matchId ?? 0,
      setNumber: marker.totalSetsPlayed,
      scoreParticipant1: p1Score,
      scoreParticipant2: p2Score,
    );
    _sets.add(setResult);

    print("marker.player1Score ${marker.player1Score}");
    print("marker.player2Score ${marker.player2Score}");
    print(
      'Set guardado: ${_sets[0].scoreParticipant1} y ${_sets[0].scoreParticipant2}',
    );
  }

  void _checkMatchWinner() {
    int jugarWin = marker.checkMatchWinner();
    if (jugarWin != 0) {
      widget.match.status = 'Finalizado';

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

      marker.resetAll();
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
