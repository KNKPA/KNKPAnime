import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/adapters/adapter_registry.dart';
import 'package:knkpanime/pages/history/history_controller.dart';
import 'package:knkpanime/widgets/series_card.dart';
import 'package:logger/logger.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late var historyController = Modular.get<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: historyController.histories.length,
          itemBuilder: (context, index) {
            var history = historyController.histories[index];
            return SeriesCard(
              history.series,
              history.progresses[history.lastWatchEpisode]!,
              (anime) {
                Modular.get<Logger>()
                    .i('Selected history:\n${history.series.toString()}');

                Modular.to.pushNamed('/play/', arguments: {
                  'adapter': adapters
                      .where((element) => element.name == history.adapterName)
                      .first,
                  'series': history.series,
                }).then((_) => setState(() {}));
              },
              history.adapterName,
            );
          },
        ),
      ),
    );
  }
}
