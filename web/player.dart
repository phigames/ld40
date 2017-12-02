part of ld40;

class Player extends Sprite {

  Foot _leftFoot, _rightFoot;
  Foot _activeFoot, _inactiveFoot;

  Player() {
    x = 100;
    y = Level.GROUND_Y;
    scaleX = scaleY = 0.1;
    _leftFoot = new Foot();
    _rightFoot = new Foot();
    _activeFoot = null;
    _inactiveFoot = null;
    addChild(_leftFoot);
    addChild(_rightFoot);
  }

  void step() {
    if (_activeFoot == null || _inactiveFoot == null) {
      _activeFoot = _leftFoot;
      _inactiveFoot = _rightFoot;
    }
    game.stage.juggler.addTween(_activeFoot, 0.1)
      ..animate.y.to(Foot.INACTIVE_Y)
      ..animate.rotation.to(Foot.INACTIVE_ROTATION);
    game.stage.juggler.addTween(_inactiveFoot, 0.2, Transition.easeOutCubic)
    //..delay = 0.1
      ..animate.y.to(Foot.ACTIVE_Y)
      ..animate.rotation.to(Foot.ACTIVE_ROTATION);
    Foot temp = _activeFoot;
    _activeFoot = _inactiveFoot;
    _inactiveFoot = temp;
  }

  bool steppedOn(Item item) {
    num footX = _inactiveFoot.hitboxX * scaleX + x;
    num footWidth = _inactiveFoot.hitboxWidth * scaleX;
    return footX < item.x + item.width && footX + footWidth > item.x;
  }

  void grow(num amount) {
    game.stage.juggler.addTween(this, 0.5, Transition.easeOutQuadratic)
      ..animate.scaleX.by(amount)
      ..animate.scaleY.by(amount);
  }

  void shrink(num amount) {
    game.stage.juggler.addTween(this, 0.5, Transition.easeOutQuadratic)
      ..animate.scaleX.by(max(-0.2, amount - scaleX))
      ..animate.scaleY.by(max(-0.2, amount - scaleY));
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

    // left leg
    graphics.beginPath();
    graphics.moveTo(50, -325);
    // ridiculous hack because I'm too lazy to figure out rotational geometry
    graphics.lineTo(_leftFoot.x + 25, _leftFoot.y + (_leftFoot == _activeFoot ? -25 : 25));
    graphics.strokeColor(Color.CornflowerBlue, 50);

    // right leg
    graphics.beginPath();
    graphics.moveTo(50, -325);
    // ridiculous hack because I'm too lazy to figure out rotational geometry
    graphics.lineTo(_rightFoot.x + 25, _rightFoot.y + (_rightFoot == _activeFoot ? -25 : 25));
    graphics.strokeColor(Color.CornflowerBlue, 50);

    // body
    graphics.beginPath();
    graphics.rect(0, -700, 100, 400);
    graphics.fillColor(Color.Coral);

    // arm
    graphics.beginPath();
    graphics.moveTo(50, -600);
    graphics.lineTo(50, -350);
    graphics.strokeColor(Color.OrangeRed, 50);

    // head
    graphics.beginPath();
    graphics.circle(50, -750, 100);
    graphics.fillColor(Color.Bisque);
  }

  void update(num passedTime) {
    if (_activeFoot != null && _inactiveFoot != null) {
      num maxDiff = 600 / sqrt(scaleX);
      num feetDifference = _activeFoot.x - (_activeFoot == _leftFoot ? _rightFoot.x : _leftFoot.x) - maxDiff;
      if (feetDifference < 0) {
        num moveSpeed = scaleX * scaleX * 10;
        _moveActiveFoot(moveSpeed * feetDifference * feetDifference * passedTime * 0.0004); // quadratic
        //_moveActiveFoot(moveSpeed * -feetDifference * passedTime); // linear
      }
    }
    _updateGraphics();
  }

}