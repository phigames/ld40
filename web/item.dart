part of ld40;

abstract class Item extends Sprite {

  bool dead;

  Item(Level level, BitmapData bitmapData) {
    dead = false;
    setBitmap(bitmapData);
    x = Game.WIDTH - level.scrollX + 1000;
  }

  void setBitmap(BitmapData bitmapData) {
    removeChildren();
    addChild(new Bitmap(bitmapData));
    y = Level.GROUND_Y - height;
  }

  void onCollide(Player player);

}

class MagicPotion extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('potion');

  MagicPotion(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.grow(0.1);
    dead = true;
    print(dead);
  }

}

class Cactus extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('cactus');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('car');

  bool broken;

  Cactus(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.2);
    broken = true;
    setBitmap(bitmapDataBroken);
  }

}

class Car extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('car');

  Car(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.3);
  }

}

class House extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('house');

  House(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.5);
  }

}