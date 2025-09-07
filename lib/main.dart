import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/app.dart';

void main() {
  runApp(const MyApp());
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _player1NameController = TextEditingController(text: 'Jugador 1');
  final TextEditingController _player2NameController = TextEditingController(text: 'Jugador 2');
  final TextEditingController _targetPointsController = TextEditingController(text: '11');
  final TextEditingController _targetSetsController = TextEditingController(text: '3');

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScoreboardPage(
          player1Name: _player1NameController.text.isEmpty ? 'Jugador 1' : _player1NameController.text,
          player2Name: _player2NameController.text.isEmpty ? 'Jugador 2' : _player2NameController.text,
          targetPoints: int.tryParse(_targetPointsController.text) ?? 11,
          targetSets: int.tryParse(_targetSetsController.text) ?? 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Juego'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _player1NameController,
              decoration: const InputDecoration(labelText: 'Nombre Jugador 1'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _player2NameController,
              decoration: const InputDecoration(labelText: 'Nombre Jugador 2'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetPointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Puntos a jugar (para ganar el set)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetSetsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Mejor de N sets (para ganar el partido)'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreboardPage extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  final int targetPoints;
  final int targetSets;

  const ScoreboardPage({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.targetPoints,
    required this.targetSets,
  });

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _player1Sets = 0;
  int _player2Sets = 0;

  @override
  void initState() {
    super.initState();
    // Forzar la orientación de la pantalla a horizontal al entrar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Volver a la orientación vertical por defecto al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _incrementScore(int player) {
    setState(() {
      if (player == 1) {
        _player1Score++;
      } else {
        _player2Score++;
      }
      _checkWinCondition();
    });
  }

  void _decrementScore(int player) {
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

  void _checkWinCondition() {
    if (_player1Score >= widget.targetPoints && _player1Score >= _player2Score + 2) {
      _player1Sets++;
      _showSetWinnerDialog(widget.player1Name);
      _resetScores();
    } else if (_player2Score >= widget.targetPoints && _player2Score >= _player1Score + 2) {
      _player2Sets++;
      _showSetWinnerDialog(widget.player2Name);
      _resetScores();
    }
  }

  void _showSetWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Set para $winner!'),
          content: Text('El set ha terminado, el marcador de sets es: $_player1Sets - $_player2Sets.'),
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

    if (_player1Sets >= widget.targetSets) {
      matchWinner = widget.player1Name;
    } else if (_player2Sets >= widget.targetSets) {
      matchWinner = widget.player2Name;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Row(
          children: [
            // Sección del Jugador 1 con detector de gestos para sumar puntos
            Expanded(
              child: GestureDetector(
                onTap: () => _incrementScore(1),
                child: Container(
                  color: Colors.blue.shade600,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🐸', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        widget.player1Name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _player1Score.toString(),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sets: $_player1Sets',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Separador de sets
            Container(
              color: Colors.grey.shade800,
              width: 20,
              child: Center(
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Sección del Jugador 2 con detector de gestos para sumar puntos
            Expanded(
              child: GestureDetector(
                onTap: () => _incrementScore(2),
                child: Container(
                  color: Colors.red.shade600,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🐄', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        widget.player2Name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _player2Score.toString(),
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sets: $_player2Sets',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}