import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/adapters/adapter_registry.dart' as registry;
import 'package:knkpanime/adapters/js_adapter.dart';
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
          _adapterAvailable(_adapters[_searchResults.indexOf(result)]))
      .toList();
  @computed
  List<SearchStatus> get statuses => _statuses
      .where(
          (status) => _adapterAvailable(_adapters[_statuses.indexOf(status)]))
      .toList();

  @observable
  var _adapters = ObservableList.of(registry.adapters);

  List<AdapterBase> get availableAdapters =>
      _adapters.where((adapter) => _adapterAvailable(adapter)).toList();

  @computed
  List<JSAdapter> get jsAdapters => _adapters.whereType<JSAdapter>().toList();

  late final settingsController = Modular.get<SettingsController>();

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

  void addJsAdapter(String sourceUrl) async {
    if (jsAdapters.map((adapter) => adapter.sourceUrl).contains(sourceUrl)) {
      Modular.get<Logger>()
          .i('JS Adapter from source $sourceUrl already exists, aborting');
      return;
    }
    Modular.get<Logger>().i('Initializing js adapter from $sourceUrl');
    final adapter = JSAdapter(sourceUrl);
    await adapter.completer.future;
    Modular.get<Logger>().i('Initialized, success: ${adapter.initialized}');
    if (adapter.initialized &&
        !_adapters.map((adapter) => adapter.name).contains(adapter.name)) {
      _adapters.add(adapter);
      _statuses.add(adapter.status);
      _searchResults.add([]);
      final stored = settingsController.jsAdapters;
      stored.add(sourceUrl);
      settingsController.jsAdapters = stored;
    }
  }

  void removeJsAdapter(JSAdapter adapter) {
    _adapters.remove(adapter);
    final stored = settingsController.jsAdapters;
    stored.removeWhere((element) => adapter.sourceUrl == element);
    settingsController.jsAdapters = stored;
  }

  bool _adapterAvailable(AdapterBase adapter) {
    return (!adapter.useWebview || settingsController.useWebViewAdapters) &&
        (adapter is! JSAdapter || adapter.initialized);
  }

  _AdapterSearchController() {
    try {
      Dio()
          .get(
              'https://raw.githubusercontent.com/KNKPA/KNKPAnime-js-adapters/main/registry.json')
          .then((resp) => (jsonDecode(resp.data) as List)
              .forEach((url) => addJsAdapter(url)));
    } catch (e) {
      Modular.get<Logger>().w(e);
    }
  }
}
