import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/utils/bangumi.dart';
import 'package:mobx/mobx.dart';

part 'today_controller.g.dart';

class TodayController = _TodayController with _$TodayController;

abstract class _TodayController with Store {
  @observable
  var animeList = <List<AnimeInfo>>[];

  var lastUpdatedTime = DateTime.now();

  bool _updatedToday() {
    DateTime currentTime = DateTime.now();
    DateTime currentTimeUTC8 = currentTime.toUtc().add(Duration(hours: 8));

    return lastUpdatedTime.day == currentTime.day &&
        lastUpdatedTime.day == currentTimeUTC8.day;
  }

  Future init() async {
    if (animeList.isEmpty || !_updatedToday()) {
      // Update list if the list is empty or a new day has came (both locally and in UTC+8)
      animeList = await Bangumi.fetchTodayAnime();
      print('fetched calendar');
    }
  }
}
