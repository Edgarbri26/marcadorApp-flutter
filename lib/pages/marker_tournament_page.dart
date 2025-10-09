import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/radius.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/models/marker.dart';
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
  bool isLoading = false;
  TypeConfeti typeConfeti = TypeConfeti.right;
  double blastDirection = 0;
  Alignment blastDirectionality = Alignment.topCenter;
  final confettiControllerLef = ConfettiController();
  final confettiControllerRigh = ConfettiController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _player1Name = widget.match.nombre1 ?? 'Jugador 1';
    _player2Name = widget.match.nombre2 ?? 'Jugador 2';
    marker.targetSets = widget.match.setsSelected ?? 3;
    marker.targetPoints = widget.match.pointsSelected ?? 11;
  }

  @override
  void dispose() {
    confettiControllerLef.dispose();
    confettiControllerRigh.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // Tu función donde muestras el diálogo
  void _showMatchWinnerDialog(String winner) async {
    // Mantenemos 'isLoading' como variable local.
    // El estado de 'isLoading' para el botón se manejará con el StatefulBuilder.
    bool dialogIsLoading = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        // Renombramos el contexto a dialogContext
        return AlertDialog(
          title: Text('¡Ganador del partido: $winner!'),
          content: Text('¡Felicidades, $winner ha ganado el partido!'),
          actions: <Widget>[
            // Botón CANCELAR - No necesita StatefulBuilder
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _sets.removeLast();
                // Usamos el setState de la pantalla principal para la lógica de datos
                setState(() {
                  winner == _player1Name
                      ? marker.player1Sets--
                      : marker.player2Sets--;
                });
              },
              child: const Text('cancelar'),
            ),

            // ¡EL CAMBIO CLAVE! Usamos StatefulBuilder para actualizar solo el botón
            StatefulBuilder(
              builder: (contextSB, setStateSB) {
                // contextSB y setStateSB son para el botón
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.secundary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(WeinFluRadius.small),
                    ),
                  ),
                  // El botón solo funciona si NO está cargando
                  onPressed:
                      dialogIsLoading
                          ? null
                          : () async {
                            // 1. Activar el loader del botón usando el setState del Builder
                            setStateSB(() => dialogIsLoading = true);

                            try {
                              await ApiService().putMatch(widget.match);

                              for (final set in _sets) {
                                print('Set a guardar: ${set.toJson()}');
                                await ApiService().postSet(set);
                              }
                              Navigator.of(dialogContext).pop();
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
                              confettiControllerLef.stop();
                              confettiControllerRigh.stop();

                              Navigator.of(context).pop();
                            } catch (e) {
                              setStateSB(() => dialogIsLoading = false);
                              if (Navigator.of(dialogContext).canPop()) {
                                Navigator.of(dialogContext).pop();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al guardar el partido: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  child:
                      dialogIsLoading
                          ? const SizedBox(
                            width: 30,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ), // Color blanco para un ElevatedButton
                            ),
                          )
                          : const Text(
                            "Guardar partido",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _checkWinCondition() {
    int jugarWin = marker.checkWinSetCondition();
    String winner = jugarWin == 1 ? _player1Name : _player2Name;

    if (marker.checkWinSetCondition() != 0) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Set para $winner!'),
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
                  marker.incrementSet(jugarWin);
                  _guardarSet(jugarWin);
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
      matchId: widget.match.matchId ?? 1,
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
      swap = !swap;
      final fechaLocal = DateTime.now();
      final fechaAjustada = fechaLocal.subtract(Duration(hours: 4));
      final fechaIso = fechaAjustada.toIso8601String();
      widget.match.date = fechaIso;

      if (jugarWin == 1) {
        !swap
            ? confettiControllerLef.play()
            : confettiControllerRigh
                .play(); // Ajusta la dirección según el swap

        _showMatchWinnerDialog(_player1Name);
        widget.match.winnerInscriptionId = widget.match.inscription1Id;
      } else {
        !swap ? confettiControllerRigh.play() : confettiControllerLef.play();
        // Ajusta la dirección según el swap

        _showMatchWinnerDialog(_player2Name);
        widget.match.winnerInscriptionId = widget.match.inscription2Id;
      } // Ajusta la dirección
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
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
                    onEvent: () {
                      confettiControllerLef.play();
                      confettiControllerRigh.play();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned.fill(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  confettiController: confettiControllerLef,
                  blastDirection: 0, // derecha
                  blastDirectionality: BlastDirectionality.directional,
                  emissionFrequency: 0.8,
                  numberOfParticles: 20,
                  gravity: 0.3,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  confettiController: confettiControllerRigh,
                  blastDirection: pi, // izquierda
                  blastDirectionality: BlastDirectionality.directional,
                  emissionFrequency: 0.8,
                  numberOfParticles: 20,
                  gravity: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum TypeConfeti { lef, right }
