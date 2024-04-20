import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/pages/today/today_controller.dart';

// Deprecated page

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final todayController = Modular.get<TodayController>();

  @override
  void initState() {
    todayController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => ListView(
              children: todayController.animeList
                  .map((e) => Text(e[0].name))
                  .toList(),
            ));
  }
}
