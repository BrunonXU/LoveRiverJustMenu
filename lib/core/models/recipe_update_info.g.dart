// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_update_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeUpdateInfoAdapter extends TypeAdapter<RecipeUpdateInfo> {
  @override
  final int typeId = 20;

  @override
  RecipeUpdateInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeUpdateInfo(
      recipeId: fields[0] as String,
      localVersion: fields[1] as DateTime,
      cloudVersion: fields[2] as DateTime,
      changedFields: (fields[3] as List).cast<String>(),
      checkedAt: fields[4] as DateTime,
      isIgnored: fields[5] as bool,
      importance: fields[6] as UpdateImportance,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeUpdateInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.recipeId)
      ..writeByte(1)
      ..write(obj.localVersion)
      ..writeByte(2)
      ..write(obj.cloudVersion)
      ..writeByte(3)
      ..write(obj.changedFields)
      ..writeByte(4)
      ..write(obj.checkedAt)
      ..writeByte(5)
      ..write(obj.isIgnored)
      ..writeByte(6)
      ..write(obj.importance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeUpdateInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpdateImportanceAdapter extends TypeAdapter<UpdateImportance> {
  @override
  final int typeId = 21;

  @override
  UpdateImportance read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UpdateImportance.normal;
      case 1:
        return UpdateImportance.important;
      case 2:
        return UpdateImportance.critical;
      default:
        return UpdateImportance.normal;
    }
  }

  @override
  void write(BinaryWriter writer, UpdateImportance obj) {
    switch (obj) {
      case UpdateImportance.normal:
        writer.writeByte(0);
        break;
      case UpdateImportance.important:
        writer.writeByte(1);
        break;
      case UpdateImportance.critical:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateImportanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
