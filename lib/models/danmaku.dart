import 'package:flutter/material.dart';
import 'package:ns_danmaku/ns_danmaku.dart';

class Danmaku {
  String content;
  double offset;
  // TODO: support danmaku position & color?
  DanmakuItemType position;
  Color color;

  Danmaku(this.offset, this.content, this.position, this.color);
}

class DanmakuAnimeInfo {
  int id;
  String name;
  int episodeCount;

  DanmakuAnimeInfo(this.id, this.name, this.episodeCount);
}
