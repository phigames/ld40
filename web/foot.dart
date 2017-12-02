part of ld40;

class Foot extends Sprite {

  static const int WIDTH = 100;
  static const int HEIGHT = 50;
  static const num ACTIVE_Y = -200;
  static const num INACTIVE_Y = -HEIGHT;

  Foot(int color, bool active) {
    graphics.rect(0, 0, WIDTH, HEIGHT);
    graphics.circle(WIDTH, HEIGHT / 2, HEIGHT / 2);
    graphics.fillColor(color);
    if (active) {
      y = ACTIVE_Y;
    } else {
      y = INACTIVE_Y;
    }
  }

}