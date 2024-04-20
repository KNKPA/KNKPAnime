import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:html/parser.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/series.dart';
import 'package:logger/logger.dart';
import 'package:media_kit_video/media_kit_video.dart';

class YhdmAdapter extends AdapterBase {
  final dio = Dio(BaseOptions(headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.3',
  }));

  final String searchApi = 'https://www.iyhdmm.com/s_all?ex=1&kw=';
  final String seriesApi = 'https://www.iyhdmm.com/showp/';

  @override
  Future<List<Episode>> getEpisodes(String seriesId) async {
    var resp = await dio.get('$seriesApi$seriesId.html');
    return _parseSeries(resp.data.toString());
  }

  @override
  Future<void> play(String episodeId, VideoController controller) {
    // I can't implement this because yhdm blocks my IP.....
    throw UnimplementedError();
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
    }
    Modular.get<Logger>().i('Fetched ${ret.length} results from yhdm');
    return ret;
  }

  List<Episode> _parseSeries(String html) {
    var doc = parse(html);
    // Yhdm has multiple video sources, we use the first for now.
    var ul = doc.getElementsByClassName('movurl').first.querySelector('ul');
    List<Episode> ret = [];
    ul!.querySelectorAll('li').asMap().forEach((idx, li) {
      ret.add(Episode(li.attributes['herf']!, idx));
    });
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

  YhdmAdapter()
      : super(
          '樱花动漫',
        );
}
