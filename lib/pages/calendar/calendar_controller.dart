import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/utils/bangumi.dart';
import 'package:mobx/mobx.dart';

part 'calendar_controller.g.dart';

class CalendarController = _CalendarController with _$CalendarController;

abstract class _CalendarController with Store {
  @observable
  List<List<AnimeInfo>> animeList = List.filled(7, []);

  var lastUpdatedTime = DateTime.now();

  bool _updatedCalendar() {
    DateTime currentTime = DateTime.now();
    DateTime currentTimeUTC8 = currentTime.toUtc().add(Duration(hours: 8));

    return lastUpdatedTime.day == currentTime.day &&
        lastUpdatedTime.day == currentTimeUTC8.day;
  }

  Future update() async {
    animeList = await Bangumi.fetchTodayAnime();
  }

  _CalendarController() {
    update();
  }
}
