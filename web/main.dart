library ld40;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'level.dart';
part 'player.dart';
part 'foot.dart';
part 'item.dart';

html.CanvasElement canvas;
ResourceManager resourceManager;
Random random;
Game game;

Future<Null> main() async {
  print('release candidate 1');
  canvas = html.querySelector('#stage');
  canvas.context2D.imageSmoothingEnabled = true;

  resourceManager = new ResourceManager();
  addResources();
  await resourceManager.load();

  random = new Random();

  if (html.document.readyState != 'complete') {
    html.document.onReadyStateChange.listen((_) => onReadyStateChange());
  } else {
    game = new Game(canvas);
  }
}

void onReadyStateChange() {
  if (html.document.readyState == "complete") {
    game = new Game(canvas);
  }
}

void addResources() {
  resourceManager.addBitmapData('potion', 'images/potion.png');
  resourceManager.addBitmapData('potion_broken', 'images/potion_broken.png');
  resourceManager.addBitmapData('cactus', 'images/cactus.png');
  resourceManager.addBitmapData('cactus_broken', 'images/cactus_broken.png');
  resourceManager.addBitmapData('car', 'images/car.png');
  resourceManager.addBitmapData('car_broken', 'images/car_broken.png');
  resourceManager.addBitmapData('house', 'images/house.png');
  resourceManager.addBitmapData('house_broken', 'images/house_broken.png');
  resourceManager.addBitmapData('goal', 'images/goal.png');

  resourceManager.addSound('loop', 'sounds/loop.ogg');
  resourceManager.addSound('loop_hurry', 'sounds/loop_hurry.ogg');
  resourceManager.addSound('grow', 'sounds/grow.ogg');
  resourceManager.addSound('ouch', 'sounds/ouch.ogg');
  resourceManager.addSound('stampf', 'sounds/stampf.ogg');
  resourceManager.addSound('end', 'sounds/end.ogg');
}