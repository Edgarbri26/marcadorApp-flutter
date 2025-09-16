import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/models/setResult.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/services/take_out.dart';
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
  int? _matchId;
  int? _Inscrip1Id;
  int? _Inscrip2Id;
  

  @override
  void initState() {
    super.initState();
    // 🔹 Bloquea orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // la deja libre pero ya esta en horizontal
    Future.delayed(const Duration(milliseconds: 500), () {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    });

  _loadMatchId().then((id) {
    if (id != null) {
      setState(() {
        _matchId = id;
      });
      // úsalo para fetch, rutas, lógica, etc.
      print('Match ID recuperado: $id');
    }
  });
  _loadInscrip1Id().then((id1) {
    if (id1 != null) {
      setState(() {
        _Inscrip1Id = id1;
      });
      // úsalo para fetch, rutas, lógica, etc.
      print('Inscription 1 ID recuperado: $id1');
    }
  });

  _loadInscrip2Id().then((id2) {
    if (id2 != null) {
      setState(() {
        _Inscrip2Id = id2;
      });
      // úsalo para fetch, rutas, lógica, etc.
      print('Incription 2 ID recuperado: $id2');
    }
  });

    //pantalla completa
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Cargar datos guardados
    _loadSettings();
  }

  @override
  void dispose() {
    // 🔹 Restaurar orientación libre al salir
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<int?> _loadMatchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('matchId');
  }
  Future<int?> _loadInscrip1Id() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('inscription1Id');
  }
  Future<int?> _loadInscrip2Id() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('inscription2Id');
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

  
  List<SetResult> _sets = [];

  void _showSetWinnerDialog(String winner) {

    _sets.add(SetResult( // o el que corresponda
      matchId: _matchId ?? 0, // necesitas tener el matchId, usa 0 si es null
      setNumber: widget.marker.player1Sets + widget.marker.player2Sets,
      scoreParticipant1: widget.marker.player1Score,
      scoreParticipant2: widget.marker.player2Score,
    ));

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

  void _showMatchWinnerDialog(String winner) async {
    // Crea el objeto Match
  final match = Match(
    matchId: _matchId ?? 0,
    inscription1Id:_Inscrip1Id ?? 0,
    inscription2Id: _Inscrip2Id ?? 0,
    status: 'finalizado',
  );

  // POST del match y sets
  await ApiService().postMatch(match);
  for (final set in _sets) {
    await ApiService().postSet(set);
  }
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              Flex(
                direction:
                    orientation == Orientation.portrait
                        ? Axis.vertical
                        : Axis.horizontal,

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

              Flex(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                direction:
                    orientation == Orientation.portrait
                        ? Axis.horizontal
                        : Axis.vertical,

                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Align(
                      alignment:
                          orientation == Orientation.portrait
                              // vertical
                              ? Alignment.centerRight
                              : //horizontal
                              Alignment.topCenter,
                      child: Container(
                        padding:
                            orientation == Orientation.portrait
                                // vertical
                                ? const EdgeInsets.symmetric(
                                  horizontal: Spacing.lg,
                                  vertical: Spacing.md,
                                )
                                : const EdgeInsets.symmetric(
                                  //horizontal
                                  horizontal: Spacing.lg,
                                  vertical: Spacing.xs,
                                ),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          color: MyColors.darkContraste,
                          borderRadius: BorderRadius.circular(Spacing.lg),
                        ),
                        child: Flex(
                          direction:
                              orientation == Orientation.portrait
                                  ? Axis.vertical
                                  : Axis.horizontal,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
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
                  ),
                  CenterButtons(
                    onResetScores:
                        () => setState(() {
                          widget.marker.resetScores();
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class TakeOut {
  bool player1 = false;
  bool player2 = false;
  bool difference = false;
  bool remove = false;
  int playerTurn = 0;
  int counter = 0;
  List<int> historyTakeOut = [];

  void init(int numPlayer) {
    if (numPlayer == 1) {
      player1 = true;
      // playerTurn = 1;
    } else {
      player2 = true;
      // playerTurn = 2;
    }
  }

  void _addHistory() {
    historyTakeOut.add(playerTurn);
  }

  void undoHistory() {
    int lastScore = 0;

    if (historyTakeOut.isNotEmpty) {
      !remove ? historyTakeOut.removeLast() : null;
      lastScore = historyTakeOut.removeLast();
      remove = true;
    }
    if (historyTakeOut.isEmpty) {
      reset();
      return;
    }

    if (lastScore == 2) {
      player1 = false;
      player2 = true;
      playerTurn = 2;
    } else if (lastScore == 1) {
      player1 = true;
      player2 = false;
      playerTurn = 1;
    }

    // print('player 1 $player1 y player 2 $player2 turno $playerTurn');
  }

  void incremen(int numPlayer) {
    if (counter == 0 && !player1 && !player2) {
      playerTurn = numPlayer;
      _addHistory();
      init(numPlayer);
      return;
    }

    if (player1 || player2) {
      counter++;
      remove = false;
      _verifyChange();
    }
  }

  void decremen() {
    if (counter == 0) {
      counter = 2;
    }
    undoHistory();
    counter--;
    // print('count $counter');
  }

  void _verifyChange() {
    if (counter == 2 && !difference) {
      counter = 0;
      if (player1) {
        player1 = false;
        player2 = true;
        playerTurn = 2;
      } else {
        player1 = true;
        player2 = false;
        playerTurn = 1;
      }
    } else if (counter >= 0 && difference) {
      if (player1) {
        player1 = false;
        player2 = true;
        playerTurn = 2;
      } else {
        player1 = true;
        player2 = false;
        playerTurn = 1;
      }
    }
    _addHistory();
  }

  void reset() {
    player1 = false;
    player2 = false;
    remove = false;
    difference = false;
    playerTurn = 0;
    counter = 0;
    historyTakeOut.clear();
  }
}
