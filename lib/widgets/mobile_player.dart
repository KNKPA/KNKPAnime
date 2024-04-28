import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MobilePlayer extends StatefulWidget {
  final VideoController playerController;
  final Function() toggleDanmaku;
  const MobilePlayer(
      {super.key, required this.playerController, required this.toggleDanmaku});

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
            icon: const Icon(Icons.comment),
            onPressed: widget.toggleDanmaku,
          ),
          const MaterialFullscreenButton()
        ],
      ),
      fullscreen: MaterialVideoControlsThemeData(
        bottomButtonBar: [
          const MaterialPositionIndicator(),
          const Spacer(),
          MaterialCustomButton(
            icon: const Icon(Icons.comment),
            onPressed: widget.toggleDanmaku,
          ),
          const MaterialFullscreenButton()
        ],
      ),
      child: Scaffold(
        body: Video(
          controller: widget.playerController,
          subtitleViewConfiguration:
              const SubtitleViewConfiguration(visible: false),
        ),
      ),
    );
  }
}
