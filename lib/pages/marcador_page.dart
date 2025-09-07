import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/widget/player_game_area.dart';

class MarcadorPage extends StatefulWidget {
  const MarcadorPage({super.key});

  @override
  State<MarcadorPage> createState() => _MarcadorPageState();
}

class _MarcadorPageState extends State<MarcadorPage> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _player1Sets = 0;
  int _player2Sets = 0;

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
      // _checkWinCondition();
    });
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

  //   if (_player1Score >= widget.targetPoints && _player1Score >= _player2Score + 2) {
  //     _player1Sets++;
  //     _showSetWinnerDialog(widget.player1Name);
  //     _resetScores();
  //   } else if (_player2Score >= widget.targetPoints && _player2Score >= _player1Score + 2) {
  //     _player2Sets++;
  //     _showSetWinnerDialog(widget.player2Name);
  //     _resetScores();
  //   }
  // }

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
                // _checkMatchWinner();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  // void _checkMatchWinner() {
  //   String? matchWinner;

  //   if (_player1Sets >= widget.targetSets) {
  //     matchWinner = widget.player1Name;
  //   } else if (_player2Sets >= widget.targetSets) {
  //     matchWinner = widget.player2Name;
  //   }

  //   if (matchWinner != null) {
  //     _showMatchWinnerDialog(matchWinner);
  //   }
  // }

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
      body: Column(
        children: [
          Expanded(
            child: PlayerGameArea(
              playerNumber: 1,
              playerScore: _player1Score,
              backgroundColor: MyColors.primary,
              onIncrement: incrementScore,
              onDecrement: decrementScore,
            ),
          ),
          Expanded(
            child: PlayerGameArea(
              playerNumber: 2,
              playerScore: _player2Score,
              backgroundColor: MyColors.secundary,
              onIncrement: incrementScore,
              onDecrement: decrementScore,
            ),
          ),
        ],
      ),
    );
  }
}
