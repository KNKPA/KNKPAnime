import 'package:hive/hive.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/history.dart';
import 'package:knkpanime/models/series.dart';

class Storage {
  static late Box<History> histories;
  static late Box<AnimeInfo> favorites;

  static Future init() async {
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(ProgressAdapter());
    Hive.registerAdapter(EpisodeAdapter());
    Hive.registerAdapter(SeriesAdapter());
    Hive.registerAdapter(AnimeInfoAdapter());
    histories = await Hive.openBox('histories');
    favorites = await Hive.openBox('favorites');
  }

  Storage._();
}
