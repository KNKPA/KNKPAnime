class Danmaku {
  String content;
  double offset;
  // TODO: support danmaku position & color?

  Danmaku(this.offset, this.content);
}

class DanmakuAnimeInfo {
  int id;
  String name;
  int episodeCount;

  DanmakuAnimeInfo(this.id, this.name, this.episodeCount);
}
