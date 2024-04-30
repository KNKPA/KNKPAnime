import 'package:flutter/material.dart';
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
    return AlertDialog(
      content: Padding(
        // Add Padding here
        padding: const EdgeInsets.all(16.0), // Adjust padding as desired
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Observer(
              builder: (context) => DropdownButton<String>(
                value: widget.playerController.selectedDanmakuSource?.id
                    .toString(),
                hint: const Text('搜索结果'),
                isExpanded: true,
                items: widget.playerController.danmakuCandidates
                    .map((danmakuInfo) {
                  return DropdownMenuItem(
                    value: danmakuInfo.id.toString(),
                    child: Text(danmakuInfo.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  newValue != null
                      ? widget.playerController
                          .loadDanmakus(int.parse(newValue))
                      : null;
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
