part of ld40;

class Level extends DisplayObjectContainer {

  static final List<int> BACKGROUND_COLORS = [ 0xFFBBDDFF, 0xFFDD9999 ];
  static const int PROGRESS_BAR_COLOR = 0xFF22CC22;
  static const num GROUND_Y = 500;
  static const num END_DISTANCE = 45000;

  Shape _backgroundColorShape;
  int _oldBackgroundColor;
  int _targetBackgroundColor;
  num _backgroundColorTime;
  Sprite _floor;
  Sprite _background;
  num _parallaxDistance;
  Sprite _levelContainer;
  Player _player;
  bool _playerStepped;
  List<Item> _items;
  num _lastItemPosition;
  num _destroyedCacti, _destroyedCars, _destroyedHouses;
  num _playingTime;
  bool _playing;
  num _shakeTime;
  Sprite _progressBar;
  Shape _progressBarHead;
  TextField _timer;
  int _playerSize;
  bool _won;
  bool _spaceDown;
  Sound _loop, _loopHurry;
  SoundChannel _activeLoopChannel;
  Sound _stampfSound;
  Sound _endSound;

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
    _playerStepped = false;

    _items = new List<Item>();
    _lastItemPosition = 0;

    _destroyedCacti = _destroyedCars = _destroyedHouses = 0;
    _playingTime = -120;
    //_playingTime = -4;
    _playing = false;

    _shakeTime = 0;

    _progressBar = new Sprite();
    addChild(_progressBar);
    _progressBarHead = new Shape();
    _progressBar.addChild(_progressBarHead);
    _drawProgressBarHead(_progressBarHead.graphics);
    _updateProgressBar(_progressBar.graphics);

    _timer = new TextField('', new TextFormat(Game.FONT, 30, 0xFF222222)..bold = true)
      ..x = Game.WIDTH - 220
      ..y = 60
      ..width = Game.WIDTH;
    addChild(_timer);

    // instructions
    _addItem(new MagicPotion(this, Game.WIDTH + 100, 0.1));
    _addItem(new Cactus(this, Game.WIDTH + 600));
    _background.addChild(
        new TextField('Hurry up, school starts at 8! ▶', new TextFormat(Game.FONT, 40, 0xFF222222))
          ..x = 30
          ..y = 50
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ This is Guy.', new TextFormat(Game.FONT, 30, 0xFF222222))
          ..x = 90
          ..y = 370
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('Press [SPACE] or click to take a step.', new TextFormat(Game.FONT, 30, 0xFFDDDDDD))
          ..x = 150
          ..y = Game.HEIGHT - 70
          ..width = Game.WIDTH);
    _levelContainer.addChild(
        new TextField('▼ Oh look, a magic potion!', new TextFormat(Game.FONT, 30, 0xFF222222))
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

    _loop = resourceManager.getSound('loop');
    _loopHurry = resourceManager.getSound('loop_hurry');
    _stampfSound = resourceManager.getSound('stampf');
    _endSound = resourceManager.getSound('end');
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
    if (_lastItemPosition < -_levelContainer.x + Game.WIDTH - 50) {
      if (_playerSize >= 2) {
        if (random.nextDouble() < distanceScrolled * 0.0007) {
          _addItem(new House(this));
          _lastItemPosition = Game.WIDTH - _levelContainer.x + 250;
          return;
        }
      }
      if (_playerSize >= 1) {
        if (random.nextDouble() < distanceScrolled * 0.001) {
          _addItem(new Car(this));
          _lastItemPosition = Game.WIDTH - _levelContainer.x + 200;
          return;
        }
      } else if (_playerSize == 0) {
        if (random.nextDouble() < distanceScrolled * 0.002) {
          _addItem(new Cactus(this));
          _lastItemPosition = Game.WIDTH - _levelContainer.x + 50;
          return;
        }
      }
      if (random.nextDouble() < distanceScrolled * 0.001 * (3 - _playerSize)) {
        _addItem(new MagicPotion(this));
        _lastItemPosition = Game.WIDTH - _levelContainer.x + 50;
        return;
      }
    }
  }

