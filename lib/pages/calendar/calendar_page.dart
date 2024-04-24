import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/calendar/calendar_controller.dart';
import 'package:knkpanime/widgets/anime_card.dart';
import 'package:knkpanime/widgets/source_selection_window.dart';
import 'package:logger/logger.dart';

// Deprecated page

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage>
    with SingleTickerProviderStateMixin {
  final calendarController = Modular.get<CalendarController>();
  late TabController _tabController;
  final weekdayNameMap = [
    '星期一',
    '星期二',
    '星期三',
    '星期四',
    '星期五',
    '星期六',
    '星期日',
  ];
  var selectedDay = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    calendarController.update();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.index = selectedDay;
    _tabController.addListener(() {
      setState(() {
        selectedDay = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => Column(
              children: [
                TabBar(
                    controller: _tabController,
                    tabs: weekdayNameMap.map((e) => Text(e)).toList()),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: calendarController.animeList
                        .map((animes) => ListView(
                              children: animes
                                  .map((anime) => AnimeCard(anime, (anime) {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                SourceSelectionWindow(
                                                  anime: anime,
                                                  searchKeyword: '',
                                                  onSearchResultTap:
                                                      (adapter, res) {
                                                    Modular.get<Logger>().i(
                                                        'Selected resource: ${res.toString()}');
                                                    Modular.to.pushNamed(
                                                        '/play/',
                                                        arguments: {
                                                          'adapter': adapter,
                                                          'series': res,
                                                        });
                                                  },
                                                ));
                                      }))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                )
              ],
            ));
  }
}
