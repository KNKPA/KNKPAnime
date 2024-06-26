import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_base.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/pages/search/adapter_search_controller.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:knkpanime/widgets/series_card.dart';
import 'package:logger/logger.dart';

class AdapterSearchPage extends StatefulWidget {
  const AdapterSearchPage({super.key});

  @override
  State<AdapterSearchPage> createState() => _AdapterSearchPageState();
}

class _AdapterSearchPageState extends State<AdapterSearchPage>
    with SingleTickerProviderStateMixin {
  late final adapterSearchController = Modular.get<AdapterSearchController>();
  late TabController _tabController;
  late final List<AdapterBase> adapters;

  @override
  void initState() {
    adapters = adapterSearchController.availableAdapters;
    _tabController = TabController(length: adapters.length, vsync: this);
    adapterSearchController.clear();
    super.initState();
  }

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
            adapterSearchController.search('', value);
          },
        ),
      ),
      body: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            controller: _tabController,
            tabs: adapters
                .map((adapter) => Observer(
                      builder: (context) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            adapter.name,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                      children: [
                        Text(adapters[index].description ?? ''),
                        ...results.map(
                          (searchResult) => SeriesCard(
                              searchResult,
                              Modular.get<HistoryController>().lastWatching(
                                  searchResult, adapters[index].name), (anime) {
                            Modular.get<Logger>().i(
                                'Selected anime:\n${searchResult.toString()}');

                            Modular.to.pushNamed('/play/', arguments: {
                              'adapter': adapters[index],
                              'series': searchResult,
                            }).then((_) => setState(() {}));
                          }, adapters[index].name),
                        )
                      ],
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
          )
        ],
      ),
    );
  }
}
