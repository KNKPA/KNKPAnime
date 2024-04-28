import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
import 'package:knkpanime/utils/danmaku.dart';
import 'package:knkpanime/widgets/desktop_player.dart';
import 'package:knkpanime/widgets/mobile_player.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ns_danmaku/ns_danmaku.dart';
import 'package:window_manager/window_manager.dart';

class PlayPage extends StatefulWidget {
  final AdapterBase adapter;
  final Series series;

  const PlayPage({super.key, required this.adapter, required this.series});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  late final logger = Modular.get<Logger>();
  late final playerController = PlayerController(
      adapter: widget.adapter, series: widget.series, buildContext: context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    playerController.dispose();
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
                  )
                : MobilePlayer(
                    playerController: playerController,
                  ),
            DanmakuView(
                createdController: (e) =>
                    playerController.setDanmakuController(e),
                option: DanmakuOption(
                  fontSize: Utils.isDesktop() ? 25 : 16,
                )),
          ],
        ));
    return Scaffold(
      body: Observer(
        builder: (context) => Utils.isDesktop()
            ? Row(
                children: [
                  playerWidget,
                  playerController.isFullscreen
                      ? Container()
                      : Expanded(child: buildPlaylistWidget()),
                ],
              )
            : Column(
                children: [
                  playerWidget,
                  playerController.isFullscreen
                      ? Container()
                      : Expanded(
                          flex: 10,
                          child: buildPlaylistWidget(),
                        ),
                ],
              ),
      ),
    );
  }

  Widget buildPlaylistWidget() {
    return ListView(
      children: playerController.episodes
          .map((episode) => Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: episode == playerController.playingEpisode
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
                    playerController.play(episode);
                  },
                ),
              ))
          .toList(),
    );
  }
}
