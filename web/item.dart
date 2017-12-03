part of ld40;

abstract class Item extends Sprite {

  Level level;
  bool broken;

  Item(this.level, BitmapData bitmapData, [num x = null]) {
    broken = false;
    setBitmap(bitmapData);
    if (x == null) {
      this.x = Game.WIDTH - level.scrollX + 300;
    } else {
      this.x = x;
    }
  }

  void setBitmap(BitmapData bitmapData) {
    removeChildren();
    addChild(new Bitmap(bitmapData));
    y = Level.GROUND_Y - height;
  }

  void onCollide(Player player, int playerSize);

}

class MagicPotion extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('potion');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('potion_broken');

  num growAmount;

  MagicPotion(Level level, [num x = null, this.growAmount = 0.05]) : super(level, bitmapData, x);

  @override
  void onCollide(Player player, int playerSize) {
    broken = true;
    player.grow(growAmount);
    setBitmap(bitmapDataBroken);
  }

}

class Cactus extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('cactus');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('cactus_broken');

  bool broken;

  Cactus(Level level, [num x = null]) : super(level, bitmapData, x);

  @override
  void onCollide(Player player, int playerSize) {
    broken = true;
    player.shrink(0.1);
    setBitmap(bitmapDataBroken);
    level._destroyedCacti++;
  }

}

class Car extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('car');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('car_broken');

  Car(Level level, [num x = null]) : super(level, bitmapData, x);

  @override
  void onCollide(Player player, int playerSize) {
    //if (playerSize >= 1) {
      broken = true;
      player.shrink(0.3);
      setBitmap(bitmapDataBroken);
      level._destroyedCars++;
    //}
  }

}

class House extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('house');
  static BitmapData bitmapDataBroken = resourceManager.getBitmapData('house_broken');

  House(Level level, [num x = null]) : super(level, bitmapData, x);

  @override
  void onCollide(Player player, int playerSize) {
    //if (playerSize >= 2) {
      broken = true;
      player.shrink(0.8);
      setBitmap(bitmapDataBroken);
      level._destroyedHouses++;
    //}
  }

}

class Goal extends Item {

  static BitmapData bitmapData = resourceManager.getBitmapData('goal');

  Goal(Level level, num x) : super(level, bitmapData, x);

  @override
  void onCollide(Player player, int playerSize) {
    level.onWin();
  }

}