import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
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
            icon: const Icon(Icons.comment),
            onPressed: widget.playerController.toggleDanmaku,
          ),
          MaterialCustomButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: widget.playerController.toggleFullscreen,
          ),
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
