import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/history.dart';
import 'package:knkpanime/models/image_set.dart';
import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/pages/settings/settings_controller.dart';

class Storage {
  static late Box<History> histories;
  static late Box<AnimeInfo> favorites;
  static ImageSet get imageSet {
    if (SettingsController().customImageSet == null) {
      return _defaultImageSet;
    }
    final imageSet = imageSets.get(SettingsController().customImageSet!);
    return imageSet ?? _defaultImageSet;
  }

  static late Box<ImageSet> imageSets;
  static late ImageSet _defaultImageSet;

  static Future init() async {
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(ProgressAdapter());
    Hive.registerAdapter(EpisodeAdapter());
    Hive.registerAdapter(SeriesAdapter());
    Hive.registerAdapter(AnimeInfoAdapter());
    Hive.registerAdapter(ImageSetAdapter());
    histories = await Hive.openBox('histories');
    favorites = await Hive.openBox('favorites');
    imageSets = await Hive.openBox<ImageSet>('imageSets');
    _defaultImageSet = ImageSet(
        (await rootBundle.load('assets/images/sidemenu_background.jpg'))
            .buffer
            .asUint8List(),
        (await rootBundle.load('assets/images/placeholder.jpg'))
            .buffer
            .asUint8List(),
        (await rootBundle.load('assets/images/no_image.jpg'))
            .buffer
            .asUint8List());
  }

  Storage._();
}
