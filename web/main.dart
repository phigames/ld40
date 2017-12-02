library ld40;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'level.dart';
part 'foot.dart';

ResourceManager resourceManager;
Random random;
Game game;

Future<Null> main() async {
  Stage stage = new Stage(html.querySelector('#stage'),
      width: 1280, height: 800, options: new StageOptions()
        ..backgroundColor = Color.White
        ..renderEngine = RenderEngine.WebGL);

  resourceManager = new ResourceManager();
  addResources();
  await resourceManager.load();

  random = new Random();

  game = new Game(stage);

  // See more examples:
  // https://github.com/bp74/StageXL_Samples
}

void addResources() {

}