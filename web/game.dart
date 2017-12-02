part of ld40;

class Game {

  Stage _stage;
  RenderLoop _renderLoop;
  Level _currentLevel;

  Game(this._stage) {
    _renderLoop = new RenderLoop()
      ..addStage(_stage);
    _stage.onEnterFrame.listen(_update);
    _stage.onMouseClick.listen(_onKeyDown);
    _currentLevel = new Level();
    _stage.addChild(_currentLevel);
  }

  void _update(EnterFrameEvent e) {
    _currentLevel.update(e.passedTime);
  }

  void _onKeyDown(MouseEvent e) {
    //if (e.keyCode == html.KeyCode.SPACE) {
      _currentLevel.onSpaceDown();
    //}
  }

  Stage get stage { return _stage; }

}