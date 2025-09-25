class Marker {
  int player1Score = 0;
  int player2Score = 0;
  int player1Sets = 0;
  int player2Sets = 0;
  int targetPoints = 7;
  int targetSets = 1;
  List<int> scoreHistory = [];

  int playerTurn = 0; // 0 = sin iniciar, 1 = jugador 1, 2 = jugador 2
  bool difference = false; // indica si se juega con diferencia
  int totalPoints = 0; // Puntos totales jugados
  int totalSetsPlayed = 0;
  int changeEvery = 2;
  int firstServer = 0;

  // List<int> historyTakeOut = [];

  Marker();

  // marcador

  scoreHistoryAdd(int nJugador) {
    scoreHistory.add(nJugador);
  }

  scoreHistoryUndo() {
    if (scoreHistory.isNotEmpty) {
      int lastScore = scoreHistory.removeLast();

      if (lastScore == 1 && player1Score > 0) {
        player1Score--;
      } else if (lastScore == 2 && player2Score > 0) {
        player2Score--;
      }

      if (totalPoints > 0) {
        totalPoints--;
        _updateTurn();
      } else if (totalPoints == 0) {
        resetScores();
      }

      // if (lastScore == -1 && player1Score < targetPoints) {
      //   player1Score++;
      // } else if (lastScore == -2 && player2Score < targetPoints) {
      //   player2Score++;
      // }
    }
  }

  void incrementScore(int player) {
    if (playerTurn == 0) {
      _init(player);
      return;
    }
    totalPoints++;
    if (player == 1) {
      player1Score++;
    } else {
      player2Score++;
    }
    scoreHistoryAdd(player);
    checkDifference();
  }

  void incrementSet(int player) {
    if (player == 1) {
      player1Sets++;
    } else {
      player2Sets++;
    }
    totalSetsPlayed++;
    scoreHistoryAdd(player);
  }

  void decrementScore(int player) {
    if (player == 1 && player1Score > 0) {
      player1Score--;
    } else if (player == 2 && player2Score > 0) {
      player2Score--;
    }
    scoreHistoryAdd(-player);
    checkDifference();
  }

  void resetScores() {
    player1Score = 0;
    player2Score = 0;
    playerTurn = 0;
    totalPoints = 0;
    scoreHistory.clear();
  }

  void resetAll() {
    playerTurn = 0;
    totalPoints = 0;
    totalSetsPlayed = 0;
    player1Score = 0;
    player2Score = 0;
    player1Sets = 0;
    player2Sets = 0;
    scoreHistory.clear();
  }

  // saque
  /// Inicializa el jugador que tiene el saque al inicio
  void _init(int startingPlayer) {
    playerTurn = startingPlayer;
    // historyTakeOut.clear();
    firstServer = startingPlayer;
    // counter = 0;
  }

  // void increment(int scoringPlayer) {
  //   // Primer punto define quién tiene el saque
  //   if (playerTurn == 0) {
  //     _init(scoringPlayer);
  //     return;
  //   }
  //   totalPoints++;
  // }

  /// Retroceder un punto
  void decrement() {
    if (totalPoints > 0) {
      totalPoints--;
      _updateTurn();
    } else if (totalPoints == 0) {
      resetScores();
    }
  }

  /// Recalcula el jugador con el saque
  void _updateTurn() {
    playerTurn =
        ((totalPoints ~/ changeEvery) % 2 == 0)
            ? firstServer
            : (firstServer == 1 ? 2 : 1);
  }

  void checkDifference() {
    if (player1Score >= (targetPoints - 1) &&
        player2Score >= (targetPoints - 1)) {
      difference = true;
    }

    if (player1Score <= targetPoints || player2Score <= targetPoints) {
      difference = false;
    }
  }

  bool checkWinSetCondition() {
    if (player1Score >= targetPoints && player1Score >= player2Score + 2) {
      incrementSet(1);
    } else if (player2Score >= targetPoints && player2Score >= player1Score + 2) {
      incrementSet(2);
    } else {
      return false;
    }
    return true;
  }

  int checkMatchWinner() {
    int matchWinner = 0;
    
    if (player1Sets == (targetSets - 1) / 2 + 1) {
      matchWinner = 1;
    } else if (player2Sets == (targetSets - 1) / 2 + 1) {
      matchWinner = 2;
    }

    return matchWinner;
  }
}
