import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/source.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class GirigiriLoveAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));

  final String baseUrl = 'https://anime.girigirilove.com';
  final String searchApi =
      'https://anime.girigirilove.com/search/-------------/?wd=';
  final String seriesApi = 'https://anime.girigirilove.com/';
  final String playApi = 'https://anime.girigirilove.com/';
  late final logger = Modular.get<Logger>();

  @override
  Future<List<Source>> getSources(String seriesId) async {
    var resp = await dio.get(seriesApi + seriesId);
    return _parseSeries(resp.data.toString());
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    var resp = await dio.get(playApi + episodeId);
    await controller.player.open(Media(_parsePlayLink(resp.data.toString())));
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
      String? image;
      var style = div.querySelector('.cover')?.attributes['style'];
      var regExp = RegExp(r'url\((.*?)\)');
      if (style != null && regExp.firstMatch(style) != null) {
        var url = regExp.firstMatch(style)!.group(1);
        image = baseUrl + url!;
      }
      String name = div.querySelector('.thumb-txt')!.text;
      String desc = div.querySelector('.thumb-blurb')!.text;
      String id = div
          .querySelector('.thumb-menu')!
          .firstChild!
          .attributes['href']!
          .replaceAll('/', '');
      return Series(id, name, description: desc, image: image);
    }).toList();
  }

  List<Source> _parseSeries(String html) {
    var doc = parse(html);
    var uls = doc.querySelectorAll('.anthology-list-play')!;
    List<Source> ret = [];
    uls.forEach((ul) {
      List<Episode> episodes = [];
      ul.querySelectorAll('li').asMap().forEach((idx, li) {
        episodes.add(Episode(
            li.firstChild!.attributes['href']!.replaceAll('/', ''), idx));
      });
      ret.add(Source(episodes));
    });
    return ret;
  }

  String _parsePlayLink(String html) {
    var doc = parse(html);
    var div = doc.querySelector('.player-left')!;
    var script =
        div.querySelector('script')!.text.split(',').map((e) => e.trim());
    for (var line in script) {
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

  GirigiriLoveAdapter() : super('Girigiri Love');
}
