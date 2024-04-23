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

class BimiAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));
  final String searchApi = 'https://www.bimiacg4.net/vod/search/';
  final String seriesApi = 'https://www.bimiacg4.net/bangumi/bi/';
  final String videoPageUrl = 'https://www.bimiacg4.net';
  final String baseUrl = 'https://www.bimiacg4.net';
  final String playerPhpUrl = 'https://www.bimiacg4.net/static/danmu/play.php';

  @override
  Future<List<Episode>> getEpisodes(String seriesId) async {
    try {
      Modular.get<Logger>().i(seriesApi + seriesId);
      var resp = await dio.get(seriesApi + seriesId);
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
    // TODO: sometimes this returns a m3u8 playlist, sometimes it's a mp4 file.
    // handle them both.
    // Besides, sometimes mp4 files also require a `t` parameter, but I can't
    // reproduce this problem in the browser.
    await controller.player.open(Media(url));
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    List<Series> ret = [];
    status = SearchStatus.pending;
    try {
      if (bangumiName.isNotEmpty) {
        var resp = await dio.post(searchApi,
            data: {'wd': bangumiName},
            options: Options(contentType: 'application/x-www-form-urlencoded'));
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      if (searchKeyword.isNotEmpty) {
        var resp = await dio.post(searchApi,
            data: {'wd': searchKeyword},
            options: Options(contentType: 'application/x-www-form-urlencoded'));
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      status = SearchStatus.success;
    } catch (e) {
      Modular.get<Logger>().w(e);
      status = SearchStatus.failed;
    }
    Modular.get<Logger>().i('Bimi adapter returns ${ret.length} results');
    return ret;
  }

  Future<String> _parsePlayLink(String html, String myUrl) async {
    var doc = parse(html);
    for (var script in doc.querySelectorAll('script')) {
      if (script.text.contains('player_aaaa')) {
        for (var line in script.text.split(',')) {
          if (line.contains("\"url\"")) {
            var url =
                line.split(':')[1].replaceAll("\"", '').replaceAll(',', '');
            var resp = await dio.get(playerPhpUrl, queryParameters: {
              'url': url,
              'myurl': myUrl,
            });
            doc = parse(resp.data.toString());
            for (var script in doc.querySelectorAll('script')) {
              if (script.text.contains('url')) {
                var line = script.text.trim().split('\n').first;
                var url = line.substring(
                    line.indexOf("'") + 1, line.lastIndexOf("'"));
                if (url.contains('m3u8')) {
                  // In this case, url is represented in relative path
                  // at least in all the case I've seen = =
                  var path = url.substring(1);
                  return baseUrl + path;
                } else {
                  // mp4 file
                  return url;
                }
              }
            }
          }
        }
      }
    }
    return '';
  }

  List<Episode> _parseSeries(String html) {
    var doc = parse(html);
    /*
      <div class="play_source_tab" id="tab">
          <a class="play_group_active">线路：Danma P</a>
          <a>线路：Danmu B</a>
          <a>线路：Danma C＋</a>
      </div>

      <ul class="player_list">
      <li>
          <a href="/bangumi/573/play/3/1/">第01话</a>
      </li>
    */
    List<Episode> ret = [];
    doc.querySelector('#tab')!.querySelectorAll('a').asMap().forEach((idx, a) {
      var sourceName = a.text;
      doc
          .querySelectorAll('.player_list')[idx]
          .querySelectorAll('li')
          .asMap()
          .forEach((idx, li) {
        var href = li.querySelector('a')!.attributes['href']!;
        var name = li.querySelector('a')!.text;
        ret.add(Episode(href, idx, '$sourceName $name'));
      });
    });
    return ret;
  }

  List<Series> _parseSearchResult(String html) {
    var doc = parse(html);
    /*
      <ul class="drama-module clearfix tab-cont">
          <li class="item">
              <a href="/bangumi/bi/9131/" title="吹响悠风号 第三季" target="_blank" class="img">
                  <img class="lazy" src="https://lz.sinaimg.cn/mw1024/006yt1Omgy1hk52rwtbloj30m80vbds1.jpg" referrerpolicy="no-referrer" data-original="https://lz.sinaimg.cn/mw1024/006yt1Omgy1hk52rwtbloj30m80vbds1.jpg" alt="吹响悠风号 第三季" width="170" height="224"/>
                  <span class="mask">
                      <p>导演：石原立也</p>
                      <i class="iconfont icon-play"></i>
                  </span>
              </a>
              <div class="info">
                  <a href="/bangumi/bi/9131/" title="吹响悠风号 第三季" target="_blank">吹响悠风号 第三季</a>
                  <p title="更新至02话">
                      <span class="fl">更新至02话</span>
                  </p>
              </div>
          </li>
      </ul>
     */
    return doc
        .querySelector('.drama-module')!
        .querySelectorAll('li')
        .map((div) {
      var a = div.querySelector('a')!;
      var id = a.attributes['href']!.split('/')[3];
      var image = div.querySelector('img')?.attributes['data-original'];
      var name = a.attributes['title']!;
      return Series(id, name, image: image);
    }).toList();
  }

  BimiAdapter() : super('Bimi', '该视频源目前仅能解析部分视频，如果长时间加载可考虑换源。');
}
