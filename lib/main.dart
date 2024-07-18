import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:knkpanime/app_module.dart';
import 'package:knkpanime/app_widget.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/storage.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

late String version;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Modular.setInitialRoute('/search/bangumi');
  await Hive.initFlutter('${(await getApplicationSupportDirectory()).path}/v1');
  await Storage.init();
  await SettingsController.init();
  MediaKit.ensureInitialized();
  version = (await PackageInfo.fromPlatform()).version;
  if (Utils.isDesktop()) {
    await windowManager.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    windowManager.setAlwaysOnTop(prefs.getBool('alwaysOnTop') ?? false);
  }
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
