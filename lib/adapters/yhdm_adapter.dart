import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/source.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:knkpanime/adapters/models/yhmd_response.dart';
import 'package:logger/logger.dart';

class YhdmAdapter extends AdapterBase {
  final logger = Modular.get<Logger>();
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
    'Referer': 'https://www.yhmgo.com/',
  }));

  final String searchApi = 'https://www.yhmgo.com/s_all?ex=1&kw=';
  final String seriesApi = 'https://www.yhmgo.com/showp/';
  // https://www.iyhdmm.com/playurl?aid=22409&playindex=1&epindex=0&r=0.7238267551203132
  final String videoApi = 'https://www.yhmgo.com/playurl';

  @override
  Future<List<Source>> getSources(String seriesId) async {
    var resp = await dio.get('$seriesApi$seriesId.html');
    return _parseSeries(resp.data.toString());
  }

  @override
  Future<void> play(String episodeId, VideoController controller) async {
    Random random = Random();
    double randomNumber = random.nextDouble(); // 生成在 0 到 1 之间的随机数
    String randomNumberString = randomNumber.toStringAsFixed(16);
    List<String> cookies = [];
    YhdmResponse result = YhdmResponse.extractNumbers(episodeId);
    var url = videoApi +
        '?aid=${result.aid}' +
        '&playindex=${result.playindex}' +
        '&epindex=${result.epindex}' +
        '&r=$randomNumberString';
    dio.options.headers['Cookie'] = '';
    var resp = await dio.get(url);
    if (resp.data.toString().contains('ipchk')) {
      cookies = resp?.headers['set-cookie'] ?? [];
      logger.i('用于视频验权的cookie为 ${videoCookieC(cookies)}');
      dio.options.headers['Cookie'] = videoCookieC(cookies);
      resp = await dio.get(url);
    }
    await controller.player.open(Media(_parseVideoUrl(resp.data.toString())));
    // throw UnimplementedError();
  }

  @override
  Future<List<Series>> search(String bangumiName, String searchKeyword) async {
    List<Series> ret = [];
    status = SearchStatus.pending;
    try {
      // if (bangumiName.isNotEmpty) {
      //   var resp = await dio.get(searchApi + bangumiName);
      //   ret.addAll(_parseSearchResult(resp.data.toString()));
      // }
      if (searchKeyword.isNotEmpty) {
        var resp = await dio.get(searchApi + searchKeyword);
        ret.addAll(_parseSearchResult(resp.data.toString()));
      }
      status = SearchStatus.success;
    } catch (e) {
      status = SearchStatus.failed;
      rethrow;
    }
    Modular.get<Logger>().i('Fetched ${ret.length} results from yhdm');
    return ret;
  }

  List<Source> _parseSeries(String html) {
    var doc = parse(html);
    List<Source> ret = [];
    for (final div in doc.getElementsByClassName('movurl')) {
      final ul = div.querySelector('ul');
      if (ul?.children.isNotEmpty ?? false) {
        List<Episode> episodes = [];
        ul!.querySelectorAll('li').asMap().forEach((idx, li) {
          episodes.add(Episode(li.querySelector('a')!.attributes['href']!, idx,
              li.querySelector('a')!.attributes['title']));
        });
        ret.add(Source(episodes));
      }
    }
    return ret;
  }

  List<Series> _parseSearchResult(String html) {
    /*
    The relevant part of the document would look like:
     <ul>
        <li>
            <a href="/showp/11112.html">
                <img referrerpolicy="no-referrer" src="https://pic.rmb.bdstatic.com/bjh/down/2d2dbb721ecd11cc10756aea4704fa52.jpeg" alt="轻音少女剧场版"></a>
            <h2>
                <a href="/showp/11112.html" title="轻音少女剧场版">轻音少女剧场版</a>
            </h2>
            <span>
                <font color="red">[全集]</font></span>
            <span>类型：搞笑 校园 百合 治愈</span>
            <p>《轻音少女》剧场版（日文：映画「けいおん！」），是改编自日本漫画家Kakifly原作的漫画《轻音少女》（けいおん！）同名动画的延续篇剧场版电影。由动画版导演山田尚子执导，京都动画负责动画制作，松竹株式会社发行，2011年12月3日于日本正式公映。
影片以伦敦的毕业旅行作为主题。临近毕业的主人公平泽唯（CV：丰崎爱生）与轻音乐部3年级的3人、2年级的1人，当听到教室的同级生关于毕业旅行的计划时，决定也要选择一个地方进行一次毕业旅行。于是她们各自提出自己想要去的目的地，最终通过抽签选中3年级的秋山澪（CV：日笠阳子）提出的去伦敦的计划。几位女生在准备旅行指南书等旅行用品的同时，关于伦敦的想象也在飞驰。
（注：按照剧情时间轴，《轻音少女剧场版》囊括了TV动画的第22集之后的内容。而#27在剧情上为#13.5，请根据需要选择观看顺序。）</p>
        </li>
		</ul>
    */
    var doc = parse(html);
    var ul = doc.getElementsByClassName('lpic').first.querySelector('ul');
    return ul!.children.map((li) {
      var name = li.querySelector('h2')!.querySelector('a')!.text;
      var link = li.querySelector('a')!.attributes['href']!;
      var desc = li.querySelector('p')?.text;
      var img = li.querySelector('a')?.querySelector('img')?.attributes['src'];

      var id = link.split('/').last.split('.').first;
      return Series(id, name, description: desc, image: img);
    }).toList();
  }

// 啊啊啊，樱花的加密比B站还离谱
  String _parseVideoUrl(String responseText) {
    String decodeText(String text) {
      if (!text.contains('{')) {
        String decodedText = '';
        int key = 1561;
        int length = text.length;
        for (int i = 0; i < length; i += 2) {
          int charCode = int.parse(text[i] + text[i + 1], radix: 16);
          charCode =
              (charCode + 1048576 - key - (length / 2 - 1 - i / 2)).toInt() %
                  256;
          decodedText = String.fromCharCode(charCode) + decodedText;
        }
        text = decodedText;
      }
      return Uri.decodeFull(text);
    }

    Map<String, dynamic> videoInfo = jsonDecode(decodeText(responseText));
    return videoInfo['vurl'];
  }

  // 啊啊啊，除了接口加密还有cookie鉴权
  videoCookieC(List<String> baseCookies) {
    String finalCookie = '';
    String baseCookieString = baseCookies.join('; ');
    baseCookieString.split('; ').forEach((cookieString) {
      if (cookieString.contains('=')) {
        List<String> cookieParts = cookieString.split('=');
        if (cookieParts[0] == 't1' || cookieParts[0] == 'k1') {
          finalCookie =
              finalCookie + cookieParts[0] + '=' + cookieParts[1] + '; ';
        }
      }
    });
    finalCookie = finalCookie.replaceAll(RegExp(r';\s*$'), '');
    return finalCookie;
  }

  YhdmAdapter()
      : super(
          'Sakura',
        );
}
