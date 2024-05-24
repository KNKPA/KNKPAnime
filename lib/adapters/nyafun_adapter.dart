import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/source.dart';
import 'package:knkpanime/utils/webview.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class NyafunAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));

  final String baseUrl = 'https://www.nyafun.net';
  final String searchApi = 'https://www.nyafun.net/search.html?wd=';
  final String seriesApi = 'https://www.nyafun.net';
  final String playApi = 'https://www.nyafun.net';
  late final logger = Modular.get<Logger>();

  @override
  Future<List<Source>> getSources(String seriesId) async {
    var resp = await dio.get(seriesApi + seriesId);
    return _parseSeries(resp.data.toString());
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    String url = (await Webview.getVideoResourceUrl(playApi + episodeId))!;
    await controller.player.open(Media(url, httpHeaders: {'Referer': url}));
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    List<Series> ret = [];
    status = SearchStatus.pending;
    try {
      if (bangumiName.isNotEmpty) {
        var resp = await dio.get(searchApi + bangumiName);
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      if (searchKeyword.isNotEmpty) {
        var resp = await dio.get(searchApi + searchKeyword);
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      status = SearchStatus.success;
    } catch (e) {
      status = SearchStatus.failed;
      logger.w(e);
      rethrow;
    }
    logger.i('Girigiri love adapter returns ${ret.length} results');
    return ret;
  }

  List<Series> _parseSearchResult(String html) {
    var doc = parse(html);
    return doc.getElementsByClassName('public-list-box').map((div) {
      final a = div.querySelector('.thumb-txt.cor4.hide')!.querySelector('a')!;
      String? image = div.querySelector('img')?.attributes['data-src'];
      String name = a.text;
      String? desc = div.querySelector('.cor5.thumb-blurb.hide2')?.text;
      String id = a.attributes['href']!;
      return Series(id, name, description: desc, image: image);
    }).toList();
  }

  List<Source> _parseSeries(String html) {
    var doc = parse(html);
    var uls = doc.querySelectorAll('.anthology-list-play');
    List<Source> ret = [];
    uls.forEach((ul) {
      List<Episode> episodes = [];
      ul.querySelectorAll('li').asMap().forEach((idx, li) {
        final a = li.querySelector('a')!;
        episodes.add(Episode(a.attributes['href']!, idx, a.text));
      });
      ret.add(Source(episodes));
    });
    return ret;
  }

  String _parsePlayLink(String html) {
    var doc = parse(html);
    var div = doc.querySelector('.player-left');
    div ??= doc.querySelector('.player-top');
    var scriptText = div!
        .querySelectorAll('script')
        .fold('', (previousValue, element) => previousValue + element.text)
        .split(',')
        .map((e) => e.trim());
    for (var line in scriptText) {
      if (line.contains("\"url\"")) {
        var encoded =
            line.split(':')[1].replaceAll("\"", '').replaceAll(',', '');
        var decoded = base64Decode(encoded);
        var urlEncoded = String.fromCharCodes(decoded);
        var videoLink = Uri.decodeFull(urlEncoded);
        logger.i('Parsed video link: $videoLink');
        return videoLink;
      }
    }
    return '';
  }

  NyafunAdapter() : super('Nyafun');
}
