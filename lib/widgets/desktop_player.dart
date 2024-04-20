import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:media_kit_video/media_kit_video.dart';

class DesktopPlayer extends StatefulWidget {
  final VideoController playerController;
  final Function() toggleDanmaku;
  const DesktopPlayer(
      {super.key, required this.playerController, required this.toggleDanmaku});

  @override
  State<DesktopPlayer> createState() => _DesktopPlayerState();
}

class _DesktopPlayerState extends State<DesktopPlayer> {
  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        topButtonBar: [
          MaterialCustomButton(
            onPressed: () => Modular.to.pop(),
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
          MaterialDesktopCustomButton(
            icon: const Icon(Icons.comment),
            onPressed: widget.toggleDanmaku,
          ),
          const MaterialDesktopFullscreenButton()
        ],
        keyboardShortcuts: _playerShortcuts,
      ),
      fullscreen: MaterialDesktopVideoControlsThemeData(
        bottomButtonBar: [
          const MaterialDesktopSkipPreviousButton(),
          const MaterialDesktopPlayOrPauseButton(),
          const MaterialDesktopSkipNextButton(),
          const MaterialDesktopVolumeButton(),
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          MaterialDesktopCustomButton(
            icon: const Icon(Icons.comment),
            onPressed: widget.toggleDanmaku,
          ),
          const MaterialDesktopFullscreenButton()
        ],
        keyboardShortcuts: _playerShortcuts,
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

  // https://github.com/media-kit/media-kit/blob/77a130b1d7ce733b47d2133b57563716090450d0/media_kit_video/lib/media_kit_video_controls/src/controls/material_desktop.dart#L542
  // This is the original shortcuts map with a little modification,
  // i.e., changing the left/right arrow's seek duration to 10 seconds
  late final _playerShortcuts = {
    const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
        widget.playerController.player.play(),
    const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
        widget.playerController.player.pause(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
        widget.playerController.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext): () =>
        widget.playerController.player.next(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () =>
        widget.playerController.player.previous(),
    const SingleActivator(LogicalKeyboardKey.space): () =>
        widget.playerController.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.keyJ): () {
      final rate = widget.playerController.player.state.position -
          const Duration(seconds: 10);
      widget.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      final rate = widget.playerController.player.state.position +
          const Duration(seconds: 10);
      widget.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      final rate = widget.playerController.player.state.position -
          const Duration(seconds: 10);
      widget.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      final rate = widget.playerController.player.state.position +
          const Duration(seconds: 10);
      widget.playerController.player.seek(rate);
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
      final volume = widget.playerController.player.state.volume + 5.0;
      widget.playerController.player.setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
      final volume = widget.playerController.player.state.volume - 5.0;
      widget.playerController.player.setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.keyF): () =>
        toggleFullscreen(context),
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        exitFullscreen(context),
  };
}
