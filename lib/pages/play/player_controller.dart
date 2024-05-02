import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/utils/danmaku.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mobx/mobx.dart';
import 'package:ns_danmaku/ns_danmaku.dart';
import 'package:window_manager/window_manager.dart';

import '../../models/danmaku.dart';

part 'player_controller.g.dart';

class PlayerController = _PlayerController with _$PlayerController;

abstract class _PlayerController with Store {
  @observable
  bool isFullscreen = false;
  @observable
  late Episode playingEpisode = Episode('', 0);
  @observable
  bool danmakuEnabled = true;
  @computed
  List<DanmakuAnimeInfo> get danmakuCandidates {
    var temp = (selectedDanmakuSource == null
        ? <DanmakuAnimeInfo>[]
        : [selectedDanmakuSource!]);
    temp.addAll(matchingAnimes
        .where((element) => element.id != selectedDanmakuSource?.id));
    return temp;
  }

  @observable
  DanmakuAnimeInfo? selectedDanmakuSource;
  @observable
  List<DanmakuAnimeInfo> matchingAnimes = [];

  late final logger = Modular.get<Logger>();
  late final historyController = Modular.get<HistoryController>();
  late final player = _IntegratedPlayer();
  late final playerController = VideoController(player);
  late DanmakuController danmakuController;
  final episodes = ObservableList<Episode>();
  bool _playStateInitialized = true;
  Map<int, List<Danmaku>> danmakus = {};
  Timer updateHistoryTimer = Timer.periodic(Duration(days: 1), (timer) {});
  late Timer danmakuTimer;
  final AdapterBase adapter;
  final Series series;
  final BuildContext buildContext;

  _PlayerController(
      {required this.adapter,
      required this.series,
      required this.buildContext}) {
    init();
  }

  void dispose() {
    exitFullscreen();
    player.dispose();
    updateHistoryTimer.cancel();
    danmakuTimer.cancel();
  }

  void setPlaybackSpeed(double rate) {
    player.setRate(rate);
  }

  void enterFullscreen() {
    isFullscreen = true;
    if (Utils.isDesktop()) {
      windowManager.setFullScreen(true);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void exitFullscreen() {
    isFullscreen = false;
    if (Utils.isDesktop()) {
      windowManager.setFullScreen(false);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void toggleFullscreen() {
    isFullscreen ? exitFullscreen() : enterFullscreen();
  }

  void init() async {
    Modular.get<Logger>().i('Video play page info:');
    Modular.get<Logger>().i('Adapter: ${adapter.toString()}');
    Modular.get<Logger>().i('Source anime info: ${series.toString()}');
    List<Episode> temp = [];
    try {
      temp = await adapter.getEpisodes(series.seriesId);
      logger.i(temp);
    } catch (e) {
      buildContext.mounted
          ? ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
              content: Text('剧集信息获取失败\n$e'),
            ))
          : null;
    }
    temp.sort(
      (a, b) => a.episode - b.episode,
    );
    episodes.addAll(temp);

    await searchDanmaku(series.name);
    if (matchingAnimes.isNotEmpty) {
      loadDanmakus(matchingAnimes[0]);
    }
    danmakuTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      danmakus[player.state.position.inSeconds]
          ?.asMap()
          .forEach((idx, danmaku) async {
        await Future.delayed(
            Duration(
                milliseconds: idx *
                    1000 ~/
                    danmakus[player.state.position.inSeconds]!.length),
            () => danmakuEnabled && buildContext.mounted && player.state.playing
                ? danmakuController.addItems([DanmakuItem(danmaku.content)])
                : null);
      });
    });

    player.stream.completed.listen((event) {
      if (event == true) {
        logger.i(
            'Playback completed, clearing progress for episode ${playingEpisode.name}');
        try {
          historyController.clearProgress(
              series, adapter.name, playingEpisode.episode);
        } catch (e) {
          logger.w(e);
        }
        if (playingEpisode != episodes.last) {
          var idx = episodes.indexOf(playingEpisode);
          play(episodes[idx + 1]);
        }
      }
    });

    var progress = historyController.lastWatching(series, adapter.name);
    play(episodes[progress?.episode.episode ?? 0]);
  }

  Future play(Episode episode) async {
    if (_playStateInitialized == false) return;
    try {
      _playStateInitialized = false;
      await _play(episode);
    } catch (e) {
      buildContext.mounted
          ? ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
              content: Text('播放信息获取失败\n$e'),
            ))
          : null;
      logger.w(e);
    } finally {
      _playStateInitialized = true;
    }
  }

  Future _play(Episode episode) async {
    // This function will be called when entering video page or change to another episode
    updateHistoryTimer.cancel();
    danmakuController.clear();
    playingEpisode = episode;
    if (selectedDanmakuSource != null) {
      loadDanmakus(selectedDanmakuSource!);
    }

    try {
      await adapter.play(episode.episodeId, playerController);
    } catch (e) {
      logger.w(e);
    }

    var progress = historyController.findProgress(
        series, adapter.name, playingEpisode.episode);
    if (progress != null) {
      Modular.get<Logger>()
          .i('Retrived watching progress: ${progress.toString()}');
      var sub = player.stream.buffer.listen(null);
      var completer = Completer();
      sub.onData((event) async {
        if (event.inMicroseconds > 0) {
          // This is a workaround for unable to await for `mediaPlayer.stream.buffer.first`
          // It seems that when the `buffer.first` is fired, the media is not fully loaded
          // and the player will not seek properlly.
          await sub.cancel();
          logger.i('Trying to seek to ${progress.progress}');
          await player.seek(progress.progress);
          completer.complete(0);
        }
      });
      await completer.future;
    }

    // The timer have to be defined here since if we define it in init(), it would
    // overwrite progress before we can seek to it.
    updateHistoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (player.state.playing) {
        historyController.updateHistory(
            playingEpisode, adapter.name, series, player.state.position);
      }
    });
  }

  Future loadDanmakus(DanmakuAnimeInfo info) async {
    logger.i('Loading danmaku with id ${info.id}');
    danmakus.clear();
    selectedDanmakuSource = info;
    try {
      var dmks =
          await DanmakuRequest.getDanmakus(info.id, playingEpisode.episode);
      logger.i('Danmaku count: ${dmks.length}');
      dmks.forEach((element) {
        danmakus[element.offset.floor()] == null
            ? danmakus[element.offset.floor()] = [element]
            : danmakus[element.offset.floor()]?.add(element);
      });
    } catch (e) {
      logger.w(e);
    }
  }

  Future searchDanmaku(String keyword) async {
    logger.i('Getting danmaku for ${keyword}');
    matchingAnimes = await DanmakuRequest.getMatchingAnimes(keyword);
    logger.i('Found ${matchingAnimes.length} matchings');
  }

  void toggleDanmaku() {
    danmakuController.clear();
    danmakuEnabled = !danmakuEnabled;
  }

  void setDanmakuController(DanmakuController c) {
    danmakuController = c;
    player.danmakuController = c;
  }
}

// Hack the player a little bit... to synchronize video and danmaku
class _IntegratedPlayer extends Player {
  DanmakuController? danmakuController;

  _IntegratedPlayer();

  @override
  Future<void> play() {
    danmakuController?.resume();
    return super.play();
  }

  @override
  Future<void> pause() {
    danmakuController?.pause();
    return super.pause();
  }

  @override
  Future<void> playOrPause() {
    super.state.playing
        ? danmakuController?.pause()
        : danmakuController?.resume();
    return super.playOrPause();
  }

  @override
  Future<void> seek(Duration duration) {
    danmakuController?.clear();
    return super.seek(duration);
  }
}
