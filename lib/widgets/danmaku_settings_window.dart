import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:knkpanime/pages/play/player_controller.dart';

class DanmakuSettingsWindow extends StatefulWidget {
  final PlayerController playerController;
  const DanmakuSettingsWindow({super.key, required this.playerController});

  @override
  State<DanmakuSettingsWindow> createState() => _DanmakuSettingsWindowState();
}

class _DanmakuSettingsWindowState extends State<DanmakuSettingsWindow> {
  @override
  Widget build(BuildContext context) {
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
            Flexible(
              child: Observer(
                builder: (context) => ListView(
                  shrinkWrap: true,
                  children:
                      widget.playerController.danmakuSources.map((danmakuInfo) {
                    return ListTile(
                      title: Text(danmakuInfo.name),
                      selected: widget.playerController.selectedDanmakuSource ==
                          danmakuInfo,
                      onTap: () {
                        widget.playerController.loadDanmakus(danmakuInfo);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
