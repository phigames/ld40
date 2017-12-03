part of ld40;

class Player extends Sprite {

  static const num MIN_SCALE = 0.1;
  static const int SKIN_COLOR = 0xFFFFE4C4;
  static const int FACE_COLOR = 0xFF555555;
  static const int SHIRT_COLOR = 0xFFFF5520;
  static const int SHIRT_COLOR_DARK = 0xFFE04510;
  static const int PANTS_COLOR = 0xFF5485ED;
  static const int SHOES_COLOR = 0xFFA05A2C;

  num _targetScale;
  num _blinkTime;
  Sprite _leftLeg; // must be drawn before left foot, thus separate
  Sprite _body;
  Foot _leftFoot, _rightFoot;
  Foot _activeFoot, _inactiveFoot;

  Player() {
    x = 100;
    y = Level.GROUND_Y;
    scaleX = scaleY = _targetScale = MIN_SCALE;
    //scaleX = scaleY = _targetScale = 1.0;
    _blinkTime = 0;
    _leftLeg = new Sprite();
    _body = new Sprite();
    _leftFoot = new Foot();
    _rightFoot = new Foot();
    _activeFoot = null;
    _inactiveFoot = null;
    _drawBody();
    addChild(_leftLeg);
    addChild(_leftFoot);
    addChild(_body);
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
    _targetScale += amount;
    game.stage.juggler.addTween(this, 0.5, Transition.easeOutQuadratic)
      ..animate.scaleX.to(_targetScale)
      ..animate.scaleY.to(_targetScale);
  }

  void shrink(num amount) {
    _targetScale = max(_targetScale - amount, MIN_SCALE);
    game.stage.juggler.addTween(this, 0.5, Transition.easeOutQuadratic)
      ..animate.scaleX.to(_targetScale)
      ..animate.scaleY.to(_targetScale);
    _blinkTime = 0.8;
  }

  num get activeFootPosition {
    if (_activeFoot != null) {
      return x + _activeFoot.hitboxX * scaleX + _activeFoot.hitboxWidth * scaleX;
    } else {
      return x + _leftFoot.hitboxX * scaleX + _leftFoot.hitboxWidth * scaleX;
    }
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

  void _drawBody() {
    _leftLeg.graphics.clear();
    _body.graphics.clear();

    // left leg
    _leftLeg.graphics.beginPath();
    _leftLeg.graphics.moveTo(50, -325);
    // ridiculous hack because I'm too lazy to figure out rotational geometry
    _leftLeg.graphics.lineTo(_leftFoot.x + 25, _leftFoot.y + (_leftFoot == _activeFoot ? -25 : 25));
    _leftLeg.graphics.strokeColor(PANTS_COLOR, 50, JointStyle.ROUND, CapsStyle.ROUND);

    // left arm
    num leftHandX = sin(sqrt(_rightFoot.hitboxX) / 20) * 200 + 50;
    num leftHandY = cos(sqrt(_rightFoot.hitboxX) / 20) * 200 - 600;
    _body.graphics.beginPath();
    _body.graphics.circle(leftHandX, leftHandY, 25);
    _body.graphics.fillColor(SKIN_COLOR);
    _body.graphics.beginPath();
    _body.graphics.moveTo(50, -600);
    _body.graphics.lineTo(leftHandX, leftHandY);
    _body.graphics.strokeColor(SHIRT_COLOR_DARK, 50);

    // body
    _body.graphics.beginPath();
    _body.graphics.rect(0, -700, 100, 350);
    _body.graphics.fillColor(SHIRT_COLOR);
    _body.graphics.beginPath();
    _body.graphics.circle(50, -350, 50);
    _body.graphics.fillColor(SHIRT_COLOR);

    // right arm
    num rightHandX = sin(sqrt(_leftFoot.hitboxX) / 20) * 200 + 50;
    num rightHandY = cos(sqrt(_leftFoot.hitboxX) / 20) * 200 - 600;
    _body.graphics.beginPath();
    _body.graphics.circle(rightHandX, rightHandY, 25);
    _body.graphics.fillColor(SKIN_COLOR);
    _body.graphics.beginPath();
    _body.graphics.moveTo(50, -600);
    _body.graphics.lineTo(rightHandX, rightHandY);
    _body.graphics.strokeColor(SHIRT_COLOR_DARK, 50);
    _body.graphics.beginPath();
    _body.graphics.circle(50, -600, 25);
    _body.graphics.fillColor(SHIRT_COLOR_DARK);

    // head
    _body.graphics.beginPath();
    _body.graphics.circle(50, -750, 100);
    _body.graphics.fillColor(SKIN_COLOR);
    _body.graphics.beginPath();
    _body.graphics.circle(75, -800, 10);
    _body.graphics.fillColor(FACE_COLOR);
    _body.graphics.beginPath();
    _body.graphics.moveTo(100, -750);
    _body.graphics.lineTo(150, -750);
    _body.graphics.strokeColor(FACE_COLOR, 20);
    _body.graphics.beginPath();
    _body.graphics.circle(100, -750, 10);
    _body.graphics.fillColor(FACE_COLOR);

    // right leg
    _body.graphics.beginPath();
    _body.graphics.moveTo(50, -325);
    // ridiculous hack because I'm too lazy to figure out rotational geometry
    _body.graphics.lineTo(_rightFoot.x + 25, _rightFoot.y + (_rightFoot == _activeFoot ? -25 : 25));
    _body.graphics.strokeColor(PANTS_COLOR, 50, JointStyle.ROUND, CapsStyle.ROUND);
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
    if (_blinkTime > 0) {
      if ((_blinkTime * 6).ceil() % 2 == 0) {
        visible = false;
      } else {
        visible = true;
      }
      _blinkTime -= passedTime;
      if (_blinkTime < 0) {
        _blinkTime = 0;
        visible = true;
      }
    }
    _drawBody();
  }

}