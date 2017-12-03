part of ld40;

class Level extends DisplayObjectContainer {

  static final List<int> BACKGROUND_COLORS = [ 0xFFBBDDFF, 0xFFDDBBDD, 0xFFDD9999 ];
  static const int PROGRESS_BAR_COLOR = 0xFF22CC22;
  static const num GROUND_Y = 500;
  static const num END_DISTANCE = 30000;

  Shape _backgroundColorShape;
  int _oldBackgroundColor;
  int _targetBackgroundColor;
  num _backgroundColorTime;
  Sprite _floor;
  Sprite _background;
  num _parallaxDistance;
  Sprite _levelContainer;
  Player _player;
  List<Item> _items;
  num _destroyedCacti, _destroyedCars, _destroyedHouses;
  num _playingTime;
  num _shakeTime;
  Sprite _progressBar;
  Shape _progressBarHead;
  int _playerSize;
  bool _won;
  bool _spaceDown;
  Sound _firstLoop, _secondLoop, _thirdLoop;
  SoundChannel _activeLoopChannel;

  Level() {
    _backgroundColorShape = new Shape();
    _oldBackgroundColor = BACKGROUND_COLORS[0];
    _targetBackgroundColor = BACKGROUND_COLORS[0];
    _backgroundColorTime = 0;
    _updateBackgroundColor(0, true);
    addChild(_backgroundColorShape);

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

    _destroyedCacti = _destroyedCars = _destroyedHouses = 0;
    _playingTime = 0;

    _shakeTime = 0;

    _progressBar = new Sprite();
    addChild(_progressBar);
    _progressBarHead = new Shape();
    _progressBar.addChild(_progressBarHead);
    _drawProgressBarHead(_progressBarHead.graphics);
    _updateProgressBar(_progressBar.graphics);

    // instructions
    _addItem(new MagicPotion(this, Game.WIDTH + 100, 0.1));
    _addItem(new Cactus(this, Game.WIDTH + 600));
    _background.addChild(
        new TextField('What a beautiful day!', new TextFormat(Game.FONT, 50, 0xFF222222))
          ..x = 150
          ..y = 50
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ This is you.', new TextFormat(Game.FONT, 30, 0xFF222222))
          ..x = 90
          ..y = 370
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('Press [SPACE] or click to take a step.', new TextFormat(Game.FONT, 30, 0xFFDDDDDD))
          ..x = 150
          ..y = Game.HEIGHT - 70
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ I wonder what this potion\n     would do to you...', new TextFormat(Game.FONT, 30, 0xFF222222))
          ..x = Game.WIDTH + 115
          ..y = 350
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ Don\'t step on this!', new TextFormat(Game.FONT, 30, 0xFF222222))
          ..x = Game.WIDTH + 610
          ..y = 380
          ..width = Game.WIDTH);

    // goal
    _addItem(new Goal(this, END_DISTANCE));

    _playerSize = 0;

    _won = false;

    _spaceDown = false;

