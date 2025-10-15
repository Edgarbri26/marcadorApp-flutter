import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/radius.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/models/marker.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double blastDirection = 0;
  Alignment blastDirectionality = Alignment.topCenter;
  final confettiControllerLef = ConfettiController();
  final confettiControllerRigh = ConfettiController();
  final repo = MatchRepository();
  bool isRotate = true;

  @override
  void initState() {
    super.initState();
    preferenceGet();
    FullScreen.setFullScreen(true);
    _player1Name = widget.match.nombre1 ?? 'Jugador 1';
    _player2Name = widget.match.nombre2 ?? 'Jugador 2';
    marker.targetSets = widget.match.setsSelected ?? 3;
    marker.targetPoints = widget.match.pointsSelected ?? 11;
  }

  @override
  void dispose() {
    enterPortraitMode();
    confettiControllerLef.dispose();
    confettiControllerRigh.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    FullScreen.setFullScreen(false);
    super.dispose();
  }

  void enterLandscapeMode() {
    // if (!kIsWeb) {
    // Esto es crucial para evitar errores en web
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // Rotación a la izquierda
      DeviceOrientation.landscapeRight, // Rotación a la derecha
    ]);
    // }
  }

  // Función para volver al modo vertical/normal
  void enterPortraitMode() {
    // if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // }
  }

  void preferenceGet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // isRotate = !isRotate;
      isRotate = prefs.getBool('isRotate') ?? true;
    });
    isRotate ? enterLandscapeMode() : enterPortraitMode();
  }

  void preferenceSet() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isRotate", isRotate);
  }

  // Tu función donde muestras el diálogo
  void _showMatchWinnerDialog(String winner) async {
    bool dialogIsLoading = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('¡Ganador del partido: $winner!'),
          content: Text('¡Felicidades, $winner ha ganado el partido!'),
          actions: <Widget>[
            // cancelar
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _sets.removeLast();
                setState(() {
                  winner == _player1Name
                      ? marker.player1Sets--
                      : marker.player2Sets--;
                });
              },
              child: const Text('cancelar'),
            ),

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

                  onPressed:
                      dialogIsLoading
                          ? null
                          : () async {
                            setStateSB(() => dialogIsLoading = true);
                            print(
                              "inscripncion 1: ${widget.match.inscription1Id}, inscripncion 2: ${widget.match.inscription2Id} inscripncion win: ${widget.match.winnerInscriptionId}",
                            );

                            final MatchSave finishedMatch = MatchSave(
                              ciWiner: widget.match.ciWiner,
                              ci1: widget.match.ci1!,
                              ci2: widget.match.ci2!,
                              tournamentId: widget.match.tournamentId,
                              round: widget.match.round,
                              matchId: widget.match.matchId,
                              player1Name: widget.match.nombre1 ?? 'Jugador 1',
                              player2Name: widget.match.nombre2 ?? 'Jugador 2',
                              winnerInscriptionId:
                                  widget.match.winnerInscriptionId,

                              winnerName: winner,
                              isSynced: false, // Aún no se ha sincronizado
                              setsResults: _sets,
                            );
                            repo.savePendingMatch(finishedMatch);

                            try {
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
      matchId: widget.match.matchId,
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
        widget.match.ciWiner = widget.match.ci1;
      } else {
        !swap ? confettiControllerRigh.play() : confettiControllerLef.play();
        // Ajusta la dirección según el swap

        _showMatchWinnerDialog(_player2Name);
        widget.match.winnerInscriptionId = widget.match.inscription2Id;
        widget.match.ciWiner = widget.match.ci2;
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
                direction: isRotate ? Axis.horizontal : Axis.vertical,
                textDirection: swap ? TextDirection.ltr : TextDirection.rtl,
                verticalDirection:
                    swap ? VerticalDirection.up : VerticalDirection.down,
                spacing: 4,
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

              Align(
                alignment: Alignment.center,
                child: CenterButtons(
                  rotate: isRotate,
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
                  onRorate: () {
                    setState(() {
                      isRotate = !isRotate;
                    });
                    preferenceSet();
                    isRotate ? enterLandscapeMode() : enterPortraitMode();
                  },
                ),
              ),
              Align(
                alignment:
                    isRotate ? Alignment.topCenter : Alignment.centerLeft,
                child: SetsPoints(
                  rotate: isRotate,
                  swap: swap,
                  player1Sets: marker.player1Sets,
                  player2Sets: marker.player2Sets,
                ),
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
