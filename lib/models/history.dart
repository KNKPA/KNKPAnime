import 'package:hive/hive.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';

part 'history.g.dart';

@HiveType(typeId: 0)
class History {
  @HiveField(0)
  Map<int, Progress> progresses = {};

  @HiveField(1)
  int lastWatchEpisode;

  @HiveField(2)
  String adapterName;

  @HiveField(3)
  Series series;

  @HiveField(4)
  DateTime lastWatchTime;

  String get key => adapterName + series.seriesId;

  History(
      this.series, this.lastWatchEpisode, this.adapterName, this.lastWatchTime);

  static String getKey(String n, Series s) => n + s.seriesId;

  @override
  String toString() {
    return 'Adapter: $adapterName, anime: $series';
  }
}

@HiveType(typeId: 1)
class Progress {
  @HiveField(0)
  Episode episode;

  @HiveField(1)
  int _progressInMilli;

  Duration get progress => Duration(milliseconds: _progressInMilli);

  set progress(Duration d) => _progressInMilli = d.inMilliseconds;

  Progress(this.episode, this._progressInMilli);

  @override
  String toString() {
    return 'Episode $episode, progress $progress';
  }
}
