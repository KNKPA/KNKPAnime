import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/utils/utils.dart';

class DanmakuRequest {
  static var _cachedAnimeId = 0;
  static var _cachedEpisodes = <int>[];
  static final _dio = Dio(BaseOptions(headers: {
    "User-Agent":
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));

  static const _searchAnimeApi =
      'https://api.dandanplay.net/api/v2/search/anime';
  static const _searchEpisodeApi = 'https://api.dandanplay.net/api/v2/bangumi/';
  static const _getDanmakuApi = 'https://api.dandanplay.net/api/v2/comment/';

  static Future<List<DanmakuAnimeInfo>> getMatchingAnimes(
      String animeName) async {
    try {
      var resp = await _dio.get(_searchAnimeApi, queryParameters: {
        'keyword': animeName,
      });
      List<DanmakuAnimeInfo> ret = [];
      resp.data['animes'].forEach((e) => ret.add(
          DanmakuAnimeInfo(e['animeId'], e['animeTitle'], e['episodeCount'])));
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Danmaku>> getDanmakus(int animeId, int episode) async {
    // Maybe considering omit request episode infomation?
    // The episodeId seems to consist of two parts:
    // Anime id and episode index (starting from 1, pad left to 4 digits)
    // E.g., first episode's id of K-ON (animeId=6257) is 62570001.
    int episodeId;
    /*
    if (_cachedAnimeId != animeId) {
      try {
        var resp = await dio.get(_searchEpisodeApi + animeId.toString());
        _cachedAnimeId = animeId;
        _cachedEpisodes = resp.data["bangumi"]["episodes"]
            .map((e) => e['episodeId'] as int)
            .toList();
      } catch (e) {
        rethrow;
      }
    }
    */
    episodeId = int.parse(
        animeId.toString() + (episode + 1).toString().padLeft(4, '0'));

    try {
      var resp = await _dio
          .get(_getDanmakuApi + episodeId.toString(), queryParameters: {
        'withRelated': true,
      });
      var ret = <Danmaku>[];
      resp.data['comments'].forEach(
          (e) => ret.add(Danmaku(double.parse(e['p'].split(',')[0]), e['m'])));
      //return Utils.cast<List<Danmaku>>(resp.data['comments']
      //    .map((e) => Danmaku(double.parse(e['p'].split(',')[0]), e['m']))
      //    .toList())!;
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  DanmakuRequest._();
}

class DanmakuAnimeInfo {
  int id;
  String name;
  int episodeCount;

  DanmakuAnimeInfo(this.id, this.name, this.episodeCount);
}
