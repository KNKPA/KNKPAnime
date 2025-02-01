import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:knkpanime/models/danmaku.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:media_kit/ffi/src/utf8.dart';
import 'package:ns_danmaku/ns_danmaku.dart';

import '../models/danmaku.dart';

class DanmakuRequest {
  static var _cachedAnimeId = 0;
  static var _cachedEpisodes = <int>[];
  static const _searchAnimeApi = '/api/v2/search/anime';
  static const _searchEpisodeApi = '/api/v2/bangumi/';
  static const _getDanmakuApi = '/api/v2/comment/';
  static const String _secret = String.fromEnvironment('APP_SECRET');
  static const String _appId = String.fromEnvironment('APP_ID');

  static Future<List<DanmakuAnimeInfo>> getMatchingAnimes(
      String animeName) async {
    try {
      var resp = await fetch(_searchAnimeApi, queryParameters: {
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
      var resp =
          await fetch(_getDanmakuApi + episodeId.toString(), queryParameters: {
        'withRelated': true,
      });
      var ret = <Danmaku>[];
      resp.data['comments'].forEach((e) {
        final info = e['p'].split(',');
        final offset = double.parse(info[0]);
        final pos = info[1] == '1'
            ? DanmakuItemType.scroll
            : (info[1] == '4' ? DanmakuItemType.bottom : DanmakuItemType.top);
        final color = Color(int.parse(info[2]) | 0xFF000000);

        ret.add(Danmaku(offset, e['m'], pos, color));
      });
      //return Utils.cast<List<Danmaku>>(resp.data['comments']
      //    .map((e) => Danmaku(double.parse(e['p'].split(',')[0]), e['m']))
      //    .toList())!;
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> fetch(String path,
      {Map<String, dynamic>? queryParameters}) {
    final dio = Dio(BaseOptions(
      headers: {
        "User-Agent": 'KNKPA/KNKPAnime',
        "X-AppId": _appId,
        "X-Timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      baseUrl: 'https://api.dandanplay.net',
    ));
    final temp = _appId +
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString() +
        path +
        _secret;
    dio.options.headers['X-Signature'] =
        base64.encode(sha256.convert(utf8.encode(temp)).bytes);
    return dio.get(path, queryParameters: queryParameters);
  }

  DanmakuRequest._();
}
