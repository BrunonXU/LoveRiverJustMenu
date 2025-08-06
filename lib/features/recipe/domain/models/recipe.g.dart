// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconType: fields[3] as String,
      totalTime: fields[4] as int,
      difficulty: fields[5] as String,
      servings: fields[6] as int,
      steps: (fields[7] as List).cast<RecipeStep>(),
      imagePath: fields[8] as String?,
      imageBase64: fields[15] as String?,
      imageUrl: fields[16] as String?,
      createdBy: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      isPublic: fields[12] as bool,
      rating: fields[13] as double,
      cookCount: fields[14] as int,
      sharedWith: (fields[17] as List).cast<String>(),
      isShared: fields[18] as bool,
      originalRecipeId: fields[19] as String?,
      sourceType: fields[20] as String,
      isPreset: fields[21] as bool,
      favoriteCount: fields[22] as int,
      emojiIcon: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconType)
      ..writeByte(4)
      ..write(obj.totalTime)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.servings)
      ..writeByte(7)
      ..write(obj.steps)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(15)
      ..write(obj.imageBase64)
      ..writeByte(16)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isPublic)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.cookCount)
      ..writeByte(17)
      ..write(obj.sharedWith)
      ..writeByte(18)
      ..write(obj.isShared)
      ..writeByte(19)
      ..write(obj.originalRecipeId)
      ..writeByte(20)
      ..write(obj.sourceType)
      ..writeByte(21)
      ..write(obj.isPreset)
      ..writeByte(22)
      ..write(obj.favoriteCount)
      ..writeByte(23)
      ..write(obj.emojiIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeStepAdapter extends TypeAdapter<RecipeStep> {
  @override
  final int typeId = 1;

  @override
  RecipeStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStep(
      title: fields[0] as String,
      description: fields[1] as String,
      duration: fields[2] as int,
      tips: fields[3] as String?,
      imagePath: fields[4] as String?,
      imageBase64: fields[6] as String?,
      ingredients: (fields[5] as List).cast<String>(),
      emojiIcon: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStep obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.tips)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.imageBase64)
      ..writeByte(5)
      ..write(obj.ingredients)
      ..writeByte(7)
      ..write(obj.emojiIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserFavoritesAdapter extends TypeAdapter<UserFavorites> {
  @override
  final int typeId = 2;

  @override
  UserFavorites read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFavorites(
      userId: fields[0] as String,
      favoriteRecipeIds: (fields[1] as List).cast<String>(),
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserFavorites obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.favoriteRecipeIds)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFavoritesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