  void _updatePlayerSize() {
    if (_player.scaleY >= 0.8) {
      if (_playerSize != 2) {
        _playerSize = 2;
        //_playLoop(_thirdLoop);
        //_targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        //_backgroundColorTime = 1.0;
      }
    } else if (_player.scaleY >= 0.5) {
      if (_playerSize != 1) {
        _playerSize = 1;
        //_playLoop(_secondLoop);
        //_targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        //_backgroundColorTime = 1.0;
      }
    } else {
      if (_playerSize != 0) {
        _playerSize = 0;
        //_playLoop(_firstLoop);
        //_targetBackgroundColor = BACKGROUND_COLORS[_playerSize];
        //_backgroundColorTime = 1.0;
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
    graphics.rect(0, 0, Game.WIDTH, 30);
    graphics.fillColor(0xFF222222);
    graphics.beginPath();
    graphics.rect(0, 0, progress * Game.WIDTH, 30);
    graphics.fillColor(PROGRESS_BAR_COLOR);
    _progressBarHead.x = progress * Game.WIDTH;
  }

  void _playLoop(Sound loop/*, [num positionFactor = null]*/) {
    /*if (_player.scaleY >= 1.0) {
      _thirdLoop.play().onComplete.listen((_) => _playMusic());
    } else if (_player.scaleY >= 0.6) {
      _secondLoop.play().onComplete.listen((_) => _playMusic());
    } else {
      _firstLoop.play().onComplete.listen((_) => _playMusic());
    }*/
    num position = 0;
    if (_activeLoopChannel != null) {
      /*if (positionFactor != null) {
        position = _activeLoopChannel.position * positionFactor;
      }*/
      _activeLoopChannel.stop();
    }
    _activeLoopChannel = loop.play(true)..position = position;
  }

  num get scrollX { return _levelContainer.x; }

  void _step() {
    if (!_playing && !_won) {
      _playing = true;
      _playLoop(_loop);
    }
    _player.step();
    _checkItemCollisions();
    if (_playerSize >= 2) {
      _shakeTime = 0.5;
      _stampfSound.play();
    }
  }

  void onWin() {
    if (!_won) {
      _won = true;
      _playing = false;
      if (_activeLoopChannel != null) {
        _activeLoopChannel.stop();
      }
      _endSound.play();
      removeChild(_timer);
      addChild(
          new TextField('Guy finally arrived at school!', new TextFormat(Game.FONT, 50, 0xFF222222))
            ..x = 70
            ..y = 50
            ..width = Game.WIDTH);
      addChild(
          new TextField('On his way he demolished', new TextFormat(Game.FONT, 30, 0xFF222222))
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
      if (_playingTime < 0) { // early
        addChild(
            new TextField('He is ${-_playingTime ~/ 60} min ${-_playingTime.round() % 60} s early.', new TextFormat(Game.FONT, 30, 0xFF222222)..bold = true)
              ..x = 150
              ..y = 300
              ..width = Game.WIDTH
              ..textColor = 0xFF008800);
        addChild(
            new TextField('Maybe he could\'ve finished watching that episode of Monty Python after all...', new TextFormat(Game.FONT, 15, 0xFF222222))
              ..x = 150
              ..y = 330
              ..width = Game.WIDTH);
      } else { // late
        addChild(
            new TextField('He is ${_playingTime ~/ 60} min ${_playingTime.round() % 60} s late.', new TextFormat(Game.FONT, 30, 0xFF222222)..bold = true)
              ..x = 150
              ..y = 300
              ..width = Game.WIDTH
              ..textColor = 0xFF880000);
      }
      addChild(
          new TextField('[R] to play again.', new TextFormat(Game.FONT, 30, 0xFF222222))
            ..x = 150
            ..y = 400
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
      _playerStepped = true;
    }
  }

  void onCanvasKeyDown(int keyCode) {
    if (keyCode == html.KeyCode.SPACE && !_spaceDown) {
      _spaceDown = true;
      _playerStepped = true;
    } else if (_won && keyCode == html.KeyCode.R) {
      game.newLevel();
    }
  }

  void onCanvasKeyUp(int keyCode) {
    if (keyCode == html.KeyCode.SPACE) {
      _spaceDown = false;
    }
  }

  void onCanvasTouch() {
    _playerStepped = true;
  }

  void update(num passedTime) {
    if (_playing) {
      _playingTime += passedTime;
      if (_playingTime - passedTime < 0 && _playingTime >= 0) { // just turned 8 a.m.
        _targetBackgroundColor = BACKGROUND_COLORS[1];
        _backgroundColorTime = 1.0;
        _timer.textColor = 0xFF880000;
        _playLoop(_loopHurry);
      }
    }
    num time = 8 * 3600 + _playingTime; // origin is 8 a.m.
    num hours = time ~/ 3600;
    num minutes = time % 3600 ~/ 60;
    num seconds = time.floor() % 60;
    _timer.text = '${hours < 10 ? '0' : ''}$hours:${minutes < 10 ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds a.m.';
    _scroll(passedTime);
    if (_playerStepped) {
      _step();
      _playerStepped = false;
    }
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