    _firstLoop = resourceManager.getSound('first');
    _secondLoop = resourceManager.getSound('second');
    _thirdLoop = resourceManager.getSound('third');
    _playLoop(_firstLoop);
  }

  void _addItem(Item item) {
    _items.add(item);
    _levelContainer.addChild(item);
  }

  void _removeItem(Item item) {
    _items.remove(item);
    _levelContainer.removeChild(item);
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

  void _checkItemCollisions() {
    for (int i = 0; i < _items.length; i++) {
      Item item = _items[i];
      if (!item.broken && _player.steppedOn(item)) {
        item.onCollide(_player, _playerSize);
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
    if (random.nextDouble() < distanceScrolled * 0.003 / (_playerSize + 1)) {
      _addItem(new MagicPotion(this));
    }
    if (_playerSize >= 2) {
      if (random.nextDouble() < distanceScrolled * 0.0003) {
        _addItem(new House(this));
      }
    } else if (_playerSize == 1) {
      if (random.nextDouble() < distanceScrolled * 0.0005) {
        _addItem(new Car(this));
      }
    } else if (_playerSize == 0) {
      if (random.nextDouble() < distanceScrolled * 0.002) {
        _addItem(new Cactus(this));
      }
    }
  }

  void _updatePlayerSize() {
    if (_player.scaleY >= 1) {
      if (_playerSize != 2) {
        _playerSize = 2;
        _playLoop(_thirdLoop);
        _targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        _backgroundColorTime = 1.0;
      }
    } else if (_player.scaleY >= 0.5) {
      if (_playerSize != 1) {
        _playerSize = 1;
        _playLoop(_secondLoop);
        _targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        _backgroundColorTime = 1.0;
      }
    } else {
      if (_playerSize != 0) {
        _playerSize = 0;
        _playLoop(_firstLoop);
        _targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        _backgroundColorTime = 1.0;
      }
    }
  }

  void _updateBackgroundColor(num passedTime, [bool force = false]) {
    if (_backgroundColorTime > 0 || force) {
      _backgroundColorTime -= passedTime;
      if (_backgroundColorTime < 0) {
        _oldBackgroundColor = _targetBackgroundColor;
        _backgroundColorTime = 0;
      }
      _backgroundColorShape.graphics.clear();
      _backgroundColorShape.graphics.beginPath();
      _backgroundColorShape.graphics.rect(0, 0, Game.WIDTH, Game.HEIGHT);
      _backgroundColorShape.graphics.fillColor(_interpolateColor(_oldBackgroundColor, _targetBackgroundColor, _backgroundColorTime));
    }
  }

  int _interpolateColor(int color1, int color2, num ratio) {
    int a1 = (color1 & 0xFF000000) >> 24;
    int r1 = (color1 & 0x00FF0000) >> 16;
    int g1 = (color1 & 0x0000FF00) >> 8;
    int b1 = (color1 & 0x000000FF);
    int a2 = (color2 & 0xFF000000) >> 24;
    int r2 = (color2 & 0x00FF0000) >> 16;
    int g2 = (color2 & 0x0000FF00) >> 8;
    int b2 = (color2 & 0x000000FF);
    int a = (a1 * ratio + a2 * (1 - ratio)).round();
    int r = (r1 * ratio + r2 * (1 - ratio)).round();
    int g = (g1 * ratio + g2 * (1 - ratio)).round();
    int b = (b1 * ratio + b2 * (1 - ratio)).round();
    return (((((a << 8) + r) << 8) + g) << 8) + b;
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
      graphics.fillColor(0x11888888);
    }
    for (int i = 0; i < 15; i++) {
      randomRect();
    }
  }

  void _drawProgressBarHead(Graphics graphics) {
    graphics.beginPath();
    graphics.circle(0, 15, 15);
    graphics.fillColor(Player.SKIN_COLOR);
    graphics.beginPath();
    graphics.circle(2, 7, 2);
    graphics.fillColor(Player.FACE_COLOR);
    graphics.beginPath();
    graphics.moveTo(7, 15);
    graphics.lineTo(15, 15);
    graphics.strokeColor(Player.FACE_COLOR, 4);
    graphics.beginPath();
    graphics.circle(7, 15, 2);
    graphics.fillColor(Player.FACE_COLOR);
  }

  void _updateProgressBar(Graphics graphics) {
    num progress = _player.x / END_DISTANCE;
    graphics.clear();
    graphics.beginPath();
    graphics.rect(0, 0, progress * Game.WIDTH, 30);
    graphics.fillColor(PROGRESS_BAR_COLOR);
    graphics.beginPath();
    graphics.rect(0, 0, Game.WIDTH, 30);
    graphics.strokeColor(0xFF222222, 2);
    _progressBarHead.x = progress * Game.WIDTH;
  }

  void _playLoop(Sound loop) {
    /*if (_player.scaleY >= 1.0) {
      _thirdLoop.play().onComplete.listen((_) => _playMusic());
    } else if (_player.scaleY >= 0.6) {
      _secondLoop.play().onComplete.listen((_) => _playMusic());
    } else {
      _firstLoop.play().onComplete.listen((_) => _playMusic());
    }*/
    if (_activeLoopChannel != null) {
      _activeLoopChannel.stop();
    }
    _activeLoopChannel = loop.play(true);
  }

  num get scrollX { return _levelContainer.x; }

  void _step() {
    _player.step();
    _checkItemCollisions();
    if (_playerSize >= 2) {
      _shakeTime = 0.5;
    }
  }

  void onWin() {
    if (!_won) {
      _won = true;
      addChild(
          new TextField('You made it!', new TextFormat(Game.FONT, 50, 0xFF222222))
            ..x = 150
            ..y = 50
            ..width = Game.WIDTH);
      addChild(
          new TextField('On your way to work, you destroyed', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 150
            ..y = 150
            ..width = Game.WIDTH);
      addChild(
          new TextField('$_destroyedCacti cact${_destroyedCacti == 1 ? 'us' : 'i'}', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 180
            ..y = 180
            ..width = Game.WIDTH);
      addChild(
          new TextField('$_destroyedCars car${_destroyedCars == 1 ? '' : 's'}', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 180
            ..y = 210
            ..width = Game.WIDTH);
      addChild(
          new TextField('$_destroyedHouses house${_destroyedHouses == 1 ? '' : 's'}', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 180
            ..y = 240
            ..width = Game.WIDTH);
      addChild(
          new TextField('You took ${_playingTime ~/ 60} min ${_playingTime.round() % 60} s.', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 150
            ..y = 300
            ..width = Game.WIDTH);
      addChild(
          new TextField('Thank you for playing!', new TextFormat(Game.FONT, 40, 0xFFDDDDDD))
            ..x = 100
            ..y = Game.HEIGHT - 80
            ..width = Game.WIDTH);
      addChild(
          new TextField('sophiakene & phi\nLudum Dare 40', new TextFormat(Game.FONT, 20, 0xFFDDDDDD))
            ..x = 550
            ..y = Game.HEIGHT - 80
            ..width = Game.WIDTH);
    }
  }

  void onCanvasClick(int button) {
    if (button == 0) {
      _step();
    }
  }

  void onCanvasKeyDown(int keyCode) {
    if (keyCode == html.KeyCode.SPACE && !_spaceDown) {
      _spaceDown = true;
      _step();
    }
  }

  void onCanvasKeyUp(int keyCode) {
    if (keyCode == html.KeyCode.SPACE) {
      _spaceDown = false;
    }
  }

  void onCanvasTouch() {
    _step();
  }

  void update(num passedTime) {
    _playingTime += passedTime;
    _scroll(passedTime);
    _player.update(passedTime);
    _checkItemsOffScreen();
    _updateProgressBar(_progressBar.graphics);
    _updatePlayerSize();
    if (_shakeTime > 0) {
      _shakeTime -= passedTime;
      if (_shakeTime < 0) {
        _shakeTime = 0;
      }
      y = sin(_shakeTime * 20) * 50 * _shakeTime;
    }
    _updateBackgroundColor(passedTime);
  }

}