part of ld40;

class Foot extends Sprite {

  static const int WIDTH = 100;
  static const int HEIGHT = 50;

  Foot(int color) {
    graphics.rect(0, 0, WIDTH, HEIGHT);
    graphics.circle(WIDTH, HEIGHT / 2, HEIGHT / 2);
    graphics.fillColor(color);
  }

}