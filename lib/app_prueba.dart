import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';

class AppBarTimer extends StatefulWidget {
  final ValueChanged<String> onPressedNum;
  final String numPairs;
  final String title;

  const AppBarTimer({
    super.key,
    required this.onPressedNum,
    required this.numPairs,
    required this.title,
  });

  @override
  State<AppBarTimer> createState() => _AppBarTimerState();
}

class _AppBarTimerState extends State<AppBarTimer> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Se usa SafeArea para evitar que el contenido se superponga con la barra de estado del sistema.
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.darkContraste,
          borderRadius: BorderRadius.circular(Spacing.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón de configuración
            IconButton(
              icon: const Icon(Icons.settings, color: MyColors.secundary),
              onPressed: () {
                // Navegación comentada porque las rutas no están definidas en este ejemplo
                // Navigator.of(context).pushNamed(AppRoutes.configuration);
              },
            ),

            // Título y selector de categoría
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Ingresa un número'),
                      content: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.onPressedNum(_controller.text);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Text(
                  widget.numPairs,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
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

// --- El resto de tu aplicación principal ---

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _isTimerRunning = false;
  String _numPairs = '00';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateTimerState(bool isRunning) {
    setState(() {
      _isTimerRunning = isRunning;
    });
  }

  void _updateNumPairs(String newNum) {
    setState(() {
      _numPairs = newNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      home: Scaffold(
        backgroundColor: MyColors.darkContraste,
        // Se oculta la barra de navegación si el temporizador está corriendo
        appBar:
            _isTimerRunning
                ? null
                : PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: AppBarTimer(
                    title: 'Temporizador',
                    numPairs: _numPairs,
                    onPressedNum: _updateNumPairs,
                  ),
                ),
        body: Center(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              TimerScreen(
                onTimerStateChanged: _updateTimerState,
                numPairs: _numPairs,
              ),
              const HomeScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
        bottomNavigationBar:
            _isTimerRunning
                ? null
                : BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.timer),
                      label: 'Temporizador',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Configuración',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final ValueChanged<bool> onTimerStateChanged;
  final String numPairs;

  const TimerScreen({
    Key? key,
    required this.onTimerStateChanged,
    required this.numPairs,
  }) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isRunning = false;
  int _elapsedTime = 0;
  Timer? _timer;

  void _startStopTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
      } else {
        _elapsedTime = 0;
        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _elapsedTime += 10;
          });
        });
      }
      _isRunning = !_isRunning;
      widget.onTimerStateChanged(_isRunning);
    });
  }

  String _formatTime(int milliseconds) {
    final int seconds = (milliseconds ~/ 1000);
    final int minutes = (seconds ~/ 60);
    final int remainingSeconds = (seconds % 60);
    final int remainingMilliseconds = (milliseconds % 1000) ~/ 10;

    String formattedTime = '';

    if (minutes > 0) {
      formattedTime +=
          '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}.';
    } else {
      formattedTime += '${remainingSeconds.toString()}.';
    }
    formattedTime += '${remainingMilliseconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startStopTimer,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _formatTime(_elapsedTime),
                style: TextStyle(
                  fontSize:
                      _isRunning ? 100 : 60, // Cambio en el tamaño de la fuente
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.numPairs,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isRunning ? 'Toca para detener' : 'Toca para iniciar',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blueGrey.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de ejemplo para la navegación
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Inicio', style: TextStyle(fontSize: 30)),
    );
  }
}

// Pantalla de ejemplo para la navegación
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Configuración', style: TextStyle(fontSize: 30)),
    );
  }
}
