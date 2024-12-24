import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'image_set.g.dart';

@HiveType(typeId: 5)
class ImageSet {
  @HiveField(0)
  Uint8List sideMenuBackground;
  @HiveField(1)
  Uint8List coverPlaceholder;
  @HiveField(2)
  Uint8List coverNoImage;

  ImageSet(this.sideMenuBackground, this.coverPlaceholder, this.coverNoImage) {}
}
