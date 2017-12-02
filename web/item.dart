part of ld40;

abstract class Item extends Sprite {

  bool dead;

  Item(Level level, BitmapData bitmapData) {
    dead = false;
    x = Game.WIDTH - level.x + 1000;
    y = Level.GROUND_Y - 50;
    addChild(new Bitmap(bitmapData));
  }

  void onCollide(Player player);

}

class FoodItem extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('test');

  FoodItem(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.grow();
    dead = true;
    print(dead);
  }

}