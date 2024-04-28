// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlayerController on _PlayerController, Store {
  late final _$isFullscreenAtom =
      Atom(name: '_PlayerController.isFullscreen', context: context);

  @override
  bool get isFullscreen {
    _$isFullscreenAtom.reportRead();
    return super.isFullscreen;
  }

  @override
  set isFullscreen(bool value) {
    _$isFullscreenAtom.reportWrite(value, super.isFullscreen, () {
      super.isFullscreen = value;
    });
  }

  late final _$playingEpisodeAtom =
      Atom(name: '_PlayerController.playingEpisode', context: context);

  @override
  Episode get playingEpisode {
    _$playingEpisodeAtom.reportRead();
    return super.playingEpisode;
  }

  bool _playingEpisodeIsInitialized = false;

  @override
  set playingEpisode(Episode value) {
    _$playingEpisodeAtom.reportWrite(
        value, _playingEpisodeIsInitialized ? super.playingEpisode : null, () {
      super.playingEpisode = value;
      _playingEpisodeIsInitialized = true;
    });
  }

  @override
  String toString() {
    return '''
isFullscreen: ${isFullscreen},
playingEpisode: ${playingEpisode}
    ''';
  }
}
