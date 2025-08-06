// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 10;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      username: fields[10] as String?,
      photoURL: fields[3] as String?,
      phoneNumber: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      preferences: fields[7] as UserPreferences,
      coupleBinding: fields[8] as CoupleBinding?,
      stats: fields[9] as UserStats,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(10)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.photoURL)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.preferences)
      ..writeByte(8)
      ..write(obj.coupleBinding)
      ..writeByte(9)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 11;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      isDarkMode: fields[0] as bool,
      enableNotifications: fields[1] as bool,
      enableCookingReminders: fields[2] as bool,
      preferredDifficulty: fields[3] as String,
      preferredServings: fields[4] as int,
      userTags: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.enableNotifications)
      ..writeByte(2)
      ..write(obj.enableCookingReminders)
      ..writeByte(3)
      ..write(obj.preferredDifficulty)
      ..writeByte(4)
      ..write(obj.preferredServings)
      ..writeByte(5)
      ..write(obj.userTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoupleBindingAdapter extends TypeAdapter<CoupleBinding> {
  @override
  final int typeId = 12;

  @override
  CoupleBinding read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoupleBinding(
      partnerId: fields[0] as String,
      partnerName: fields[1] as String,
      bindingDate: fields[2] as DateTime,
      coupleId: fields[3] as String,
      intimacyLevel: fields[4] as int,
      cookingTogether: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CoupleBinding obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.partnerId)
      ..writeByte(1)
      ..write(obj.partnerName)
      ..writeByte(2)
      ..write(obj.bindingDate)
      ..writeByte(3)
      ..write(obj.coupleId)
      ..writeByte(4)
      ..write(obj.intimacyLevel)
      ..writeByte(5)
      ..write(obj.cookingTogether);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoupleBindingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 13;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      level: fields[0] as int,
      experience: fields[1] as int,
      recipesCreated: fields[2] as int,
      cookingCompleted: fields[3] as int,
      consecutiveDays: fields[4] as int,
      lastActiveDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.experience)
      ..writeByte(2)
      ..write(obj.recipesCreated)
      ..writeByte(3)
      ..write(obj.cookingCompleted)
      ..writeByte(4)
      ..write(obj.consecutiveDays)
      ..writeByte(5)
      ..write(obj.lastActiveDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
