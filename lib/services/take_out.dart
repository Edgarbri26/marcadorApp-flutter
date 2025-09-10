class TakeOut {
  bool player1 = false;
  bool player2 = false;
  bool difference = false;
  bool remove = false;
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

  void undoHistory() {
    int lastScore = 0;

    if (historyTakeOut.isNotEmpty) {
      !remove ? historyTakeOut.removeLast() : null;
      lastScore = historyTakeOut.removeLast();
      remove = true;
    }
    if (historyTakeOut.isEmpty) {
      reset();
      return;
    }

    if (lastScore == 2) {
      player1 = false;
      player2 = true;
      playerTurn = 2;
    } else if (lastScore == 1) {
      player1 = true;
      player2 = false;
      playerTurn = 1;
    }

    // print('player 1 $player1 y player 2 $player2 turno $playerTurn');
  }

  void incremen(int numPlayer) {
    if (counter == 0 && !player1 && !player2) {
      playerTurn = numPlayer;
      _addHistory();
      init(numPlayer);
      return;
    }

    if (player1 || player2) {
      counter++;
      remove = false;
      _verifyChange();
    }
  }

  void decremen() {
    if (counter == 0) {
      counter = 2;
    }
    undoHistory();
    counter--;
    // print('count $counter');
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
    remove = false;
    difference = false;
    playerTurn = 0;
    counter = 0;
    historyTakeOut.clear();
  }
}
