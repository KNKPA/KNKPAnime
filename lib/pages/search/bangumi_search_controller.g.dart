// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi_search_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BangumiSearchController on _BangumiSearchController, Store {
  Computed<bool>? _$hasMoreComputed;

  @override
  bool get hasMore => (_$hasMoreComputed ??= Computed<bool>(() => super.hasMore,
          name: '_BangumiSearchController.hasMore'))
      .value;

  late final _$searchResultsAtom =
      Atom(name: '_BangumiSearchController.searchResults', context: context);

  @override
  ObservableList<AnimeInfo> get searchResults {
    _$searchResultsAtom.reportRead();
    return super.searchResults;
  }

  @override
  set searchResults(ObservableList<AnimeInfo> value) {
    _$searchResultsAtom.reportWrite(value, super.searchResults, () {
      super.searchResults = value;
    });
  }

  late final _$searchingAtom =
      Atom(name: '_BangumiSearchController.searching', context: context);

  @override
  bool get searching {
    _$searchingAtom.reportRead();
    return super.searching;
  }

  @override
  set searching(bool value) {
    _$searchingAtom.reportWrite(value, super.searching, () {
      super.searching = value;
    });
  }

  late final _$_itemsAtom =
      Atom(name: '_BangumiSearchController._items', context: context);

  @override
  int get _items {
    _$_itemsAtom.reportRead();
    return super._items;
  }

  @override
  set _items(int value) {
    _$_itemsAtom.reportWrite(value, super._items, () {
      super._items = value;
    });
  }

  late final _$_pageAtom =
      Atom(name: '_BangumiSearchController._page', context: context);

  @override
  int get _page {
    _$_pageAtom.reportRead();
    return super._page;
  }

  @override
  set _page(int value) {
    _$_pageAtom.reportWrite(value, super._page, () {
      super._page = value;
    });
  }

  late final _$failedAtom =
      Atom(name: '_BangumiSearchController.failed', context: context);

  @override
  bool get failed {
    _$failedAtom.reportRead();
    return super.failed;
  }

  @override
  set failed(bool value) {
    _$failedAtom.reportWrite(value, super.failed, () {
      super.failed = value;
    });
  }

  @override
  String toString() {
    return '''
searchResults: ${searchResults},
searching: ${searching},
failed: ${failed},
hasMore: ${hasMore}
    ''';
  }
}
