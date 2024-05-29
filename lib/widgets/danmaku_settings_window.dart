import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/pages/play/player_controller.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/utils.dart';

class DanmakuSettingsWindow extends StatefulWidget {
  final PlayerController playerController;
  const DanmakuSettingsWindow({super.key, required this.playerController});

  @override
  State<DanmakuSettingsWindow> createState() => _DanmakuSettingsWindowState();
}

class _DanmakuSettingsWindowState extends State<DanmakuSettingsWindow> {
  late final settingsController = Modular.get<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Expanded(
        child: SingleChildScrollView(
          child: Observer(
            builder: (context) => Wrap(
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
      ),
      Utils.isDesktop() ? const VerticalDivider() : const Divider(),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('弹幕偏移'),
                  Tooltip(
                    richMessage: WidgetSpan(
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5),
                        child: const Text(
                            '此设置用来解决弹幕与视频不同步的问题，单位为秒。例如，此设置为5、视频播放至30秒时，会显示35秒时对应的弹幕。'),
                      ),
                    ),
                    child: const Icon(Icons.info),
                  ),
                ],
              ),
              Observer(
                builder: (context) => Slider(
                    label: '${widget.playerController.danmakuOffset.toInt()}',
                    value: widget.playerController.danmakuOffset,
                    min: -60,
                    max: 60,
                    divisions: 120,
                    onChanged: (value) {
                      widget.playerController.danmakuOffset = value;
                    }),
              ),
              const Text('弹幕字号'),
              Slider(
                value: settingsController.fontSize,
                min: 10,
                max: 50,
                divisions: 40,
                label: settingsController.fontSize.round().toString(),
                onChanged: (value) {
                  setState(() => settingsController.fontSize = value);
                  widget.playerController.updateDanmakuConfig();
                },
              ),

              // Danmaku Area Section
              const Text('弹幕区域'),
              Slider(
                value: settingsController.danmakuArea,
                min: 0,
                max: 1,
                divisions: 10,
                label: '${(settingsController.danmakuArea * 100).round()}%',
                onChanged: (value) {
                  setState(() => settingsController.danmakuArea = value);
                  widget.playerController.updateDanmakuConfig();
                },
              ),

              // Danmaku Area Section
              const Text('弹幕不透明度'),
              Slider(
                value: settingsController.danmakuOpacity,
                min: 0,
                max: 1,
                divisions: 100,
                label: '${(settingsController.danmakuOpacity * 100).round()}%',
                onChanged: (value) {
                  setState(() => settingsController.danmakuOpacity = value);
                  widget.playerController.updateDanmakuConfig();
                },
              ),

              ListTile(
                title: const Text('隐藏滚动弹幕'),
                trailing: Switch(
                  value: settingsController.hideScrollDanmakus,
                  onChanged: (value) {
                    setState(
                        () => settingsController.hideScrollDanmakus = value);
                    widget.playerController.updateDanmakuConfig();
                  },
                ),
              ),

              ListTile(
                title: const Text('隐藏顶部弹幕'),
                trailing: Switch(
                  value: settingsController.hideTopDanmakus,
                  onChanged: (value) {
                    setState(() => settingsController.hideTopDanmakus = value);
                    widget.playerController.updateDanmakuConfig();
                  },
                ),
              ),

              ListTile(
                title: const Text('隐藏底部弹幕'),
                trailing: Switch(
                  value: settingsController.hideBottomDanmakus,
                  onChanged: (value) {
                    setState(
                        () => settingsController.hideBottomDanmakus = value);
                    widget.playerController.updateDanmakuConfig();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
