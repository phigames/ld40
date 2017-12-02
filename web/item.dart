part of ld40;

abstract class Item extends Sprite {

  Item(Level level, BitmapData bitmapData) {
    setBitmap(bitmapData);
    x = Game.WIDTH - level.scrollX + 300;
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
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('potion_broken');

  MagicPotion(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.grow(0.1);
    setBitmap(bitmapDataBroken);
  }

}

class Cactus extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('cactus');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('cactus_broken');

  bool broken;

  Cactus(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.2);
    setBitmap(bitmapDataBroken);
  }

}

class Car extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('car');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('car_broken');

  Car(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.3);
    setBitmap(bitmapDataBroken);
  }

}

class House extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('house');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('house_broken');

  House(Level level) : super(level, bitmapData);

  @override
  void onCollide(Player player) {
    player.shrink(0.5);
    setBitmap(bitmapDataBroken);
  }

}