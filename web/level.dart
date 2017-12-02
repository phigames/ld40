part of ld40;

class Level extends DisplayObjectContainer {

  static const num GROUND_Y = 500;

  Sprite _background;
  num _parallaxDistance;
  Sprite _levelContainer;
  Player _player;
  List<Item> _items;

  Level() {
    _background = new Sprite();
    _parallaxDistance = 0;
    _drawBackground(_background.graphics);
    addChild(_background);
    _levelContainer = new Sprite();
    addChild(_levelContainer);
    _player = new Player();
    _levelContainer.addChild(_player);
    _items = new List<Item>();
  }

  void _drawBackground(Graphics graphics) {
    graphics.beginPath();
    void randomRect() {
      num randomX = random.nextInt(Game.WIDTH + 200) + Game.WIDTH - _background.x;
      num randomY = random.nextInt(GROUND_Y - 100);
      graphics.rect(randomX, randomY, random.nextInt(300) + 100, GROUND_Y - randomY);
      graphics.fillColor(0x22888888);
    }
    for (int i = 0; i < 5; i++) {
      randomRect();
    }
  }

  void _addItem(Item item) {
    _items.add(item);
    _levelContainer.addChild(item);
  }

  void _removeItem(Item item) {
    _items.remove(item);
    _levelContainer.removeChild(item);
  }

  void _checkItemCollisions() {
    for (int i = 0; i < _items.length; i++) {
      Item item = _items[i];
      if (_player.steppedOn(item)) {
        item.onCollide(_player);
      }
    }
  }

  void _checkItemsOffScreen() {
    for (int i = 0; i < _items.length; i++) {
      Item item = _items[i];
      if (item.x + item.width + x < 0) {
        _removeItem(item);
        i--;
      }
    }
  }

  num get scrollX { return _levelContainer.x; }

  void onCanvasClick(int button) {
    if (button == 0) {
      _player.step();
      _checkItemCollisions();
    }
  }

  void onCanvasKeyDown(int keyCode) {
    if (keyCode == html.KeyCode.SPACE) {
      _player.step();
      _checkItemCollisions();
    }
  }

  void _scroll(num passedTime) {
    //num distance = min(_player.x - 100 + _levelContainer.x, (_player.scaleX + 0.2) * 300 * passedTime);
    num targetDistance = max(_player.x - 100 + _levelContainer.x, 0);
    num distance = sqrt(targetDistance) * 40 * passedTime;
    _levelContainer.x -= distance;
    _background.x -= distance / 3; // parallax effect
    _parallaxDistance += distance / 3;
    if (_parallaxDistance > Game.WIDTH) {
      _drawBackground(_background.graphics);
      _parallaxDistance = 0;
    }
    if (random.nextDouble() < distance * 0.005) {
      _addItem(new MagicPotion(this));
    }
    if (random.nextDouble() < distance * 0.002) {
      _addItem(new Cactus(this));
    }
  }

  void update(num passedTime) {
    _scroll(passedTime);
    _player.update(passedTime);
    _checkItemsOffScreen();
  }

}