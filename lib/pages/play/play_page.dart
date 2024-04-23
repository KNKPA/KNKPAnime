import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/utils/danmaku.dart';
import 'package:knkpanime/widgets/desktop_player.dart';
import 'package:knkpanime/widgets/mobile_player.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ns_danmaku/ns_danmaku.dart';

// TODO: Use custom control to synchronize player and danmaku behaviors.

class PlayPage extends StatefulWidget {
  final AdapterBase adapter;
  final Series series;

  const PlayPage({super.key, required this.adapter, required this.series});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late final player = _IntegratedPlayer();
  late final playerController = VideoController(player);
  late final historyController = Modular.get<HistoryController>();
  late DanmakuController danmakuController;
  late final logger = Modular.get<Logger>();
  List<Episode> animeSeriesInfo = [];
  late Episode playingEpisode = Episode('', 0);
  Timer updateHistoryTimer = Timer.periodic(Duration(days: 1), (timer) {});
  Timer danmakuTimer = Timer.periodic(Duration(days: 1), (timer) {});
  Map<int, List<Danmaku>> danmakus = {};
  bool danmakuEnabled = true;
  bool playStateInitialized = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    Modular.get<Logger>().i('Video play page info:');
    Modular.get<Logger>().i('Adapter: ${widget.adapter.toString()}');
    Modular.get<Logger>().i('Source anime info:  ${widget.series.toString()}');
    List<Episode> temp = [];
    try {
      temp = await widget.adapter.getEpisodes(widget.series.seriesId);
      logger.i(temp);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('剧集信息获取失败\n$e'),
      ));
    }
    temp.sort(
      (a, b) => a.episode - b.episode,
    );
    setState(() {
      animeSeriesInfo = temp;
    });

    var progress =
        historyController.lastWatching(widget.series, widget.adapter.name);
    play(animeSeriesInfo[progress?.episode.episode ?? 0]);
  }

  Future play(Episode episode) async {
    if (playStateInitialized == false) return;
    try {
      playStateInitialized = false;
      await _play(episode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('播放信息获取失败\n$e'),
      ));
      logger.w(e);
    } finally {
      playStateInitialized = true;
    }
  }

  Future _play(Episode episode) async {
    // This function will be called when entering video page or change to another episode
    updateHistoryTimer.cancel();
    danmakuTimer.cancel();
    setState(() {
      playingEpisode = episode;
    });

    try {
      await widget.adapter.play(episode.episodeId, playerController);
    } catch (e) {
      logger.w(e);
    }

    var progress = historyController.findProgress(
        widget.series, widget.adapter.name, playingEpisode.episode);
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
          debugPrint('Trying to seek to ${progress.progress}');
          await player.seek(progress.progress);
          completer.complete(1);
        }
      });
      await completer.future;
    }

    // The timer have to be defined here since if we define it in init(), it would
    // overwrite progress before we can seek to it.
    updateHistoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      historyController.updateHistory(playingEpisode, widget.adapter.name,
          widget.series, player.state.position);
    });

    try {
      // TODO: Get danmakus using `anime.name`
      // Currently we use only `series.name` to get danmakus.
      // We can consider to use `anime.name` to match danmakus as fallback,
      // but this may involve adding a AnimeInfo to the History class.
      // TODO: Danmaku source selection
      // Maybe this can't be done unless we define our own video controls.
      logger.i('Getting danmaku for ${widget.series.name}');
      var matchingAnimes =
          await DanmakuRequest.getMatchingAnimes(widget.series.name);
      logger.i(matchingAnimes.length);
      if (matchingAnimes.isNotEmpty) {
        var dmks = await DanmakuRequest.getDanmakus(
            matchingAnimes[0].id, playingEpisode.episode);
        logger.i('Danmaku count: ${danmakus.length}');
        danmakus.clear();
        dmks.forEach((element) {
          danmakus[element.offset.floor()] == null
              ? danmakus[element.offset.floor()] = [element]
              : danmakus[element.offset.floor()]?.add(element);
        });
        danmakuTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          danmakus[player.state.position.inSeconds]
              ?.asMap()
              .forEach((idx, danmaku) async {
            await Future.delayed(
                Duration(
                    milliseconds: idx *
                        1000 ~/
                        danmakus[player.state.position.inSeconds]!.length),
                () => danmakuEnabled && mounted && player.state.playing
                    ? danmakuController.addItems([DanmakuItem(danmaku.content)])
                    : null);
          });
        });
      }
    } catch (e) {
      logger.w(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    updateHistoryTimer.cancel();
    danmakuTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var playerWidget = Expanded(
        flex: 5,
        child: Stack(
          children: [
            Utils.isDesktop()
                ? DesktopPlayer(
                    playerController: playerController,
                    toggleDanmaku: () => danmakuEnabled = !danmakuEnabled,
                  )
                : MobilePlayer(
                    playerController: playerController,
                    toggleDanmaku: () => danmakuEnabled = !danmakuEnabled,
                  ),
            DanmakuView(
                createdController: (e) {
                  danmakuController = e;
                  player.danmakuController = e;
                },
                option: DanmakuOption(
                  fontSize: Utils.isDesktop() ? 25 : 16,
                )),
          ],
        ));
    return Scaffold(
      body: Utils.isDesktop()
          ? Row(
              children: [
                playerWidget,
                Expanded(child: buildPlaylistWidget()),
              ],
            )
          : Column(
              children: [
                playerWidget,
                Expanded(
                  flex: 10,
                  child: buildPlaylistWidget(),
                ),
              ],
            ),
    );
  }

  Widget buildPlaylistWidget() {
    return ListView(
      children: animeSeriesInfo
          .map((episode) => Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: episode == playingEpisode
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.2),
                      blurRadius: 3.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(episode.name),
                  onTap: () {
                    play(episode);
                  },
                ),
              ))
          .toList(),
    );
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
