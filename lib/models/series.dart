import 'package:hive/hive.dart';

part 'series.g.dart';

@HiveType(typeId: 3)
class Series {
  /// Anime name
  @HiveField(0)
  String name;

  /// Anime series id, defined by each adapter and will later be used to
  /// fetch detailed info.
  @HiveField(1)
  String seriesId;

  /// Optional description for the anime. If not null, this will be
  /// displayed with the title on the source selection window.
  @HiveField(2)
  String? description;

  /// Optional thumbnail image url. If not null, this will be displayed
  /// on the history page
  @HiveField(3)
  String? image;

  Series(this.seriesId, this.name, {this.description, this.image});

  Series.fromDynamicJson(dynamic json)
      : seriesId = json['seriesId']!,
        name = json['name']!,
        description = json['description'],
        image = json['image'];

  @override
  String toString() {
    return 'Name: $name\nId: $seriesId\nDescription: $description';
  }
}
