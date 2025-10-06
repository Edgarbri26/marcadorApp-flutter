import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/center_buttons.dart';
import 'package:marcador/widget/player_game_area.dart';
import 'package:marcador/widget/sets_points.dart';

class MarkerOffLinePage extends StatefulWidget {
  const MarkerOffLinePage({super.key});

  @override
  State<MarkerOffLinePage> createState() => _MarkerOffLinePageState();
}

class _MarkerOffLinePageState extends State<MarkerOffLinePage> {
  Marker marker = Marker();
  final TextEditingController controller = TextEditingController();
  String player1Name = 'Player1';
  String player2Name = 'Player2';
  bool swap = true;
  int _selectedIndex = 0;

  Null get prefs => null;

  Future<void> mostrarDialogoCambiarNombre({
    required BuildContext context,
    required String nombreActual,
    required void Function(String nuevoNombre) onGuardar, // El callback
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
              // Retorna el texto del campo SÓLO si es diferente del actual y no está vacío
              onPressed: () {
                final texto = controller.text.trim();
                if (texto.isNotEmpty && texto != nombreActual) {
                  Navigator.pop(context, texto);
                } else {
                  Navigator.pop(context, null); // Cierra sin cambios
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // 2. Ejecutar la función 'onGuardar' si el usuario ingresó un nombre válido
    if (nuevoNombre != null) {
      onGuardar(nuevoNombre);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    marker.targetPoints = 7;
    marker.targetSets = 3;
    // setState(() {
    //   player1Name = prefs.getString('player1') ?? 'Player1';
    //   player2Name = prefs.getString('player2') ?? 'Player2';
    //   marker.targetPoints = prefs.getInt('points') ?? 7;
    //   marker.targetSets = prefs.getInt('sets') ?? 1;
    // });
    // marker.targetSets = 3;
    // marker.targetPoints = 11;
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
                Navigator.of(context).pop(); // Cerrar el diálogo de ganador
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
    }
  }

  void _checkMatchWinner() {
    int jugarWin = marker.checkMatchWinner();
    if (jugarWin != 0) {
      if (jugarWin == 1) {
        _showMatchWinnerDialog(player1Name);
      } else {
        _showMatchWinnerDialog(player2Name);
      }
      marker.resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // reescribimos los paddings a cero
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
      ),
      child: Scaffold(
        appBar: null,
        body: Stack(
          children: [
            Flex(
              direction: Axis.horizontal,
              textDirection: swap ? TextDirection.ltr : TextDirection.rtl, //
              children: [
                Expanded(
                  child: PlayerGameArea(
                    isTournament: false,
                    onEdit: () {
                      mostrarDialogoCambiarNombre(
                        nombreActual: player1Name,
                        context: context,
                        onGuardar: (nuevoNombre) {
                          player1Name = nuevoNombre;
                        },
                      );
                    },
                    takeOut: marker.playerTurn == 1,
                    playerName: player1Name,
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
                        nombreActual: player1Name,
                        context: context,
                        onGuardar: (nuevoNombre) {
                          player2Name = nuevoNombre;
                        },
                      );
                    },
                    isTournament: false,
                    takeOut: marker.playerTurn == 2,
                    playerName: player2Name,
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
                    _showCustomDialog();
                    // showDialog(
                    //   context: context,
                    //   builder: (context) {
                    //     return  Column(
                    //         children: [
                    //           Row(
                    //             children: [
                    //               IconButton(
                    //                 onPressed: () {
                    //                   _onItemTapped(0);
                    //                 },
                    //                 icon: Icon(Icons.hail_rounded),
                    //               ),
                    //               IconButton(
                    //                 onPressed: () {
                    //                   _onItemTapped(1);
                    //                 },
                    //                 icon: Icon(Icons.emoji_events),
                    //               ),
                    //             ],
                    //           ),
                    //           IndexedStack(index: _selectedIndex, children: [

                    //             ],
                    //           ),
                    //         ],
                    //       );
                    //   },
                    // );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String selectedTab = "Orientación"; // Pestaña inicial

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menú superior (pestañas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton("Amistoso", selectedTab, setState),
                      _buildTabButton("Torneo", selectedTab, setState),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Contenido dinámico
                  _getTabContent(selectedTab),
                  SizedBox(height: 16),
                  // Botones OK y Cancelar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text("CANCELAR"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          // Aquí aplicas los cambios
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabButton(String title, String selected, Function setState) {
    bool active = selected == title;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = title);
      },
      child: Column(
        children: [
          Icon(
            Icons.circle,
            color: active ? Colors.blue : Colors.grey,
            size: 20,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTabContent(String selectedTab) {
    switch (selectedTab) {
      case "Orientación":
        return Container(
          color: Colors.green[50],
          height: 100,
          child: Center(child: Text("Opciones de Orientación")),
        );
      case "Oscuro":
        return Container(
          color: Colors.grey[200],
          height: 100,
          child: Center(child: Text("Opciones de Modo Oscuro")),
        );
      default:
        return Container();
    }
  }

  // Índice inicial en Configuración
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Tournamen extends StatelessWidget {
  const Tournamen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("torneo"));
  }
}

class Friendly extends StatelessWidget {
  const Friendly({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("amistoso"));
  }
}
