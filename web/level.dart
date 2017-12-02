part of ld40;

class Level extends DisplayObjectContainer {

  static const num GROUND_Y = 500;

  Player player;

  Level() {
    player = new Player();
    addChild(player);
  }

  void onCanvasClick(int button) {
    if (button == 0) {
      player.step();
    }
  }

  void onCanvasKeyDown(int keyCode) {
    if (keyCode == html.KeyCode.SPACE) {
      player.step();
    }
  }

  void scroll(num distance) {
    x -= distance;
  }

  void update(num passedTime) {
    scroll(300 * passedTime);
    //increasePlayerScale(0.1 * passedTime);
    player.update(passedTime);
  }

}