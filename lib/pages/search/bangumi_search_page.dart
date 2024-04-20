import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:knkpanime/widgets/anime_card.dart';
import 'package:knkpanime/widgets/source_selection_window.dart';
import 'package:logger/logger.dart';
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

  @override
  Widget build(BuildContext context) {
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
