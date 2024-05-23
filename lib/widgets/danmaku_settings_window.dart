import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
import 'package:knkpanime/utils/utils.dart';

class DanmakuSettingsWindow extends StatefulWidget {
  final PlayerController playerController;
  const DanmakuSettingsWindow({super.key, required this.playerController});

  @override
  State<DanmakuSettingsWindow> createState() => _DanmakuSettingsWindowState();
}

class _DanmakuSettingsWindowState extends State<DanmakuSettingsWindow> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Expanded(
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: List.generate(
                widget.playerController.selectedDanmakuSource?.episodeCount ??
                    0,
                (index) => Observer(
                      builder: (context) => ElevatedButton(
                        onPressed: () {
                          widget.playerController.danmakuEpisode = index;
                          widget.playerController.loadDanmakus(
                              widget.playerController.selectedDanmakuSource!);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 50),
                          foregroundColor: Colors.black,
                          backgroundColor:
                              widget.playerController.danmakuEpisode == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                        ),
                        child: Text('第${index + 1}集'),
                      ),
                    )),
          ),
        ),
      ),
      // TODO: Danmaku controls. E.g., danmaku offset
      /*
      Utils.isDesktop() ? const VerticalDivider() : const Divider(),
      Expanded(
        child: Column(
          children: [
            Observer(
              builder: (context) => Slider(
                  label: '${widget.playerController.danmakuOffset}',
                  value: widget.playerController.danmakuOffset,
                  min: -60,
                  max: 60,
                  divisions: 120,
                  onChanged: (value) {
                    debugPrint('$value');
                    widget.playerController.danmakuOffset = value;
                  }),
            ),
          ],
        ),
      ),
       */
    ];
    return Dialog(
      child: Padding(
        // Add Padding here
        padding: const EdgeInsets.all(16.0), // Adjust padding as desired
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: '搜索弹幕源',
              ),
              onSubmitted: (keyword) {
                widget.playerController.searchDanmaku(keyword);
              },
            ),
            const SizedBox(height: 16),
            const Text('搜索结果'),
            Expanded(
              child: Observer(
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children:
                      widget.playerController.danmakuSources.map((danmakuInfo) {
                    return ListTile(
                      title: Text(danmakuInfo.name),
                      selected: widget.playerController.selectedDanmakuSource ==
                          danmakuInfo,
                      onTap: () async {
                        await widget.playerController.loadDanmakus(danmakuInfo);
                        widget.playerController.danmakuEpisode =
                            widget.playerController.playingEpisode.episode;
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: Utils.isDesktop()
                  ? Row(
                      children: children,
                    )
                  : Column(
                      children: children,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
