// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adapter_search_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AdapterSearchController on _AdapterSearchController, Store {
  late final _$searchResultsAtom =
      Atom(name: '_AdapterSearchController.searchResults', context: context);

  @override
  ObservableList<List<Series>> get searchResults {
    _$searchResultsAtom.reportRead();
    return super.searchResults;
  }

  @override
  set searchResults(ObservableList<List<Series>> value) {
    _$searchResultsAtom.reportWrite(value, super.searchResults, () {
      super.searchResults = value;
    });
  }

  late final _$statusesAtom =
      Atom(name: '_AdapterSearchController.statuses', context: context);

  @override
  ObservableList<SearchStatus> get statuses {
    _$statusesAtom.reportRead();
    return super.statuses;
  }

  @override
  set statuses(ObservableList<SearchStatus> value) {
    _$statusesAtom.reportWrite(value, super.statuses, () {
      super.statuses = value;
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
