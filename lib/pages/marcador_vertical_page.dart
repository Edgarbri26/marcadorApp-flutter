import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/services/take_out.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/services/take_out2.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';
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
  // TakeOut2 takeOut = TakeOut2();
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

    // // la deja libre pero ya esta en horizontal
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // });

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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    int jugarWin = widget.marker.checkMatchWinner();
    if (jugarWin != 0) {
      jugarWin == 1
          ? _showMatchWinnerDialog(_player1Name)
          : _showMatchWinnerDialog(_player2Name);
    }

    if (widget.marker.checkWinSetCondition()) {
      // aqui para guardar el set
    }
    
  }

  // void _undoTakeoOut() {
  //   if (widget.marker.player1Score <= widget.marker.targetPoints ||
  //       widget.marker.player2Score <= widget.marker.targetPoints) {
  //     widget.marker.difference = false;
  //   }
  //   setState(() {
  //     widget.marker.decrement();
  //   });
  // }

  // List<SetResult> _sets = [];

  // void _showSetWinnerDialog(String winner) {
  //   _sets.add(
  //     SetResult(
  //       // o el que corresponda
  //       matchId: _matchId ?? 0, // necesitas tener el matchId, usa 0 si es null
  //       setNumber: widget.marker.player1Sets + widget.marker.player2Sets,
  //       scoreParticipant1: widget.marker.player1Score,
  //       scoreParticipant2: widget.marker.player2Score,
  //     ),
  //   );

  //   _checkMatchWinner();
  //   setState(() {
  //     takeOut.reset();
  //   });

  //   // showDialog(
  //   //   context: context,
  //   //   builder: (BuildContext context) {
  //   //     return AlertDialog(
  //   //       title: Text('¡Set para $winner!'),
  //   //       content: Text(
  //   //         'El set ha terminado, el marcador de sets es: ${widget.marker.player1Sets} - ${widget.marker.player2Sets}.',
  //   //       ),
  //   //       actions: <Widget>[
  //   //         TextButton(
  //   //           onPressed: () {
  //   //             Navigator.of(context).pop();
  //   //             _checkMatchWinner();
  //   //             setState(() {
  //   //               takeOut.reset();
  //   //             });
  //   //           },
  //   //           child: const Text('Continuar'),
  //   //         ),
  //   //       ],
  //   //     );
  //   //   },
  //   // );
  // }

  // void _checkMatchWinner() {
  //   String? matchWinner;
  //   if (widget.marker.player1Sets == (widget.marker.targetSets - 1) / 2 + 1) {
  //     matchWinner = _player1Name;
  //   } else if (widget.marker.player2Sets ==
  //       (widget.marker.targetSets - 1) / 2 + 1) {
  //     matchWinner = _player2Name;
  //   }

  //   if (matchWinner != null) {
  //     setState(() {
  //       widget.marker.resetAll();
  //     });
  //     _showMatchWinnerDialog(matchWinner);
  //   }
  // }

  void _showMatchWinnerDialog(String winner) async {
    // Crea el objeto Match
    // final match = Match(
    //   matchId: _matchId ?? 0,
    //   inscription1Id: _Inscrip1Id ?? 0,
    //   inscription2Id: _Inscrip2Id ?? 0,
    //   status: 'finalizado',
    // );

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
                      takeOut: widget.marker.playerTurn == 1,
                      playerName: _player1Name,
                      playerNumber: 1,
                      playerScore: widget.marker.player1Score,
                      backgroundColor: MyColors.secundary,
                      onIncrement: () {
                        setState(() {
                          widget.marker.incrementScore(1);
                          _checkWinCondition();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: PlayerGameArea(
                      takeOut: widget.marker.playerTurn == 2,
                      playerName: _player2Name,
                      playerNumber: 2,
                      playerScore: widget.marker.player2Score,
                      backgroundColor: MyColors.primary,
                      onIncrement: () {
                        setState(() {
                          widget.marker.incrementScore(2);
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
                direction:
                    orientation == Orientation.portrait
                        ? Axis.horizontal
                        : Axis.vertical,

                children: [
                  SetsPoints(
                    player1Sets: widget.marker.player1Sets,
                    player2Sets: widget.marker.player2Sets,
                  ),
                  CenterButtons(
                    onResetScores:
                        () => setState(() {
                          widget.marker.resetScores();
                        }),
                    onResetAll:
                        () => setState(() {
                          widget.marker.resetAll();
                        }),
                    onUndo: () {
                      setState(() {
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
