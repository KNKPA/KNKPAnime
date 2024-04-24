import 'package:dio/dio.dart';
import 'package:knkpanime/models/anime_info.dart';

class Bangumi {
  Bangumi._();

  static const _todayBangumiApi = '/calendar';
  static const _searchApi = '/search/subject/';
  static final _dio = Dio(BaseOptions(baseUrl: 'https://api.bgm.tv', headers: {
    'User-Agent': 'KNKPA/KNKPAnime',
  }));

  static Future<List<List<AnimeInfo>>> fetchTodayAnime() async {
    var ret = <List<AnimeInfo>>[];
    var resp = await _dio.get(_todayBangumiApi);
    var temp = <AnimeInfo>[];
    for (var weekday in resp.data) {
      for (var anime in weekday['items']) {
        temp.add(_toAnimeInfo(anime));
      }
      ret.add(temp);
      temp = <AnimeInfo>[];
    }
    return ret;
  }

  static Future<(List<AnimeInfo>, int)> search(String keyword,
      {int? start, int? maxResults}) async {
    var ret = <AnimeInfo>[];
    var resp = await _dio.get(_searchApi + keyword, queryParameters: {
      'type': 2,
      'max_results': maxResults ?? 25,
      'start': start ?? 0,
      'responseGroup': 'large',
    });
    if (resp.statusCode != 200 || resp.data is String) {
      throw resp.toString();
    }
    for (var anime in resp.data['list']) {
      ret.add(_toAnimeInfo(anime));
    }
    return (ret, resp.data['results'] as int);
  }

  static AnimeInfo _toAnimeInfo(dynamic anime) {
    var images = anime['images'] == null
        ? null
        : Map<String, String>.from(anime['images']);
    return AnimeInfo(anime['id'], anime['url'], anime['name_cn'], anime['name'],
        anime['summary'], anime['air_date'], images);
  }
}
