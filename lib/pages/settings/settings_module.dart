import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/settings/settings_page.dart';

class SettingsModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => SettingsPage());
  }
}
