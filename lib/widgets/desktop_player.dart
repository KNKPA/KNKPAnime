import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
import 'package:knkpanime/widgets/danmaku_settings_window.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class DesktopPlayer extends StatefulWidget {
  final PlayerController playerController;
  const DesktopPlayer({super.key, required this.playerController});

  @override
  State<DesktopPlayer> createState() => _DesktopPlayerState();
}

class _DesktopPlayerState extends State<DesktopPlayer> {
  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        toggleFullscreenOnDoublePress: false,
        topButtonBar: [
          MaterialCustomButton(
            onPressed: () {
              widget.playerController.exitFullscreen();
              Modular.to.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ],
        bottomButtonBar: [
          const MaterialDesktopSkipPreviousButton(),
          const MaterialDesktopPlayOrPauseButton(),
          const MaterialDesktopSkipNextButton(),
          const MaterialDesktopVolumeButton(),
          const MaterialDesktopPositionIndicator(),
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
                  builder: (context) => AlertDialog(
                    title: const Text('选择播放速度'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('0.5x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(0.5);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('0.75x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(0.75);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('1.0x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(1);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('1.5x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(1.5);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('2.0x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(2);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('3.0x'),
                          onTap: () {
                            widget.playerController.setPlaybackSpeed(3);
                            Navigator.pop(context);
                          },
                        ),
                      ],
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
        keyboardShortcuts: _playerShortcuts,
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(),
      child: Scaffold(
        body: Video(
          controller: widget.playerController.playerController,
          subtitleViewConfiguration:
              const SubtitleViewConfiguration(visible: false),
        ),
      ),
    );
  }

  // https://github.com/media-kit/media-kit/blob/77a130b1d7ce733b47d2133b57563716090450d0/media_kit_video/lib/media_kit_video_controls/src/controls/material_desktop.dart#L542
  // This is the original shortcuts map with a little modification,
  // i.e., changing the left/right arrow's seek duration to 10 seconds
  late final _playerShortcuts = {
    const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
        widget.playerController.playerController.player.play(),
    const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
        widget.playerController.playerController.player.pause(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
        widget.playerController.playerController.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext): () =>
        widget.playerController.playerController.player.next(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () =>
        widget.playerController.playerController.player.previous(),
    const SingleActivator(LogicalKeyboardKey.space): () =>
        widget.playerController.playerController.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.keyJ): () {
      final rate =
          widget.playerController.playerController.player.state.position -
              const Duration(seconds: 10);
      widget.playerController.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      final rate =
          widget.playerController.playerController.player.state.position +
              const Duration(seconds: 10);
      widget.playerController.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      final rate =
          widget.playerController.playerController.player.state.position -
              const Duration(seconds: 10);
      widget.playerController.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      final rate =
          widget.playerController.playerController.player.state.position +
              const Duration(seconds: 10);
      widget.playerController.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
      final volume =
          widget.playerController.playerController.player.state.volume + 5.0;
      widget.playerController.playerController.player
          .setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
      final volume =
          widget.playerController.playerController.player.state.volume - 5.0;
      widget.playerController.playerController.player
          .setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.escape):
        widget.playerController.exitFullscreen,
    const SingleActivator(LogicalKeyboardKey.keyD):
        widget.playerController.toggleDanmaku,
  };
}
