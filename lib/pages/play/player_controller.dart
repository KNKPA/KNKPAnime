import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/source.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
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
  late bool danmakuEnabled = settingsController.danmakuEnabled;
  @computed
  List<DanmakuAnimeInfo> get danmakuSources {
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
  @observable
  bool showPlaylist = true;
  @observable
  int selectedVideoSource = 0;
  @observable
  int danmakuEpisode = 0;
  @observable
  double danmakuOffset = 0;

  late final logger = Modular.get<Logger>();
  late final historyController = Modular.get<HistoryController>();
  late final player = _IntegratedPlayer();
  late final playerController = VideoController(player);
  late final settingsController = Modular.get<SettingsController>();
  late DanmakuController danmakuController;
  final videoSources = ObservableList<Source>();
  bool _playStateInitialized = true;
  Map<int, List<Danmaku>> danmakus = {};
  Timer updateHistoryTimer = Timer.periodic(Duration(days: 1), (timer) {});
  int danmakuPosition = -1;
  double playbackSpeed = 1;
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
  }

  void playNextEpisode() {
    if (playingEpisode != videoSources[selectedVideoSource].episodes.last) {
      play(videoSources[selectedVideoSource]
          .episodes[playingEpisode.episode + 1]);
    }
  }

  void playPrevEpisode() {
    if (playingEpisode != videoSources[selectedVideoSource].episodes.first) {
      play(videoSources[selectedVideoSource]
          .episodes[playingEpisode.episode - 1]);
    }
  }

  void setPlaybackSpeed(double rate) {
    playbackSpeed = rate;
    player.setRate(rate);
  }

  void longPressFastForwardStart() {
    player.setRate(3);
  }

  void longPressFastForwardEnd() {
    player.setRate(playbackSpeed);
  }

  void updateDanmakuConfig() {
    danmakuController.updateOption(DanmakuOption(
      fontSize: settingsController.fontSize,
      area: settingsController.danmakuArea,
      opacity: settingsController.danmakuOpacity,
      hideBottom: settingsController.hideBottomDanmakus,
      hideScroll: settingsController.hideScrollDanmakus,
      hideTop: settingsController.hideTopDanmakus,
    ));
  }

  void enterFullscreen() {
    isFullscreen = true;
    if (Utils.isDesktop()) {
      showPlaylist = false;
      windowManager.setFullScreen(true);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void toggleFullscreen() {
    isFullscreen ? exitFullscreen() : enterFullscreen();
  }

  void init() async {
    Modular.get<Logger>().i('Video play page info:');
    Modular.get<Logger>().i('Adapter: ${adapter.toString()}');
    Modular.get<Logger>().i('Source anime info: ${series.toString()}');

    player.stream.position.listen((event) {
      if (event.inSeconds != danmakuPosition) {
        danmakuPosition = event.inSeconds + danmakuOffset.toInt();
        danmakus[danmakuPosition]?.asMap().forEach((idx, danmaku) async {
          await Future.delayed(
              Duration(
                  milliseconds: idx *
                      1000 /
                      playbackSpeed ~/
                      danmakus[danmakuPosition]!.length),
              () =>
                  danmakuEnabled && buildContext.mounted && player.state.playing
                      ? danmakuController.addItems([
                          DanmakuItem(danmaku.content,
                              color: danmaku.color, type: danmaku.position)
                        ])
                      : null);
        });
      }
    });

    List<Source> temp = [];
    try {
      temp = await adapter.getSources(series.seriesId);
      logger.i(temp);
    } catch (e) {
      buildContext.mounted
          ? ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
              content: Text('剧集信息获取失败\n$e'),
            ))
          : null;
    }
    // We gotta do progress related computation here,
    // otherwise, the videoSources's change will be rendered by the playlist
    // widget, and the change of selectedVideoSource won't be refelected.
    var progress = historyController.lastWatching(series, adapter.name);
    if (progress != null) {
      // Find the corresponding source
      selectedVideoSource = temp.indexWhere(
        (source) {
          return source.episodes
              .map((e) => e.episodeId)
              .contains(progress.episode.episodeId);
        },
      );
      selectedVideoSource == -1 ? selectedVideoSource = 0 : null;
    }
    videoSources.addAll(temp);

    try {
      await searchDanmaku(series.name);
      if (matchingAnimes.isNotEmpty) {
        selectedDanmakuSource = matchingAnimes[0];
      }
    } catch (e) {
      logger.w(e);
    }

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
        if (playingEpisode != videoSources[selectedVideoSource].episodes.last) {
          var idx = videoSources[selectedVideoSource]
              .episodes
              .indexOf(playingEpisode);
          play(videoSources[selectedVideoSource].episodes[idx + 1]);
        }
      }
    });

    play(videoSources[selectedVideoSource]
        .episodes[progress?.episode.episode ?? 0]);
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
    player.pause();
    danmakuEpisode += (episode.episode - playingEpisode.episode);
    playingEpisode = episode;
    if (selectedDanmakuSource != null) {
      loadDanmakus(selectedDanmakuSource!);
    }

    try {
      await adapter.play(episode.episodeId, playerController);
    } catch (e) {
      logger.w(e);
      buildContext.mounted
          ? ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
              content: Text('播放失败\n$e'),
            ))
          : null;
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
    danmakuOffset = 0;
    try {
      var dmks = await DanmakuRequest.getDanmakus(info.id, danmakuEpisode);
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
    settingsController.danmakuEnabled = danmakuEnabled;
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
