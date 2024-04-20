import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/search/adapter_search_page.dart';
import 'package:knkpanime/pages/search/bangumi_search_page.dart';

class SearchModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/bangumi', child: (_) => BangumiSearchPage());
    r.child('/adapter', child: (_) => AdapterSearchPage());
  }
}
