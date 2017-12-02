library ld40;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'level.dart';
part 'player.dart';
part 'foot.dart';

ResourceManager resourceManager;
Random random;
Game game;

Future<Null> main() async {
  html.CanvasElement canvas = html.querySelector('#stage');

  resourceManager = new ResourceManager();
  addResources();
  await resourceManager.load();

  random = new Random();

  game = new Game(canvas);

  // See more examples:
  // https://github.com/bp74/StageXL_Samples
}

void addResources() {

}