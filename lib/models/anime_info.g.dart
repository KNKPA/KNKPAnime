// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeInfoAdapter extends TypeAdapter<AnimeInfo> {
  @override
  final int typeId = 4;

  @override
  AnimeInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeInfo(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      (fields[6] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnimeInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.nameCn)
      ..writeByte(3)
      ..write(obj.nameJp)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.airDate)
      ..writeByte(6)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
