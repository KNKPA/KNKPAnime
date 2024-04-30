// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlayerController on _PlayerController, Store {
  Computed<List<DanmakuAnimeInfo>>? _$danmakuCandidatesComputed;

  @override
  List<DanmakuAnimeInfo> get danmakuCandidates =>
      (_$danmakuCandidatesComputed ??= Computed<List<DanmakuAnimeInfo>>(
              () => super.danmakuCandidates,
              name: '_PlayerController.danmakuCandidates'))
          .value;

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

  late final _$danmakuEnabledAtom =
      Atom(name: '_PlayerController.danmakuEnabled', context: context);

  @override
  bool get danmakuEnabled {
    _$danmakuEnabledAtom.reportRead();
    return super.danmakuEnabled;
  }

  @override
  set danmakuEnabled(bool value) {
    _$danmakuEnabledAtom.reportWrite(value, super.danmakuEnabled, () {
      super.danmakuEnabled = value;
    });
  }

  late final _$selectedDanmakuSourceAtom =
      Atom(name: '_PlayerController.selectedDanmakuSource', context: context);

  @override
  DanmakuAnimeInfo? get selectedDanmakuSource {
    _$selectedDanmakuSourceAtom.reportRead();
    return super.selectedDanmakuSource;
  }

  @override
  set selectedDanmakuSource(DanmakuAnimeInfo? value) {
    _$selectedDanmakuSourceAtom.reportWrite(value, super.selectedDanmakuSource,
        () {
      super.selectedDanmakuSource = value;
    });
  }

  late final _$matchingAnimesAtom =
      Atom(name: '_PlayerController.matchingAnimes', context: context);

  @override
  List<DanmakuAnimeInfo> get matchingAnimes {
    _$matchingAnimesAtom.reportRead();
    return super.matchingAnimes;
  }

  @override
  set matchingAnimes(List<DanmakuAnimeInfo> value) {
    _$matchingAnimesAtom.reportWrite(value, super.matchingAnimes, () {
      super.matchingAnimes = value;
    });
  }

  @override
  String toString() {
    return '''
isFullscreen: ${isFullscreen},
playingEpisode: ${playingEpisode},
danmakuEnabled: ${danmakuEnabled},
selectedDanmakuSource: ${selectedDanmakuSource},
matchingAnimes: ${matchingAnimes},
danmakuCandidates: ${danmakuCandidates}
    ''';
  }
}
