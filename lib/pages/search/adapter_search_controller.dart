import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/adapters/adapter_registry.dart';
import 'package:knkpanime/models/series.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

part 'adapter_search_controller.g.dart';

class AdapterSearchController = _AdapterSearchController
    with _$AdapterSearchController;

abstract class _AdapterSearchController with Store {
  @observable
  ObservableList<List<Series>> searchResults =
      ObservableList.of(adapters.map((e) => <Series>[]));
  @observable
  var statuses = ObservableList.of(adapters.map((adapter) => adapter.status));

  final _adapters = adapters;

  void search(String bangumiName, String keyword) {
    if (bangumiName.isEmpty && keyword.isEmpty) {
      searchResults.clear();
      searchResults = ObservableList.of(_adapters.map((e) => <Series>[]));
      return;
    }
    _adapters.asMap().forEach((idx, adapter) async {
      try {
        var future = adapter.search(bangumiName, keyword);
        statuses[idx] = adapter.status;
        searchResults[idx] = await future;
      } catch (e) {
        Modular.get<Logger>().w(e);
      }
      statuses[idx] = adapter.status;
    });
  }
}
