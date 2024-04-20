import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/today/today_page.dart';

class TodayModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => TodayPage());
  }
}
