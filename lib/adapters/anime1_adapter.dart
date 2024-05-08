import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/source.dart';
import 'package:logger/logger.dart';
import 'package:html/parser.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

part 'models/anime1_anime_info.dart';

/*
 * Acknowledgement:
 * 
 * A major part of the code of this adapter is migrated from oneAnime
 * https://github.com/Predidit/oneAnime
 * Thanks to this work and the works on which it depends.
 * 
 */

class Anime1Adapter extends AdapterBase {
  var animes = <Anime1AnimeInfo>[];
  final _dio = Dio(BaseOptions(headers: {}));
  final logger = Modular.get<Logger>();

  final String listApi = 'https://d1zquzjgwo9yb.cloudfront.net/';
  final String tokenApi = 'https://anime1.me/?cat=';
  final String videoApi = 'https://v.anime1.me/api';
  static const String desc =
      'Anime1番剧源，源网址anime1.me，建议使用繁体搜索该源。\n本番剧源获取的番剧有时会出现集数颠倒（如最后一集显示为第一集）的情况。';
  final initialized = Completer<bool>();

  late List<String> _tokens;

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    await initialized.future;
    status = SearchStatus.pending;
    List<Anime1AnimeInfo> results = [];
    if (bangumiName.isNotEmpty) {
      results.addAll(animes.where((element) =>
          element.name.contains(bangumiName) ||
          bangumiName.contains(element.name)));
    }
    if (searchKeyword.isNotEmpty) {
      results.addAll(animes.where((element) =>
          element.name.contains(searchKeyword) ||
          searchKeyword.contains(element.name)));
    }
    // TODO: Remove duplicates in results

    Modular.get<Logger>().i('Anime1 adapter returns ${results.length} results');
    results.forEach((element) => Modular.get<Logger>().i(element.name));
    status = SearchStatus.success;
    return results.map((e) => Series(e.id.toString(), e.name)).toList();
  }

  @override
  Future<List<Source>> getSources(String seriesId) async {
    _tokens = await getVideoToken(tokenApi + seriesId);

    return [
      Source(_tokens.map((e) {
        var i = _tokens.indexOf(e);
        return Episode((i + 1).toString(), i);
      }).toList())
    ];
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    var token = _tokens[_tokens.length - int.parse(episodeId)];
    var resp = await getVideoLink(token);
    var headers = <String, String>{
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
      'referer': 'https://anime1.me',
      'Cookie': resp['cookie'],
    };
    controller.player.open(Media(resp['link'], httpHeaders: headers));
  }

  Anime1Adapter() : super('Anime1', desc) {
    init();
  }

  void init() async {
    try {
      var resp = await _dio.get(listApi);
      for (var anime in resp.data) {
        animes.add(Anime1AnimeInfo(anime[0], anime[1]));
      }
      initialized.complete(true);
    } catch (e) {
      Modular.get<Logger>()
          .w('Anime1 adapter initialization failed, got list: ${e.toString()}');
      status = SearchStatus.failed;
    }
  }

  Future getVideoToken(String url) async {
    List<String> token = [];
    final res = await _dio.get(url);
    String resString = res.data.toString();
    try {
      var document = parse(resString);
      final videoTags = document.getElementsByTagName('video');
      if (videoTags.length > 0) {
        for (int i = 0; i < videoTags.length; i++) {
          final element = videoTags[i];
          token.add(element.attributes['data-apireq'] ?? '');
        }
        logger.i('从网页上成功捕获视频凭据 ${token[0]}');
        logger.i('合集总长度 ${videoTags.length}');
      } else {
        logger.i('未从网页上找到视频源');
      }
      if (token.length == 14) {
        for (int p = 2; p <= ((token.length / 14).floor() + 1); p++) {
          final link = document.getElementsByClassName('cat-links').first;
          final resNext =
              await _dio.get(link.nodes[1].attributes['href']! + '/page/$p');
          document = parse(resNext.data);
          final videoTags = document.getElementsByTagName('video');
          if (videoTags.length > 0) {
            for (int i = 0; i < videoTags.length; i++) {
              final element = videoTags[i];
              token.add(element.attributes['data-apireq'] ?? '');
            }
            logger.i('从网页$p上成功捕获视频凭据 ${token[0]}');
            logger.i('合集$p总长度 ${videoTags.length}');
          } else {
            logger.i('未从网页$p上找到视频源');
          }
        }
      }
    } catch (e) {
      logger.i('其他错误 ${e.toString()}');
      rethrow;
    }
    return token;
  }

  Future getVideoLink(String token) async {
    // Todo 剧集切换
    String link = '';
    var result = {};
    List<String> cookies = [];
    final res = await _dio.post(videoApi,
        data: 'd=' + token,
        options: Options(contentType: 'application/x-www-form-urlencoded'));
    try {
      link = 'https:' + res.data['s'][0]['src'].toString();
      cookies = res?.headers['set-cookie'] ?? [];
      logger.i('用于视频验权的cookie为 ${videoCookieC(cookies)}');
    } catch (e) {
      logger.i(e.toString());
      result['link'] = link;
      result['cookie'] = '';
      return result;
    }
    result['link'] = link;
    result['cookie'] = videoCookieC(cookies);
    return result;
  }

  videoCookieC(List<String> baseCookies) {
    String finalCookie = '';
    String baseCookieString = baseCookies.join('; ');
    baseCookieString.split('; ').forEach((cookieString) {
      if (cookieString.contains('=')) {
        List<String> cookieParts = cookieString.split('=');
        if (cookieParts[0] == 'e' ||
            cookieParts[0] == 'p' ||
            cookieParts[0] == 'h' ||
            cookieParts[0].startsWith('_ga')) {
          finalCookie =
              finalCookie + cookieParts[0] + '=' + cookieParts[1] + '; ';
        }
      }
    });
    finalCookie = finalCookie.replaceAll(RegExp(r';\s*$'), '');
    return finalCookie;
  }
}
