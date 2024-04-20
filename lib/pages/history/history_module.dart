import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/history/history_page.dart';

class HistoryModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => HistoryPage());
  }
}
