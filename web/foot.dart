part of ld40;

class Foot extends Sprite {

  static const int WIDTH = 100;
  static const int HEIGHT = 50;
  static const num ACTIVE_Y = -500;
  static const num INACTIVE_Y = -HEIGHT;
  static const num ACTIVE_ROTATION = -PI / 2;
  static const num INACTIVE_ROTATION = 0;

  num _hitboxX, _hitboxWidth;

  Foot() {
    graphics.beginPath();
    graphics.rect(50, 0, WIDTH, HEIGHT);
    graphics.circle(WIDTH + 50, HEIGHT / 2, HEIGHT / 2);
    graphics.fillColor(Color.Brown);
    y = INACTIVE_Y;
    rotation = INACTIVE_ROTATION;
    pivotX = 50;
    pivotY = 0;
    _hitboxX = 50;
    _hitboxWidth = WIDTH + 25;
  }

  num get hitboxX { return x + _hitboxX; }

  num get hitboxWidth { return _hitboxWidth; }

}