part of ld40;

class Level extends DisplayObjectContainer {

  static const num GROUND_Y = 500;
  static const num END_DISTANCE = 50000;

  Sprite _floor;
  Sprite _background;
  num _parallaxDistance;
  Sprite _levelContainer;
  Player _player;
  List<Item> _items;
  Sprite _progressBar;
  //Sprite _test;
  bool spaceDown;
  Sound firstLoop, secondLoop, thirdLoop;

  Level() {
    _floor = new Sprite();
    _drawFloor(_floor.graphics);
    addChild(_floor);

    _background = new Sprite();
    _parallaxDistance = 0;
    _drawBackgroundShapes(_background.graphics, 0);
    _drawBackgroundShapes(_background.graphics, Game.WIDTH);
    addChild(_background);

    _levelContainer = new Sprite();
    addChild(_levelContainer);
    _player = new Player();
    _levelContainer.addChild(_player);

    _items = new List<Item>();

    _progressBar = new Sprite();
    _updateProgressBar(_progressBar.graphics);
    addChild(_progressBar);

    // instructions
    _addItem(new MagicPotion(this, Game.WIDTH + 100, 0.1));
    _addItem(new Cactus(this, Game.WIDTH + 600));
    _background.addChild(
        new TextField('Welcome to ___', new TextFormat("sans-serif", 50, 0xFF222222))
          ..wordWrap = false
          ..x = 200
          ..y = 50
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ This is you.', new TextFormat("sans-serif", 30, 0xFF222222))
          ..wordWrap = false
          ..x = 90
          ..y = 370
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('Press [SPACE] or click to take a step.', new TextFormat("sans-serif", 30, 0xFFDDDDDD))
          ..wordWrap = false
          ..x = 150
          ..y = Game.HEIGHT - 50
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ I wonder what this potion\n     would do to you...', new TextFormat("sans-serif", 30, 0xFF222222))
          ..wordWrap = false
          ..x = Game.WIDTH + 110
          ..y = 350
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ Don\'t step on this!', new TextFormat("sans-serif", 30, 0xFF222222))
          ..wordWrap = false
          ..x = Game.WIDTH + 610
          ..y = 380
          ..width = Game.WIDTH);

    /*_test = new Sprite();
    _test.addChild(new Bitmap(resourceManager.getBitmapData('test')));
    _levelContainer.addChild(_test);*/

    spaceDown = false;

    firstLoop = resourceManager.getSound('first');
    secondLoop = resourceManager.getSound('second');
    thirdLoop = resourceManager.getSound('third');
    //firstLoop.play(false).onComplete.listen((_) => secondLoop.play(false).onComplete.listen((_) => thirdLoop.play(false)));
  }

  void _drawFloor(Graphics graphics) {
    graphics.beginPath();
    graphics.rect(0, GROUND_Y, Game.WIDTH, Game.HEIGHT - GROUND_Y);
    graphics.fillColor(0xFF222222);
  }

  void _drawBackgroundShapes(Graphics graphics, num offset) {
    graphics.beginPath();
    void randomRect() {
      num randomX = random.nextInt(Game.WIDTH + 200) + offset - _background.x;
      num randomY = random.nextInt(GROUND_Y - 100);
      graphics.rect(randomX, randomY, random.nextInt(100) + 100, GROUND_Y - randomY);
      graphics.fillColor(0x22888888);
    }
    for (int i = 0; i < 10; i++) {
      randomRect();
    }
  }

  void _updateProgressBar(Graphics graphics) {
    graphics.clear();
    graphics.beginPath();
    graphics.rect(0, 0, Game.WIDTH * _player.x / END_DISTANCE, 30);
    graphics.fillColor(0xFF22DD22);
    graphics.beginPath();
    graphics.rect(0, 0, Game.WIDTH, 30);
    graphics.strokeColor(0xFF222222);
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
      if (!item.broken && _player.steppedOn(item)) {
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

  void _spawnItems(num distanceScrolled) {
    if (random.nextDouble() < distanceScrolled * 0.0005 / _player.scaleX) {
      _addItem(new MagicPotion(this));
    }
    if (_player.scaleY >= 2) {
      if (random.nextDouble() < distanceScrolled * 0.0003) {
        _addItem(new House(this));
      }
    } else if (_player.scaleY >= 0.6) {
      if (random.nextDouble() < distanceScrolled * 0.0005) {
        _addItem(new Car(this));
      }
    } else if (_player.scaleY >= 0.1) {
      if (random.nextDouble() < distanceScrolled * 0.002) {
        _addItem(new Cactus(this));
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
    if (keyCode == html.KeyCode.SPACE && !spaceDown) {
      spaceDown = true;
      _player.step();
      _checkItemCollisions();
    }
  }

  void onCanvasKeyUp(int keyCode) {
    if (keyCode == html.KeyCode.SPACE) {
      spaceDown = false;
    }
  }

  void _scroll(num passedTime) {
    //num distance = min(_player.x - 100 + _levelContainer.x, (_player.scaleX + 0.2) * 300 * passedTime);
    num targetDistance = max(_player.x - 100 + _levelContainer.x, 0);
    num distance = sqrt(targetDistance) * 40 * passedTime;
    if (_player.activeFootPosition > -_levelContainer.x + distance + Game.WIDTH) { // active foot off-screen
      distance += _player.activeFootPosition - (-_levelContainer.x + distance + Game.WIDTH);
    }
    _levelContainer.x -= distance;
    _background.x -= distance / 3; // parallax effect
    _parallaxDistance += distance / 3;
    if (_parallaxDistance > Game.WIDTH) {
      _drawBackgroundShapes(_background.graphics, Game.WIDTH);
      _parallaxDistance = 0;
    }
    if (_levelContainer.x < -Game.WIDTH) { // tutorial done
      _spawnItems(distance);
    }
  }

  void update(num passedTime) {
    _scroll(passedTime);
    _player.update(passedTime);
    _checkItemsOffScreen();
    _updateProgressBar(_progressBar.graphics);
  }

}