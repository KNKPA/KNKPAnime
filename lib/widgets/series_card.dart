import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/history.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class SeriesCard extends StatelessWidget {
  final Series series;
  final Progress? progress;
  final Function(Series) onTap;
  final String sourceName;
  final Function()? onDelete;

  const SeriesCard(this.series, this.progress, this.onTap, this.sourceName,
      {super.key, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(series),
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
                imageUrl: series.image ?? '',
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
                    series.name,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '番剧源：$sourceName',
                    style: const TextStyle(fontSize: 12),
                  ),
                  progress != null
                      ? Text(
                          '上次看到 ${progress!.episode.name} ${Utils.dur2str(progress!.progress)}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : Container(),
                  const SizedBox(height: 5.0),
                  Text(
                    series.description ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            onDelete == null
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete!,
                  ),
          ],
        ),
      ),
    );
  }
}
