part of ld40;

class Level extends DisplayObjectContainer {

  static const num GROUND_Y = 500;

  Player _player;
  List<Item> _items;
  num _scrollSpeed;

  Level() {
    _player = new Player();
    addChild(_player);
    _items = new List<Item>();
    _scrollSpeed = 200;
  }

  void _addItem(Item item) {
    _items.add(item);
    addChild(item);
  }

  void _removeItem(Item item) {
    _items.remove(item);
    removeChild(item);
  }

  void _checkItemCollisions() {
    for (int i = 0; i < _items.length; i++) {
      Item item = _items[i];
      if (_player.steppedOn(item)) {
        item.onCollide(_player);
        if (item.dead) {
          _removeItem(item);
          i--;
        }
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

  void scroll(num distance) {
    x -= distance;
  }

  void update(num passedTime) {
    if (random.nextDouble() < passedTime) {
      _addItem(new FoodItem(this));
    }
    scroll(_scrollSpeed * passedTime);
    _player.update(passedTime);
    _checkItemsOffScreen();
  }

}