import 'package:knkpanime/models/anime_info.dart';
import 'package:knkpanime/utils/storage.dart';

class FavoriteController {
  late var storedFavorites = Storage.favorites;

  List<AnimeInfo> get favorites => storedFavorites.values.toList();

  bool isFavorite(AnimeInfo anime) {
    return !(storedFavorites.get(anime.id) == null);
  }

  void addFavorite(AnimeInfo anime) {
    storedFavorites.put(anime.id, anime);
  }

  void deleteFavorite(AnimeInfo anime) {
    storedFavorites.delete(anime.id);
  }
}
