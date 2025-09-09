class Marker {
  int player1Score = 0;
  int player2Score = 0;
  int player1Sets = 0;
  int player2Sets = 0;
  int targetPoints = 7;
  int targetSets = 1;
  List<int> scoreHistory = [];

  Marker();

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

      if (lastScore == -1 && player1Score < targetPoints) {
        player1Score++;
      } else if (lastScore == -2 && player2Score < targetPoints) {
        player2Score++;
      }
    }
  }

  void incrementScore(int player) {
    if (player == 1) {
      player1Score++;
    } else {
      player2Score++;
    }
    scoreHistoryAdd(player);
  }

  void incrementSet(int player) {
    if (player == 1) {
      player1Sets++;
    } else {
      player2Sets++;
    }
    scoreHistoryAdd(player);
  }

  void decrementScore(int player) {
    if (player == 1 && player1Score > 0) {
      player1Score--;
    } else if (player == 2 && player2Score > 0) {
      player2Score--;
    }
    scoreHistoryAdd(-player);
  }

  void resetScores() {
    player1Score = 0;
    player2Score = 0;
    scoreHistory.clear();
  }

  void resetAll() {
    player1Score = 0;
    player2Score = 0;
    player1Sets = 0;
    player2Sets = 0;
    scoreHistory.clear();
  }
}
