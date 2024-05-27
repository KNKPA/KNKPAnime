import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/pages/search/adapter_search_controller.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class SourceSelectionWindow extends StatefulWidget {
  final AnimeInfo anime;
  final String searchKeyword;
  final Function(AdapterBase, Series) onSearchResultTap;

  /// [searchKeyword] is the keyword typed in the search bar. it is used later to call adapter's search function.
  ///
  /// [onSearchResultTap] is the function to call when the user selects
  /// a search result returned by adapters. This function should
  /// navigate to the media page.
  const SourceSelectionWindow(
      {super.key,
      required this.anime,
      required this.searchKeyword,
      required this.onSearchResultTap});

  @override
  State<SourceSelectionWindow> createState() => _SourceSelectionWindowState();
}

class _SourceSelectionWindowState extends State<SourceSelectionWindow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var selectedSource = 0;
  late final adapterSearchController = Modular.get<AdapterSearchController>();
  late final List<AdapterBase> adapters;

  @override
  void initState() {
    super.initState();
    adapters = adapterSearchController.availableAdapters;
    _tabController = TabController(length: adapters.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedSource = _tabController.index;
      });
    });
    adapterSearchController.search(widget.anime.name, widget.searchKeyword);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimeInfo(widget.anime),
          const Divider(),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            controller: _tabController,
            tabs: adapters
                .map((adapter) => Observer(
                      builder: (context) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(adapter.name),
                          const SizedBox(width: 5.0),
                          Container(
                            width: 16.0,
                            height: 16.0,
                            decoration: BoxDecoration(
                              color: Utils.getColorFromStatus(
                                  adapterSearchController
                                      .statuses[adapters.indexOf(adapter)]),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${adapterSearchController.searchResults[adapters.indexOf(adapter)].length}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          Expanded(
            child: Observer(
              builder: (context) => TabBarView(
                controller: _tabController,
                children: adapterSearchController.searchResults.map((results) {
                  var index =
                      adapterSearchController.searchResults.indexOf(results);
                  if (adapterSearchController.statuses[index] ==
                      SearchStatus.success) {
                    return ListView(
                      children: results
                          .map(
                            (searchResult) => InkWell(
                              onTap: () => widget.onSearchResultTap(
                                  adapters[index], searchResult),
                              child: Card(
                                child: ListTile(
                                  title: Text(searchResult.name),
                                  subtitle: searchResult.description != null
                                      ? Text(searchResult.description!)
                                      : null,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  } else {
                    if (adapterSearchController.statuses[index] ==
                        SearchStatus.failed) {
                      return const Center(
                        child: Text('该番剧源获取失败'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                }).toList(),
              ),
            ),
          ),
          Container(height: 20), // 添加下边距以解决 overflow
        ],
      ),
    );
  }

  Widget _buildAnimeInfo(AnimeInfo anime) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                placeholder: (context, url) => Image.asset(
                  width: 100.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                  'assets/images/placeholder.jpg',
                ),
                imageUrl: anime.images?['large'] ?? '',
                width: 100.0,
                height: 150.0,
                fit: BoxFit.cover,
                fadeOutDuration: const Duration(milliseconds: 120),
                fadeInDuration: const Duration(milliseconds: 120),
                // filterQuality: FilterQuality.low,
                errorWidget: (context, error, stackTrace) {
                  Modular.get<Logger>().w(error);
                  return Image.asset(
                    width: 100.0,
                    height: 150.0,
                    fit: BoxFit.cover,
                    'assets/images/no_image.jpg',
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    anime.name,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    anime.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    adapters[selectedSource].description != null
                        ? '番剧源说明：'
                        : '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(adapters[selectedSource].description ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
