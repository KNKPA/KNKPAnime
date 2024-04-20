import 'package:hive/hive.dart';

part 'anime_info.g.dart';

@HiveType(typeId: 4)
class AnimeInfo {
  @HiveField(0)
  int id;
  @HiveField(1)
  String url;
  @HiveField(2)
  String nameCn;
  @HiveField(3)
  String nameJp;
  @HiveField(4)
  String summary;
  @HiveField(5)
  String airDate;
  @HiveField(6)
  Map<String, String>? images;

  AnimeInfo(this.id, this.url, this.nameCn, this.nameJp, this.summary,
      this.airDate, this.images);

  String get name => nameCn.isNotEmpty ? nameCn : nameJp;

  @override
  String toString() {
    return 'id: $id\n'
        'url: $url\n'
        'Chinese name: $nameCn\n'
        'Japanese name: $nameJp';
  }
}
