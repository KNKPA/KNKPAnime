import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/utils.dart';

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
      appBar: AppBar(title: const Text('设置')),
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

            if (Utils.isDesktop())
              ListTile(
                title: const Text('置顶窗口'),
                trailing: Switch(
                  value: settingsController.alwaysOnTop,
                  onChanged: (value) =>
                      setState(() => settingsController.alwaysOnTop = value),
                ),
              ),

            ListTile(
              title: Row(
                children: [
                  const Text('禁用GitHub api代理'),
                  Tooltip(
                    richMessage: WidgetSpan(
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5),
                        child: const Text(
                            '考虑到部分用户可能存在连接GitHub不稳定的问题，作者在Cloudflare设置了一个worker转发GitHub的请求结果。作者承诺worker不记录您的信息，但口说无凭，如果您担心使用作者的worker代理的请求可能泄露您的数据（包括ip地址、所在地区等信息），可以禁用代理。'),
                      ),
                    ),
                    child: const Icon(Icons.info),
                  )
                ],
              ),
              trailing: Switch(
                value: settingsController.disableGithubProxy,
                onChanged: (value) => setState(
                    () => settingsController.disableGithubProxy = value),
              ),
            ),

            //if (!Platform.isWindows)
            ListTile(
              title: Row(
                children: [
                  const Text('使用WebView源'),
                  Tooltip(
                    richMessage: WidgetSpan(
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5),
                        child: const Text(
                            '部分播放源会使用WebView，也就是使用一个隐藏的浏览器，来解析视频链接。这些源在进入视频页面时会暂时消耗较多资源。'),
                      ),
                    ),
                    child: const Icon(Icons.info),
                  )
                ],
              ),
              trailing: Switch(
                value: settingsController.useWebViewAdapters,
                onChanged: (value) => setState(
                    () => settingsController.useWebViewAdapters = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
