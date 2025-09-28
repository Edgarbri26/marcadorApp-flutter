class TakeOut2 {
  int playerTurn = 0; // 0 = sin iniciar, 1 = jugador 1, 2 = jugador 2
  // int counter = 0; // cuenta puntos dentro del turno
  bool difference = false; // indica si se juega con diferencia
  int totalPoints = 0; // Puntos totales jugados
  int changeEvery = 2;
  int firstServer = 0;
  List<int> historyTakeOut = [];

  /// Inicializa el jugador que tiene el saque al inicio
  void _init(int startingPlayer) {
    playerTurn = startingPlayer;
    historyTakeOut.clear();
    firstServer = startingPlayer;
    // counter = 0;
  }

  /// Registra en historial
  // ignore: unused_element
  void _addHistory(int turn) {
    historyTakeOut.add(turn);
  }

  /// Deshacer último cambio
  void undoHistory() {
    if (historyTakeOut.isEmpty) {
      print('isEmpaty');

      reset();
      return;
    }
    playerTurn = historyTakeOut.removeLast();
  }

  /// Sumar punto
  void increment(int scoringPlayer) {
    if (playerTurn == 0) {
      // Primer punto define quién tiene el saque
      _init(scoringPlayer);
      // _addHistory(playerTurn);

      return;
    }
    totalPoints++;
    _updateTurn();
  }

  /// Retroceder un punto
  void decrement() {
    if (totalPoints > 0) {
      totalPoints--;
      _updateTurn();
    } else if (totalPoints == 0) {
      reset();
    }
  }

  /// Recalcula el jugador con el saque
  void _updateTurn() {
    playerTurn =
        ((totalPoints ~/ changeEvery) % 2 == 0)
            ? firstServer
            : (firstServer == 1 ? 2 : 1);
  }

  /// Reinicia todo
  void reset() {
    playerTurn = 0;
    totalPoints = 0;
    historyTakeOut.clear();
  }

  void checkDifference() {
    // if(){

    // }
  }
}
