import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/pages/favorite/favorite_controller.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:knkpanime/widgets/anime_card.dart';
import 'package:knkpanime/widgets/source_selection_window.dart';
import 'package:logger/logger.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late var favoriteController = Modular.get<FavoriteController>();
  List<AnimeInfo> favorites = [];

  @override
  void initState() {
    super.initState();
    favorites = favoriteController.favorites;
    setState(() {});
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
            favorites = favoriteController.favorites
                .where((element) => element.name.contains(value))
                .toList();
            setState(() {});
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: favorites
              .map(
                (anime) => AnimeCard(anime, (anime) {
                  Modular.get<Logger>()
                      .i('Clicked in favorite page: \n${anime.name}');
                  showDialog(
                      context: context,
                      builder: (context) => SourceSelectionWindow(
                            anime: anime,
                            searchKeyword: '',
                            onSearchResultTap: (adapter, res) {
                              Modular.get<Logger>()
                                  .i('Selected resource: ${res.toString()}');
                              Modular.to.pushNamed('/play/', arguments: {
                                'adapter': adapter,
                                'series': res,
                              });
                            },
                          ));
                }),
              )
              .toList(),
        ),
      ),
    );
  }
}
