import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsController {
  late final SharedPreferences prefs;
  late final logger = Modular.get<Logger>();

  double get fontSize =>
      prefs.getDouble('fontSize') ?? (Utils.isDesktop() ? 25 : 16);
  double get danmakuArea => prefs.getDouble('danmakuArea') ?? 1;
  double get danmakuOpacity => prefs.getDouble('danmakuOpacity') ?? 1;
  bool get hideScrollDanmakus => prefs.getBool('hideScrollDanmakus') ?? false;
  bool get hideTopDanmakus => prefs.getBool('hideTopDanmakus') ?? false;
  bool get hideBottomDanmakus => prefs.getBool('hideBottomDanmakus') ?? false;
  bool get alwaysOnTop => prefs.getBool('alwaysOnTop') ?? false;
  bool get disableGithubProxy => prefs.getBool('disableGithubProxy') ?? false;
  bool get useWebViewAdapters => prefs.getBool('useWebViewAdapters') ?? true;
  List<String> get jsAdapters => prefs.getStringList('jsAdapters') ?? [];

  set fontSize(double size) {
    prefs.setDouble('fontSize', size);
    logger.i('Font size set to $size');
  }

  set danmakuArea(double value) {
    prefs.setDouble('danmakuArea', value);
    logger.i('Danmaku area set to $value');
  }

  set danmakuOpacity(double value) {
    prefs.setDouble('danmakuOpacity', value);
    logger.i('Danmaku opacity set to $value');
  }

  set hideScrollDanmakus(bool value) {
    prefs.setBool('hideScrollDanmakus', value);
    logger.i('Hide scroll danmakus set to $value');
  }

  set hideTopDanmakus(bool value) {
    prefs.setBool('hideTopDanmakus', value);
    logger.i('Hide top danmakus set to $value');
  }

  set hideBottomDanmakus(bool value) {
    prefs.setBool('hideBottomDanmakus', value);
    logger.i('Hide bottom danmakus set to $value');
  }

  set alwaysOnTop(bool value) {
    prefs.setBool('alwaysOnTop', value);
    windowManager.setAlwaysOnTop(value);
    logger.i('Always on top set to $value');
  }

  set disableGithubProxy(bool value) {
    prefs.setBool('disableGithubProxy', value);
    logger.i('disableGithubProxy set to $value');
  }

  set useWebViewAdapters(bool value) {
    prefs.setBool('useWebViewAdapters', value);
    logger.i('useWebViewAdapters set to $value');
  }

  set jsAdapters(List<String> value) {
    prefs.setStringList('jsAdapters', value);
  }

  SettingsController() {
    SharedPreferences.getInstance().then((v) => prefs = v);
  }
}
