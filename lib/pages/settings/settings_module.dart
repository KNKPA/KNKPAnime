import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/settings/image_set_config_page.dart';
import 'package:knkpanime/pages/settings/js_adapter_config_page.dart';
import 'package:knkpanime/pages/settings/settings_page.dart';

class SettingsModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => SettingsPage());
    r.child('/jsAdapterConfig', child: (context) => JsAdapterConfigPage());
    r.child('/imageSetConfig', child: (context) => ImageSetConfigPage());
  }
}
