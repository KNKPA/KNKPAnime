import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/adapters/adapter_registry.dart' as registry;
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

part 'adapter_search_controller.g.dart';

class AdapterSearchController = _AdapterSearchController
    with _$AdapterSearchController;

abstract class _AdapterSearchController with Store {
  @observable
  ObservableList<List<Series>> _searchResults =
      ObservableList.of(registry.adapters.map((e) => <Series>[]));
  @observable
  var _statuses =
      ObservableList.of(registry.adapters.map((adapter) => adapter.status));
  @computed
  List<List<Series>> get searchResults => _searchResults
      .where((result) =>
          !_adapters[_searchResults.indexOf(result)].useWebview ||
          Modular.get<SettingsController>().useWebViewAdapters)
      .toList();
  @computed
  List<SearchStatus> get statuses => _statuses
      .where((status) =>
          !_adapters[_statuses.indexOf(status)].useWebview ||
          Modular.get<SettingsController>().useWebViewAdapters)
      .toList();

  final _adapters = registry.adapters;

  List<AdapterBase> get adapters => _adapters
      .where((adapter) =>
          !adapter.useWebview ||
          Modular.get<SettingsController>().useWebViewAdapters)
      .toList();

  void search(String bangumiName, String keyword) {
    if (bangumiName.isEmpty && keyword.isEmpty) {
      _searchResults.clear();
      _searchResults = ObservableList.of(_adapters.map((e) => <Series>[]));
      return;
    }
    _adapters.asMap().forEach((idx, adapter) async {
      try {
        var future = adapter.search(bangumiName, keyword);
        _statuses[idx] = adapter.status;
        _searchResults[idx] = [];
        _searchResults[idx] = await future;
      } catch (e) {
        Modular.get<Logger>().w(e);
      }
      _statuses[idx] = adapter.status;
    });
  }

  void clear() {
    _searchResults.clear();
    _searchResults = ObservableList.of(_adapters.map((e) => <Series>[]));
  }
}
