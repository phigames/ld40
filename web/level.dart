part of ld40;

class Level extends DisplayObjectContainer {

  static const num GROUND_Y = 500;
  static const num ACTIVE_Y = 300;

  num _playerScale;
  Foot _leftFoot, _rightFoot;
  Foot _activeFoot;

  Level() {
    _playerScale = 1;
    _leftFoot = new Foot(Color.Red);
    _rightFoot = new Foot(Color.Blue);
    _activeFoot = _leftFoot;
    addChild(_leftFoot);
    addChild(_rightFoot);
  }

  void onSpaceDown() {
    game.stage.juggler.addTween(_activeFoot, 0.1)
        ..animate.y.to(GROUND_Y);
    _activeFoot = _activeFoot == _leftFoot ? _rightFoot : _leftFoot;
    game.stage.juggler.addTween(_activeFoot, 0.4)
      ..delay = 0.1
      ..animate.y.to(ACTIVE_Y);
  }

  void scroll(num distance) {
    x -= distance;
  }

  void moveActiveFoot(num distance) {
    _activeFoot.x += distance;
  }

  void increasePlayerScale(num increase) {
    _playerScale += increase;
    _leftFoot.scaleX = _leftFoot.scaleY = _playerScale;
    _rightFoot.scaleX = _rightFoot.scaleY = _playerScale;
  }

  void update(num passedTime) {
    scroll(100 * passedTime);
    moveActiveFoot(150 * passedTime);
    //increasePlayerScale(0.1 * passedTime);
  }

}