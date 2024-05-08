import 'package:knkpanime/models/series.dart';
import 'package:knkpanime/models/episode.dart';
import 'package:knkpanime/models/source.dart';
import 'package:media_kit_video/media_kit_video.dart';

enum SearchStatus { pending, success, failed }

/// The base class that all the adapters must inherit.
abstract class AdapterBase {
  /// Source name, e.g.: Anime1, yhdm
  String name;

  /// Source description, will be displayed on the source selection window if available.
  String? description;

  /// Status to reflect each search.
  SearchStatus status = SearchStatus.success;

  AdapterBase(this.name, [this.description]);

  /// Given an anime name, search possible resources.
  /// [bangumiName] is the name provided by bgm.tv, which could be
  /// very detailed but hard to match.
  /// [searchKeyword] is the user input, usually simple and short but
  /// might not be precise.
  ///
  /// It is at the subclasses' will to decide which to use and how to use them,
  /// and it's also the subclasses' responsibility to update the status.
  Future<List<Series>> search(String bangumiName, String searchKeyword);

  /// Given an seriesId returned by [search], get video sources of that anime.
  Future<List<Source>> getSources(String seriesId);

  /// Pass the control of player to the adapter to initialize the player.
  /// This function should handle all the details such as authentication.
  Future<void> play(String episodeId, VideoController controller);

  @override
  String toString() {
    return name;
  }
}
