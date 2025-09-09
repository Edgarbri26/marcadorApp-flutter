class TakeOut {
  bool player1 = false;
  bool player2 = false;
  bool difference = false;
  int counter = 0;

  void init(int numPlayer) {
    if (numPlayer == 1) {
      player1 = true;
    } else {
      player2 = true;
    }
  }

  void incremen(int numPlayer) {
    if (counter == 0 && !player1 && !player2) {
      init(numPlayer);
    }
    counter++;
    verifyChange();
  }

  void decremen() {
    if (counter == 0) {
      if (player1) {
        player1 = false;
        player2 = true;
      } else {
        player1 = true;
        player2 = false;
      }
      return;
    }

    counter--;
  }

  void verifyChange() {
    if (counter == 2 && !difference) {
      counter = 0;
      if (player1) {
        player1 = false;
        player2 = true;
      } else {
        player1 = true;
        player2 = false;
      }
    } else {
      if (player1) {
        player1 = false;
        player2 = true;
      } else {
        player1 = true;
        player2 = false;
      }
    }
  }

  void reset() {
    player1 = false;
    player2 = false;
    difference = false;
    counter = 0;
  }
}
