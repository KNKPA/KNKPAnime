import 'package:knkpanime/models/episode.dart';

class Source {
  List<Episode> episodes;
  String? sourceName;

  Source(this.episodes, [this.sourceName]);

  Source.fromDynamicJson(dynamic json)
      : episodes = (json['episodes'] as List)
            .map((e) => Episode.fromDynamicJson(e))
            .toList(),
        sourceName = json['sourceName'];
}
