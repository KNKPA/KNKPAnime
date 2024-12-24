// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageSetAdapter extends TypeAdapter<ImageSet> {
  @override
  final int typeId = 5;

  @override
  ImageSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageSet(
      fields[0] as Uint8List,
      fields[1] as Uint8List,
      fields[2] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, ImageSet obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sideMenuBackground)
      ..writeByte(1)
      ..write(obj.coverPlaceholder)
      ..writeByte(2)
      ..write(obj.coverNoImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
