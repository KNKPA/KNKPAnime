import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/favorite/favorite_page.dart';

class FavoriteModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => FavoritePage());
  }
}
