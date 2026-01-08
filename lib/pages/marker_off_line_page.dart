import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/models/marker.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkerOffLinePage extends StatefulWidget {
  const MarkerOffLinePage({super.key});

  @override
  State<MarkerOffLinePage> createState() => _MarkerOffLinePageState();
}

class _MarkerOffLinePageState extends State<MarkerOffLinePage> {
  Marker marker = Marker();
  final TextEditingController controller = TextEditingController();
  String _player1Name = 'Player1';
  String _player2Name = 'Player2';
  bool swap = true;
  double blastDirection = 0;
  Alignment blastDirectionality = Alignment.topCenter;
  final confettiControllerLef = ConfettiController();
  final confettiControllerRigh = ConfettiController();
  bool isRotate = true;

  @override
  void initState() {
    super.initState();
    preferenceGet();
    FullScreen.setFullScreen(true);
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void enterPortraitMode() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void preferenceGet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRotate = prefs.getBool('isRotate') ?? true;
      marker.targetPoints = prefs.getInt('points') ?? 11;
      marker.targetSets = prefs.getInt('sets') ?? 3;
      print(
        'DEBUG: Loaded settings - Points: ${marker.targetPoints}, Sets: ${marker.targetSets}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Configuración cargada: ${marker.targetSets} sets, ${marker.targetPoints} puntos',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
    isRotate ? enterLandscapeMode() : enterPortraitMode();
  }

  void preferenceSet() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isRotate", isRotate);
  }

  Future<void> mostrarDialogoCambiarNombre({
    required BuildContext context,
    required String nombreActual,
    required void Function(String nuevoNombre) onGuardar,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: nombreActual,
    );

    final String? nuevoNombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Nombre'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Introduce el nuevo nombre",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final texto = controller.text.trim();
                if (texto.isNotEmpty && texto != nombreActual) {
                  Navigator.pop(context, texto);
                } else {
                  Navigator.pop(context, null);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nuevoNombre != null) {
      onGuardar(nuevoNombre);
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
                confettiControllerLef.stop();
                confettiControllerRigh.stop();
                setState(() {
                  if (winner == _player1Name) {
                    marker.player1Sets--;
                  } else {
                    marker.player2Sets--;
                  }
                  // Revert swap since we swapped on win
                  swap = !swap;
                  marker.scoreHistoryUndo();
                });
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  marker.resetAll();
                });
                confettiControllerLef.stop();
                confettiControllerRigh.stop();
              },
              child: const Text('Reiniciar Partido'),
            ),
          ],
        );
      },
    );
  }

  void _checkWinCondition() {
    if (marker.checkWinSetCondition() != 0) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          int setWinner = marker.checkWinSetCondition();
          String winnerName = setWinner == 1 ? _player1Name : _player2Name;

          return AlertDialog(
            title: Text('¡Set para $winnerName!'),
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
                  marker.incrementSet(setWinner);

                  if (marker.checkMatchWinner() != 0) {
                    _checkMatchWinner();
                  } else {
                    marker.resetScores();
                    setState(() {
                      swap = !swap;
                    });
                  }
                },
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _checkMatchWinner() {
    int jugarWin = marker.checkMatchWinner();
    if (jugarWin != 0) {
      if (jugarWin == 1) {
        !swap ? confettiControllerLef.play() : confettiControllerRigh.play();
        _showMatchWinnerDialog(_player1Name);
      } else {
        !swap ? confettiControllerRigh.play() : confettiControllerLef.play();
        _showMatchWinnerDialog(_player2Name);
      }
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
                      isTournament: false,
                      onEdit: () {
                        mostrarDialogoCambiarNombre(
                          nombreActual: _player1Name,
                          context: context,
                          onGuardar: (nuevoNombre) {
                            setState(() {
                              _player1Name = nuevoNombre;
                            });
                          },
                        );
                      },
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
                      onEdit: () {
                        mostrarDialogoCambiarNombre(
                          nombreActual: _player2Name,
                          context: context,
                          onGuardar: (nuevoNombre) {
                            setState(() {
                              _player2Name = nuevoNombre;
                            });
                          },
                        );
                      },
                      isTournament: false,
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
