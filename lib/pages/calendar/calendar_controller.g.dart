// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CalendarController on _CalendarController, Store {
  late final _$animeListAtom =
      Atom(name: '_CalendarController.animeList', context: context);

  @override
  List<List<AnimeInfo>> get animeList {
    _$animeListAtom.reportRead();
    return super.animeList;
  }

  @override
  set animeList(List<List<AnimeInfo>> value) {
    _$animeListAtom.reportWrite(value, super.animeList, () {
      super.animeList = value;
    });
  }

  @override
  String toString() {
    return '''
animeList: ${animeList}
    ''';
  }
}
