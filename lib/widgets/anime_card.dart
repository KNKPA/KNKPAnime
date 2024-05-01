import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/pages/favorite/favorite_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class AnimeCard extends StatefulWidget {
  final AnimeInfo anime;
  final Function(AnimeInfo) onTap;

  const AnimeCard(this.anime, this.onTap, {super.key});

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  late var favoriteController = Modular.get<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(widget.anime),
      child: Card(
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
                imageUrl: widget.anime.images?['large'] ?? '',
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
                    widget.anime.name,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    widget.anime.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                favoriteController.isFavorite(widget.anime)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                favoriteController.isFavorite(widget.anime)
                    ? favoriteController.deleteFavorite(widget.anime)
                    : favoriteController.addFavorite(widget.anime);
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
