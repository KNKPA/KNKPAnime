import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final settingsController = Modular.get<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        // Make content scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('弹幕字号'),
            Slider(
              value: settingsController.fontSize,
              min: 10,
              max: 50,
              divisions: 40,
              label: settingsController.fontSize.round().toString(),
              onChanged: (value) =>
                  setState(() => settingsController.fontSize = value),
            ),

            // Danmaku Area Section
            const Text('弹幕区域'),
            Slider(
              value: settingsController.danmakuArea,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(settingsController.danmakuArea * 100).round()}%',
              onChanged: (value) =>
                  setState(() => settingsController.danmakuArea = value),
            ),

            // Danmaku Area Section
            const Text('弹幕不透明度'),
            Slider(
              value: settingsController.danmakuOpacity,
              min: 0,
              max: 1,
              divisions: 100,
              label: '${(settingsController.danmakuOpacity * 100).round()}%',
              onChanged: (value) =>
                  setState(() => settingsController.danmakuOpacity = value),
            ),

            ListTile(
              title: const Text('隐藏滚动弹幕'),
              trailing: Switch(
                value: settingsController.hideScrollDanmakus,
                onChanged: (value) => setState(
                    () => settingsController.hideScrollDanmakus = value),
              ),
            ),

            ListTile(
              title: const Text('隐藏顶部弹幕'),
              trailing: Switch(
                value: settingsController.hideTopDanmakus,
                onChanged: (value) =>
                    setState(() => settingsController.hideTopDanmakus = value),
              ),
            ),

            ListTile(
              title: const Text('隐藏底部弹幕'),
              trailing: Switch(
                value: settingsController.hideBottomDanmakus,
                onChanged: (value) => setState(
                    () => settingsController.hideBottomDanmakus = value),
              ),
            ),

            ListTile(
              title: const Text('置顶窗口'),
              trailing: Switch(
                value: settingsController.alwaysOnTop,
                onChanged: (value) =>
                    setState(() => settingsController.alwaysOnTop = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
