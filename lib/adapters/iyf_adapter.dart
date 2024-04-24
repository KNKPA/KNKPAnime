import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:crypto/crypto.dart';

class IyfAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));
  late String publicKey;
  late List<String> privateKey;
  final Map<String, List<Episode>> cachedPlaylist = {};

  final baseUrl = 'https://www.iyf.tv/';
  final searchApi = 'https://rankv21.iyf.tv/v3/list/briefsearch';
  final playlistApi = 'https://m10.iyf.tv/v3/video/languagesplaylist';
  final playPageUrl = 'https://www.iyf.tv/play/';
  final playLinkApi = 'https://m10.iyf.tv/v3/video/play';

  @override
  Future<List<Episode>> getEpisodes(String seriesId) async {
    if (!cachedPlaylist.containsKey(seriesId)) {
      //await updateKeys(playPageUrl + seriesId);
      var queryParameters = {
        'cinema': 1,
        'vid': seriesId,
        'lsk': 1,
        'taxis': '0',
        'cid': '0,1,4,133'
      };
      queryParameters['vv'] =
          _getSignature(_buildQueryFromMap(queryParameters));
      queryParameters['pub'] = publicKey;

      var resp = await dio.get(playlistApi, queryParameters: queryParameters);
      cachedPlaylist[seriesId] = [];
      List<Episode> ret = [];
      (resp.data['data']['info'][0]['playList'] as List)
          .asMap()
          .forEach((idx, episode) {
        cachedPlaylist[seriesId]!
            .add(Episode(episode['key'], idx, episode['name']));
      });
    }
    return cachedPlaylist[seriesId]!;
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    var queryParameters = {
      'cinema': 1,
      'id': episodeId,
      'a': 0,
      'lang': 'none',
      'usersign': 1,
      'region': 'GL.',
      'device': 1,
      'isMasterSupport': 1,
    };
    queryParameters['vv'] = _getSignature(_buildQueryFromMap(queryParameters));
    queryParameters['pub'] = publicKey;

    var resp = await dio.get(playLinkApi, queryParameters: queryParameters);
    var paths = resp.data['data']['info'][0]['flvPathList'] as List;
    for (var path in paths.reversed) {
      try {
        Modular.get<Logger>().i(path['result']);
        var link = path['result'] as String;
        var queryString = link.substring(link.indexOf('?') + 1);
        link += '&vv=${_getSignature(queryString)}&pub=$publicKey';
        await controller.player.open(Media(link));
        return;
      } catch (e) {
        Modular.get<Logger>().w(e);
      }
    }
    throw '无法打开链接';
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    List<Series> ret = [];
    if (searchKeyword.isEmpty) return ret;
    status = SearchStatus.pending;
    try {
      var resp = await dio.post(searchApi, queryParameters: {
        'tags': searchKeyword,
        'orderby': 4,
        'page': 1,
        'size': 36,
        'desc': 1,
        'isserial': -1,
      }, data: {
        'tags': Uri.encodeFull(searchKeyword),
        'vv': _getSignature('tags=${Uri.encodeFull(searchKeyword)}'),
        'pub': publicKey,
      });
      for (var entry in resp.data['data']['info'][0]['result']) {
        ret.add(
            Series(entry['contxt'], entry['title'], image: entry['imgPath']));
        cachedPlaylist[entry['contxt']] = [];
        entry['languagesPlayList']['playList'].asMap().forEach((idx, episode) {
          cachedPlaylist[entry['contxt']]!
              .add(Episode(episode['key'], idx, episode['name']));
        });
      }
      status = SearchStatus.success;
    } catch (e) {
      Modular.get<Logger>().w(e);
      status = SearchStatus.failed;
    }
    Modular.get<Logger>().i('Iyf adapter returns ${ret.length} results');
    return ret;
  }

  String _getSignature(String query) {
    var input = publicKey + '&' + query.toLowerCase() + '&' + _getPrivateKey();
    return md5.convert(utf8.encode(input)).toString();
  }

  String _getPrivateKey() {
    final timePublicKeyIndex = DateTime.now().millisecondsSinceEpoch;
    final timePublicKey = timePublicKeyIndex.toString();
    return privateKey[timePublicKeyIndex % privateKey.length];
  }

  String _buildQueryFromMap(Map<String, Object> params) {
    return params.entries
        .map((entry) => '${entry.key}=${entry.value.toString()}')
        .join('&');
  }

  IyfAdapter() : super('Iyf', '其实... 这是个电视剧源\n该源不支持Bangumi搜索。') {
    init();
  }

  void init() async {
    updateKeys(baseUrl);
  }

  Future updateKeys(String url) async {
    var resp = await dio.get(url);
    var doc = parse(resp.data.toString());

    for (var script in doc.querySelectorAll('script')) {
      if (script.text.contains('injectJson')) {
        var jsonString = '';
        script.text.split('\n').forEach((line) {
          if (line.contains('injectJson')) {
            jsonString =
                line.substring(line.indexOf('{'), line.lastIndexOf(';'));
          }
        });
        var json = jsonDecode(jsonString);
        publicKey = json['config'][0]['pConfig']['publicKey'];
        privateKey =
            List.from(json['config'][0]['pConfig']['privateKey'] as List);
      }
    }
  }
}
