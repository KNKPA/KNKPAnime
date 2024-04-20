import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/utils/bangumi.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';

part 'bangumi_search_controller.g.dart';

class BangumiSearchController = _BangumiSearchController
    with _$BangumiSearchController;

abstract class _BangumiSearchController with Store {
  @observable
  var searchResults = ObservableList<AnimeInfo>();
  @observable
  bool searching = false;
  @observable
  int _items = 0;
  @observable
  int _page = 0;
  @computed
  bool get hasMore => _page * _maxResults < _items;
  @observable
  bool failed = false;

  String _keyword = '';
  String get keyword => _keyword;
  final int _maxResults = 25;

  void search(String keyword) async {
    if (keyword == _keyword && !failed) return;
    clear();
    if (keyword.isEmpty) return;

    _keyword = keyword;
    searchResults.addAll(await _search());
  }

  void loadMore() async {
    searchResults.addAll(await _search());
    debugPrint('$_page $_items');
  }

  void clear() {
    searchResults.clear();
    _page = 0;
    _keyword = '';
    _items = 0;
    failed = false;
  }

  Future<List<AnimeInfo>> _search() async {
    searching = true;
    try {
      var (animes, totalItems) = await Bangumi.search(_keyword,
          start: _page * _maxResults, maxResults: _maxResults);
      _items = totalItems;
      _page++;
      return animes;
    } catch (e) {
      failed = true;
      Modular.get<Logger>().w(e.toString());
    } finally {
      searching = false;
    }
    return [];
  }
}
