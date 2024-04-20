import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/play/play_page.dart';

class PlayModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/',
        child: (context) => PlayPage(
            adapter: r.args.data['adapter'], series: r.args.data['series']));
  }
}
