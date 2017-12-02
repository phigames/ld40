part of ld40;

abstract class Item extends Sprite {

  bool dead;

  Item(BitmapData bitmapData) {
    dead = false;
    x = Game.WIDTH;
    y = Level.GROUND_Y - 50;
    addChild(new Bitmap(bitmapData));
  }

  void onCollide(Player player);

}

class FoodItem extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('test');

  FoodItem() : super(bitmapData) {

  }

  @override
  void onCollide(Player player) {
    player.grow();
    dead = true;
    print(dead);
  }

}