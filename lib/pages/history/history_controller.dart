import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/history.dart';
import 'package:knkpanime/utils/storage.dart';
import 'package:logger/logger.dart';

class HistoryController {
  late var storedHistories = Storage.histories;

  List<History> get histories {
    var temp = storedHistories.values.toList();
    temp.sort(
      (a, b) =>
          b.lastWatchTime.millisecondsSinceEpoch -
          a.lastWatchTime.millisecondsSinceEpoch,
    );
    return temp;
  }

  void updateHistory(
      Episode episode, String adapterName, Series series, Duration progress) {
    var history = storedHistories.get(History.getKey(adapterName, series)) ??
        History(series, episode.episode, adapterName, DateTime.now());
    history.lastWatchEpisode = episode.episode;
    history.lastWatchTime = DateTime.now();

    var prog = history.progresses[episode.episode];
    if (prog == null) {
      history.progresses[episode.episode] =
          Progress(episode, progress.inMilliseconds);
    } else {
      prog.progress = progress;
    }

    storedHistories.put(history.key, history);
  }

  Progress? lastWatching(Series series, String adapterName) {
    var history = storedHistories.get(History.getKey(adapterName, series));
    return history?.progresses[history.lastWatchEpisode];
  }

  Progress? findProgress(Series series, String adapterName, int episode) {
    var history = storedHistories.get(History.getKey(adapterName, series));
    return history?.progresses[episode];
  }

  void deleteHistory(History history) {
    storedHistories.delete(history.key);
  }
}
