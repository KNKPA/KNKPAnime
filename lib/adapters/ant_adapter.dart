import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AntAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
    'Referer': 'https://www.mayiyingshi.tv/',
  }));
  final String searchApi =
      'https://www.mayiyingshi.tv/vodsearch/-------------.html';
  final String seriesApi = 'https://www.mayiyingshi.tv/voddetail/';
  final String videoPageUrl = 'https://www.mayiyingshi.tv';
  final String baseUrl = 'https://www.mayiyingshi.tv/';
  final String videoApi = 'https://vip.sp-flv.com:8443/?url=';

  @override
  Future<List<Episode>> getEpisodes(String seriesId) async {
    try {
      Modular.get<Logger>().i(seriesApi + seriesId + '.html');
      var resp = await dio.get(seriesApi + seriesId + '.html');
      return _parseSeries(resp.data.toString());
    } catch (e) {
      Modular.get<Logger>().w(e);
    }
    return [];
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    var resp = await dio.get(videoPageUrl + episodeId);
    var url =
        await _parsePlayLink(resp.data.toString(), videoPageUrl + episodeId);
    Modular.get<Logger>().i(url);
    await controller.player.open(Media(url));
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    List<Series> ret = [];
    status = SearchStatus.pending;
    try {
      if (bangumiName.isNotEmpty) {
        var resp = await dio.get(searchApi + '?wd=${bangumiName}' + '&sq=yes',
            options: Options(contentType: 'application/x-www-form-urlencoded'));
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      if (searchKeyword.isNotEmpty) {
        var resp = await dio.get(searchApi + '?wd=${searchKeyword}' + '&sq=yes',
            options: Options(contentType: 'application/x-www-form-urlencoded'));
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      status = SearchStatus.success;
    } catch (e) {
      Modular.get<Logger>().w(e);
      status = SearchStatus.failed;
    }
    Modular.get<Logger>().i('Ant adapter returns ${ret.length} results');
    return ret;
  }

  Future<String> _parsePlayLink(String html, String myUrl) async {
    var doc = parse(html);
    String? url;
    var scriptElement = doc.querySelector('.stui-player__video')!.querySelectorAll('script')[0];
    if (scriptElement.text.contains('url')) {
        for (var line in scriptElement.text.split(',')) {
          if (line.contains("\"url\"")) {
            url =
                line.split(':')[1].replaceAll("\"", '').replaceAll(',', '');
          }
        }
      }
    if (url == null) {
      debugPrint('未找到视频资源');
    } else {
      debugPrint('找到视频资源 ${videoApi + url}');
    }
    var resp = await dio.get((videoApi + (url ?? '')));
    html = resp.data.toString();
    debugPrint('API返回为 $html');
    // 后续待完成
    var videoLink = '';
    return videoLink;
  }

  List<Episode> _parseSeries(String html) {
    var doc = parse(html);
    List<Episode> ret = [];
    var count = 0;
    doc.querySelectorAll('.play_source_list_item')[0].querySelectorAll('li').asMap().forEach((idx, li) {
      var href = li.querySelector('a')!.attributes['href']!;
      var name = '第 ${idx + 1} 话';
      ret.add(Episode(href, count, name));
      count++;
    });
    return ret;
  }

  List<Series> _parseSearchResult(String html) {
    var doc = parse(html);
    return doc
        .querySelector('.stui-vodlist__media')!
        .querySelectorAll('li')
        .map((li) {
      var id =
          li.querySelector('.thumb')!.querySelector('a')!.attributes['href']!;
      RegExp regExp = RegExp(r'\d+');
      Iterable<Match> matches = regExp.allMatches(id);
      for (Match match in matches) {
        String result = match.group(0) ?? '';
        id = result;
        debugPrint('ID为 $result');
      }
      var image = li
          .querySelector('.thumb')!
          .querySelector('a')!
          .attributes['data-original']!;
      var name = li.querySelector('h3 a@text')?.text ?? '';
      return Series(id, name, image: image);
    }).toList();
  }

  AntAdapter() : super('Ant', '本视频源支持番剧与影视剧');
}
