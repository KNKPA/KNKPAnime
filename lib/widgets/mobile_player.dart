import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
import 'package:knkpanime/widgets/danmaku_settings_window.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobilePlayer extends StatefulWidget {
  final PlayerController playerController;
  const MobilePlayer({super.key, required this.playerController});

  @override
  State<MobilePlayer> createState() => _MobilePlayerState();
}

class _MobilePlayerState extends State<MobilePlayer> {
  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        topButtonBar: [
          MaterialCustomButton(
            onPressed: () => Modular.to.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
        bottomButtonBar: [
          const MaterialPositionIndicator(),
          const Spacer(),
          MaterialCustomButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DanmakuSettingsWindow(
                  playerController: widget.playerController),
            ),
          ),
          MaterialCustomButton(
              icon: const Icon(Icons.speed),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('选择播放速度',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16.0),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                final speeds = [0.5, 0.75, 1.0, 1.5, 2.0, 3.0];
                                return ListTile(
                                  title: Text('${speeds[index]}x'),
                                  onTap: () {
                                    widget.playerController
                                        .setPlaybackSpeed(speeds[index]);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
          Observer(
              builder: (_) => MaterialDesktopCustomButton(
                    icon: widget.playerController.danmakuEnabled
                        ? const Icon(Icons.comment)
                        : const Icon(Icons.comments_disabled),
                    onPressed: widget.playerController.toggleDanmaku,
                  )),
          Observer(
              builder: (_) => MaterialDesktopCustomButton(
                    icon: widget.playerController.isFullscreen
                        ? const Icon(Icons.fullscreen_exit)
                        : const Icon(Icons.fullscreen),
                    onPressed: widget.playerController.toggleFullscreen,
                  )),
        ],
      ),
      fullscreen: const MaterialVideoControlsThemeData(),
      child: Scaffold(
        body: Video(
          controller: widget.playerController.playerController,
          subtitleViewConfiguration:
              const SubtitleViewConfiguration(visible: false),
        ),
      ),
    );
  }
}
