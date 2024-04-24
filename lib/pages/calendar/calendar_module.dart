import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/calendar/calendar_page.dart';

class CalendarModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => TodayPage());
  }
}
