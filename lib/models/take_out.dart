class TakeOut {
  bool player1 = false;
  bool player2 = false;
  bool difference = false;
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

  void _undoHistory() {
    int lastScore = 0;

    if (historyTakeOut.isNotEmpty) {
      lastScore = historyTakeOut.removeLast();
      print(historyTakeOut);
    } else if (lastScore == 2) {
      player1 = false;
      player2 = true;
      playerTurn = 2;
    } else if (lastScore == 1) {
      player1 = true;
      player2 = false;
      playerTurn = 1;
    } else {
      reset();
    }
  }

  void incremen(int numPlayer) {
    if (counter == 0 && playerTurn == 0) {
      playerTurn = numPlayer;
      _addHistory();
      init(numPlayer);
      print(historyTakeOut);
      return;
    }
    counter++;
    _verifyChange();
    print(historyTakeOut);
  }

  void decremen() {
    if (counter == 0) {
      counter = 2;
    }
    _undoHistory();
    counter--;
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
    difference = false;
    playerTurn = 0;
    counter = 0;
    historyTakeOut.clear();
  }
}
