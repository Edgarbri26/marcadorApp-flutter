import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarcadorVerticalPage extends StatefulWidget {
  const MarcadorVerticalPage({super.key});

  @override
  State<MarcadorVerticalPage> createState() => _MarcadorVerticalPageState();
}

class _MarcadorVerticalPageState extends State<MarcadorVerticalPage> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _player1Sets = 0;
  int _player2Sets = 0;
  String _player1Name = 'Jugador 1';
  String _player2Name = 'Jugador 2';
  int _targetPoints = 11;
  int _targetSets = 3;

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
      _targetPoints = prefs.getInt('points') ?? 7;
      _targetSets = prefs.getInt('sets') ?? 1;
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

  void incrementScore(int player) {
    setState(() {
      if (player == 1) {
        _player1Score++;
      } else {
        _player2Score++;
      }
      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    if (_player1Score >= _targetPoints && _player1Score >= _player2Score + 2) {
      _player1Sets++;
      _showSetWinnerDialog(_player1Name);
      _resetScores();
    } else if (_player2Score >= _targetPoints &&
        _player2Score >= _player1Score + 2) {
      _player2Sets++;
      _showSetWinnerDialog(_player2Name);
      _resetScores();
    }
  }

  void decrementScore(int player) {
    setState(() {
      if (player == 1 && _player1Score > 0) {
        _player1Score--;
      } else if (player == 2 && _player2Score > 0) {
        _player2Score--;
      }
    });
  }

  void _resetScores() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
    });
  }

  void _resetAll() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _player1Sets = 0;
      _player2Sets = 0;
    });
  }

  void _showSetWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Set para $winner!'),
          content: Text(
            'El set ha terminado, el marcador de sets es: $_player1Sets - $_player2Sets.',
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

    if (_player1Sets >= _targetSets) {
      matchWinner = _player1Name;
    } else if (_player2Sets >= _targetSets) {
      matchWinner = _player2Name;
    }

    if (matchWinner != null) {
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
                _resetAll();
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
                  playerScore: _player1Score,
                  backgroundColor: MyColors.primary,
                  onIncrement: incrementScore,
                  onDecrement: decrementScore,
                ),
              ),
              Expanded(
                child: PlayerGameArea(
                  playerName: _player2Name,
                  playerNumber: 2,
                  playerScore: _player2Score,
                  backgroundColor: MyColors.secundary,
                  onIncrement: incrementScore,
                  onDecrement: decrementScore,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: CenterButtons(
              onResetScores: _resetScores,
              onResetAll: _resetAll,
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
                    '$_player1Sets',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      color: MyColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '$_player2Sets',
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

class CenterButtons extends StatelessWidget {
  final VoidCallback? onResetScores;
  final VoidCallback? onResetAll;
  const CenterButtons({super.key, this.onResetScores, this.onResetAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: MyColors.darkContraste,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed:
                () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirmación'),
                      content: Text(
                        '¿Estás seguro de jugar una nueva partida?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                ),
            icon: Icon(Icons.add_box_outlined, color: MyColors.lightGray),
          ),
          IconButton(
            onPressed: onResetScores,
            icon: Icon(Icons.refresh, color: MyColors.lightGray),
          ),
          IconButton(
            onPressed: onResetAll,
            icon: Icon(Icons.restart_alt, color: MyColors.lightGray),
          ),
        ],
      ),
    );
  }
}
