part of ld40;

class Game {

  static const int WIDTH = 800;
  static const int HEIGHT = 600;

  Stage _stage;
  RenderLoop _renderLoop;
  Level _currentLevel;

  Game(html.CanvasElement canvas) {
    _stage = new Stage(canvas,
        width: Game.WIDTH, height: Game.HEIGHT, options: new StageOptions()
          ..backgroundColor = Color.White
          ..renderEngine = RenderEngine.WebGL);
    _renderLoop = new RenderLoop()
      ..addStage(_stage);
    _stage.onEnterFrame.listen(_update);
    canvas.onClick.listen(_onClick);
    canvas.onKeyDown.listen(_onKeyDown);
    _currentLevel = new Level();
    _stage.addChild(_currentLevel);
  }

  void _update(EnterFrameEvent e) {
    _currentLevel.update(e.passedTime);
  }

  void _onClick(html.MouseEvent e) {
    _currentLevel.onCanvasClick(e.button);
  }

  void _onKeyDown(html.KeyboardEvent e) {
    _currentLevel.onCanvasKeyDown(e.keyCode);
  }

  Stage get stage { return _stage; }

}