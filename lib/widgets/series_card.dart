import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:knkpanime/models/history.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/utils/utils.dart';
import 'package:logger/logger.dart';

class SeriesCard extends StatelessWidget {
  final Series series;
  final Progress? progress;
  final Function(Series) onTap;
  final String sourceName;

  const SeriesCard(this.series, this.progress, this.onTap, this.sourceName,
      {super.key});

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
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.jpg',
                image: series.image ?? '',
                width: 100.0,
                height: 150.0,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
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
            )
          ],
        ),
      ),
    );
  }
}
