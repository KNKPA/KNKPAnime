// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adapter_search_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AdapterSearchController on _AdapterSearchController, Store {
  Computed<List<List<Series>>>? _$searchResultsComputed;

  @override
  List<List<Series>> get searchResults => (_$searchResultsComputed ??=
          Computed<List<List<Series>>>(() => super.searchResults,
              name: '_AdapterSearchController.searchResults'))
      .value;
  Computed<List<SearchStatus>>? _$statusesComputed;

  @override
  List<SearchStatus> get statuses =>
      (_$statusesComputed ??= Computed<List<SearchStatus>>(() => super.statuses,
              name: '_AdapterSearchController.statuses'))
          .value;

  late final _$_searchResultsAtom =
      Atom(name: '_AdapterSearchController._searchResults', context: context);

  @override
  ObservableList<List<Series>> get _searchResults {
    _$_searchResultsAtom.reportRead();
    return super._searchResults;
  }

  @override
  set _searchResults(ObservableList<List<Series>> value) {
    _$_searchResultsAtom.reportWrite(value, super._searchResults, () {
      super._searchResults = value;
    });
  }

  late final _$_statusesAtom =
      Atom(name: '_AdapterSearchController._statuses', context: context);

  @override
  ObservableList<SearchStatus> get _statuses {
    _$_statusesAtom.reportRead();
    return super._statuses;
  }

  @override
  set _statuses(ObservableList<SearchStatus> value) {
    _$_statusesAtom.reportWrite(value, super._statuses, () {
      super._statuses = value;
    });
  }

  @override
  String toString() {
    return '''
searchResults: ${searchResults},
statuses: ${statuses}
    ''';
  }
}
