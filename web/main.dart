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

ResourceManager resourceManager;
Random random;
Game game;

Future<Null> main() async {
  html.CanvasElement canvas = html.querySelector('#stage');
  canvas.context2D.imageSmoothingEnabled = true;

  resourceManager = new ResourceManager();
  addResources();
  await resourceManager.load();

  random = new Random();

  game = new Game(canvas);
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
  resourceManager.addBitmapData('test', 'images/test.png');

  resourceManager.addSound('first', 'sounds/first.ogg');
  resourceManager.addSound('second', 'sounds/second.ogg');
  resourceManager.addSound('third', 'sounds/third.ogg');
}