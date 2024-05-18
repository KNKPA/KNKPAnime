import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:knkpanime/widgets/anime_card.dart';
import 'package:knkpanime/widgets/source_selection_window.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'bangumi_search_controller.dart';

class BangumiSearchPage extends StatefulWidget {
  const BangumiSearchPage({super.key});

  @override
  State<BangumiSearchPage> createState() => _BangumiSearchPageState();
}

class _BangumiSearchPageState extends State<BangumiSearchPage> {
  final BangumiSearchController bangumiSearchController =
      Modular.get<BangumiSearchController>();
  final logger = Modular.get<Logger>();

  void showNewChangeDialog(BuildContext context) {
    // TODO: Remove this popup window and related pref in future versions.
    // It's so fxxking ugly to put it here. But I don't want to all new packages and this will be removed soon... so whatever.
    final prefs = Modular.get<SettingsController>().prefs;
    if (prefs.getBool('showNewChanges') ?? true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Introducing (戏剧性地拉长声调) New! (掷地) Changes! (有声)'),
          content: const SingleChildScrollView(
            child: Text('在这个新版本中，本软件添加了对“云JavaScript适配器”的支持。\n'
                '什么是云JavaScript适配器呢？简单来说，这个新版本增加了从网络上获取JavaScript代码并执行的功能。在之前的版本中，所有适配器都是在写代码的时候都确定好的，在代码发布后，如果想新增适配器或调整已有适配器的代码，就需要重新编译软件并发布新版本。作者也知道反反复复更新新版本有多烦，别说这个软件还没有上架商店，想更新就只能删掉重装。为了解决这个问题，我们引入了云JavaScript适配器，从此更新适配器再也不需要更新版本了！\n'
                '除此之外，这个功能带来的另一个改变是，任何人都可以绕过向GitHub主仓库提交PR的方式，编写并分发自己的适配器了。只要在设置->管理JavaScript适配器界面输入适配器代码文件的URL，就可以使用你的适配器，而不需要作者的同意。\n'
                '不过，这也意味着在您的设备上执行任何人发布的代码 —— With flexibility, come dangers. 请在使用这个功能的时候多加小心！'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                prefs.setBool('showNewChanges', false);
                Navigator.of(context).pop();
              },
              child: const Text('知道了，不再提醒'),
            ),
            TextButton(
              onPressed: () {
                prefs.setBool('showNewChanges', false);
                launchUrlString(
                    'https://github.com/KNKPA/KNKPAnime-js-adapters');
                Navigator.of(context).pop();
              },
              child: const Row(
                children: [
                  Spacer(),
                  Text('查看适配器代码Repo'),
                  Icon(Icons.open_in_new)
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showNewChangeDialog(context));
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.search),
        elevation: 2,
        title: TextField(
          autofocus: Utils.isDesktop(),
          decoration: const InputDecoration(
            hintText: '搜索',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            bangumiSearchController.search(value);
          },
        ),
      ),
      body: SafeArea(
        child: Observer(builder: (context) {
          if (bangumiSearchController.failed) {
            return const Center(
              child: Text('搜索失败（可能是由于Bangumi API导致，可以尝试换关键词搜索）'),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: bangumiSearchController.searchResults.length +
                  (bangumiSearchController.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == bangumiSearchController.searchResults.length) {
                  if (bangumiSearchController.hasMore) {
                    bangumiSearchController.loadMore();
                  }
                  return const Center(child: CircularProgressIndicator());
                }
                final anime = bangumiSearchController.searchResults[index];
                return AnimeCard(anime, (anime) {
                  logger.i('Clicked in search page: \n${anime.name}');
                  showDialog(
                      context: context,
                      builder: (context) => SourceSelectionWindow(
                            anime: anime,
                            searchKeyword: bangumiSearchController.keyword,
                            onSearchResultTap: (adapter, res) {
                              Modular.get<Logger>()
                                  .i('Selected resource: ${res.toString()}');
                              Modular.to.pushNamed('/play/', arguments: {
                                'adapter': adapter,
                                'series': res,
                              });
                            },
                          ));
                });
              },
            );
          }
        }),
      ),
    );
  }
}
