part of ld40;

class Player extends Sprite {

  Foot _leftFoot, _rightFoot;
  Foot _activeFoot, _inactiveFoot;

  Player() {
    y = Level.GROUND_Y;
    scaleX = scaleY = 0.1;
    _leftFoot = new Foot(Color.Black, true);
    _rightFoot = new Foot(Color.Black, false);
    _activeFoot = _leftFoot;
    _inactiveFoot = _rightFoot;
    addChild(_leftFoot);
    addChild(_rightFoot);
  }

  void step() {
    game.stage.juggler.addTween(_activeFoot, 0.1)
      ..animate.y.to(Foot.INACTIVE_Y);
    game.stage.juggler.addTween(_inactiveFoot, 0.2, Transition.easeOutCubic)
    //..delay = 0.1
      ..animate.y.to(Foot.ACTIVE_Y);
    Foot temp = _activeFoot;
    _activeFoot = _inactiveFoot;
    _inactiveFoot = temp;
  }

  void _moveActiveFoot(num distance) {
    if (_activeFoot.x < _inactiveFoot.x) {
      x += distance;
      _inactiveFoot.x -= distance / scaleX; // always move independent of player scale
      if (_inactiveFoot.x < 0) {
        _inactiveFoot.x = 0;
      }
    } else {
      _activeFoot.x += distance / scaleX; // always move independent of player scale
    }
  }

  void _updateGraphics() {
    graphics.clear();
    graphics.rect(0, -700, 100, 400);
    graphics.fillColor(Color.Black);
    graphics.beginPath();
    graphics.moveTo(50, -325);
    graphics.lineTo(_leftFoot.x + 25, _leftFoot.y + 25);
    graphics.strokeColor(Color.Black, 50);
    graphics.beginPath();
    graphics.moveTo(50, -325);
    graphics.lineTo(_rightFoot.x + 25, _rightFoot.y + 25);
    graphics.strokeColor(Color.Black, 50);
  }

  void update(num passedTime) {
    num maxDiff = 0.7 * Game.WIDTH;
    num feetDifference = _activeFoot.x - (_activeFoot == _leftFoot ? _rightFoot.x : _leftFoot.x) - maxDiff;
    if (feetDifference < 0) {
      num moveSpeed = 1;
      //moveActiveFoot(moveSpeed * feetDifference * feetDifference * passedTime * 0.01); // quadratic
      _moveActiveFoot(moveSpeed * -feetDifference * passedTime);
    }
    scaleX = scaleY += 0.01;
    _updateGraphics();
  }

}