/// 🔐 用户数据模型
/// 
/// 定义应用中的用户实体，包含基本信息和个人设置
/// 用于 Firebase Auth 和 Firestore 数据交互
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:hive/hive.dart';

part 'app_user.g.dart';

/// 🧑‍💻 应用用户模型
/// 
/// 包含用户的基本信息、偏好设置和情侣绑定状态
/// 支持 Hive 本地存储和 Firestore 云端存储
@HiveType(typeId: 10)
class AppUser extends HiveObject {
  /// 用户唯一标识符 (Firebase UID)
  @HiveField(0)
  final String uid;
  
  /// 邮箱地址
  @HiveField(1)
  final String email;
  
  /// 显示名称 (用户昵称)
  @HiveField(2)
  final String? displayName;
  
  /// 头像 URL
  @HiveField(3)
  final String? photoURL;
  
  /// 手机号码
  @HiveField(4)
  final String? phoneNumber;
  
  /// 账号创建时间
  @HiveField(5)
  final DateTime createdAt;
  
  /// 最后更新时间
  @HiveField(6)
  final DateTime updatedAt;
  
  /// 🏠 用户偏好设置
  @HiveField(7)
  final UserPreferences preferences;
  
  /// 💑 情侣绑定信息
  @HiveField(8)
  final CoupleBinding? coupleBinding;
  
  /// 📊 用户统计数据
  @HiveField(9)
  final UserStats stats;
  
  /// 构造函数
  /// 
  /// [uid] 用户唯一标识符
  /// [email] 邮箱地址
  /// [displayName] 显示名称
  /// [photoURL] 头像 URL
  /// [phoneNumber] 手机号码
  /// [createdAt] 创建时间
  /// [updatedAt] 更新时间
  /// [preferences] 用户偏好设置
  /// [coupleBinding] 情侣绑定信息
  /// [stats] 用户统计数据
  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    this.coupleBinding,
    required this.stats,
  });
  
  /// 🏭 从 Firebase User 创建 AppUser
  /// 
  /// [firebaseUser] Firebase 用户对象
  /// [preferences] 用户偏好设置（可选）
  /// [coupleBinding] 情侣绑定信息（可选）
  /// [stats] 用户统计数据（可选）
  factory AppUser.fromFirebaseUser(
    dynamic firebaseUser, {
    UserPreferences? preferences,
    CoupleBinding? coupleBinding,
    UserStats? stats,
  }) {
    final now = DateTime.now();
    
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata?.creationTime ?? now,
      updatedAt: now,
      preferences: preferences ?? UserPreferences.defaultSettings(),
      coupleBinding: coupleBinding,
      stats: stats ?? UserStats.initial(),
    );
  }
  
  /// 🗺️ 从 Firestore 文档创建 AppUser
  /// 
  /// [doc] Firestore 文档数据
  /// [uid] 用户唯一标识符
  factory AppUser.fromFirestore(Map<String, dynamic> doc, String uid) {
    return AppUser(
      uid: uid,
      email: doc['email'] ?? '',
      displayName: doc['displayName'],
      photoURL: doc['photoURL'],
      phoneNumber: doc['phoneNumber'],
      createdAt: DateTime.parse(doc['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(doc['updatedAt'] ?? DateTime.now().toIso8601String()),
      preferences: UserPreferences.fromMap(doc['preferences'] ?? {}),
      coupleBinding: doc['coupleBinding'] != null 
          ? CoupleBinding.fromMap(doc['coupleBinding'])
          : null,
      stats: UserStats.fromMap(doc['stats'] ?? {}),
    );
  }
  
  /// 📝 转换为 Firestore 文档格式
  /// 
  /// 返回适合存储到 Firestore 的 Map 格式数据
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences.toMap(),
      'coupleBinding': coupleBinding?.toMap(),
      'stats': stats.toMap(),
    };
  }
  
  /// 🔄 复制并更新用户信息
  /// 
  /// 创建一个新的 AppUser 实例，可以选择性更新某些字段
  AppUser copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? updatedAt,
    UserPreferences? preferences,
    CoupleBinding? coupleBinding,
    UserStats? stats,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      preferences: preferences ?? this.preferences,
      coupleBinding: coupleBinding ?? this.coupleBinding,
      stats: stats ?? this.stats,
    );
  }
  
  /// ✅ 判断是否已绑定情侣
  bool get isCoupleLinked => coupleBinding != null && coupleBinding!.partnerId.isNotEmpty;
  
  /// 🏆 获取用户等级
  int get userLevel => stats.level;
  
  /// 📈 获取用户经验值
  int get userExperience => stats.experience;
  
  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName)';
  }
}

/// 🏠 用户偏好设置
/// 
/// 包含用户的个人偏好和应用设置
@HiveType(typeId: 11)
class UserPreferences extends HiveObject {
  /// 是否启用深色模式
  @HiveField(0)
  final bool isDarkMode;
  
  /// 是否启用通知
  @HiveField(1)
  final bool enableNotifications;
  
  /// 是否启用烹饪提醒
  @HiveField(2)
  final bool enableCookingReminders;
  
  /// 默认菜谱难度偏好
  @HiveField(3)
  final String preferredDifficulty;
  
  /// 默认份量偏好
  @HiveField(4)
  final int preferredServings;
  
  /// 用户标签 (口味偏好等)
  @HiveField(5)
  final List<String> userTags;
  
  /// 构造函数
  /// 
  /// [isDarkMode] 是否启用深色模式
  /// [enableNotifications] 是否启用通知
  /// [enableCookingReminders] 是否启用烹饪提醒
  /// [preferredDifficulty] 默认菜谱难度偏好
  /// [preferredServings] 默认份量偏好
  /// [userTags] 用户标签
  UserPreferences({
    required this.isDarkMode,
    required this.enableNotifications,
    required this.enableCookingReminders,
    required this.preferredDifficulty,
    required this.preferredServings,
    required this.userTags,
  });
  
  /// 🏭 创建默认设置
  factory UserPreferences.defaultSettings() {
    return UserPreferences(
      isDarkMode: false,
      enableNotifications: true,
      enableCookingReminders: true,
      preferredDifficulty: '简单',
      preferredServings: 2,
      userTags: [],
    );
  }
  
  /// 🗺️ 从 Map 创建 UserPreferences
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      isDarkMode: map['isDarkMode'] ?? false,
      enableNotifications: map['enableNotifications'] ?? true,
      enableCookingReminders: map['enableCookingReminders'] ?? true,
      preferredDifficulty: map['preferredDifficulty'] ?? '简单',
      preferredServings: map['preferredServings'] ?? 2,
      userTags: List<String>.from(map['userTags'] ?? []),
    );
  }
  
  /// 📝 转换为 Map 格式
  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'enableNotifications': enableNotifications,
      'enableCookingReminders': enableCookingReminders,
      'preferredDifficulty': preferredDifficulty,
      'preferredServings': preferredServings,
      'userTags': userTags,
    };
  }
  
  /// 🔄 复制并更新偏好设置
  UserPreferences copyWith({
    bool? isDarkMode,
    bool? enableNotifications,
    bool? enableCookingReminders,
    String? preferredDifficulty,
    int? preferredServings,
    List<String>? userTags,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableCookingReminders: enableCookingReminders ?? this.enableCookingReminders,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      preferredServings: preferredServings ?? this.preferredServings,
      userTags: userTags ?? this.userTags,
    );
  }
}

/// 💑 情侣绑定信息
/// 
/// 记录情侣绑定的相关信息和状态
@HiveType(typeId: 12)
class CoupleBinding extends HiveObject {
  /// 伴侣用户 ID
  @HiveField(0)
  final String partnerId;
  
  /// 伴侣昵称
  @HiveField(1)
  final String partnerName;
  
  /// 绑定时间
  @HiveField(2)
  final DateTime bindingDate;
  
  /// 情侣组 ID (用于数据共享)
  @HiveField(3)
  final String coupleId;
  
  /// 亲密度等级
  @HiveField(4)
  final int intimacyLevel;
  
  /// 共同烹饪次数
  @HiveField(5)
  final int cookingTogether;
  
  /// 构造函数
  /// 
  /// [partnerId] 伴侣用户 ID
  /// [partnerName] 伴侣昵称
  /// [bindingDate] 绑定时间
  /// [coupleId] 情侣组 ID
  /// [intimacyLevel] 亲密度等级
  /// [cookingTogether] 共同烹饪次数
  CoupleBinding({
    required this.partnerId,
    required this.partnerName,
    required this.bindingDate,
    required this.coupleId,
    required this.intimacyLevel,
    required this.cookingTogether,
  });
  
  /// 🗺️ 从 Map 创建 CoupleBinding
  factory CoupleBinding.fromMap(Map<String, dynamic> map) {
    return CoupleBinding(
      partnerId: map['partnerId'] ?? '',
      partnerName: map['partnerName'] ?? '',
      bindingDate: DateTime.parse(map['bindingDate'] ?? DateTime.now().toIso8601String()),
      coupleId: map['coupleId'] ?? '',
      intimacyLevel: map['intimacyLevel'] ?? 1,
      cookingTogether: map['cookingTogether'] ?? 0,
    );
  }
  
  /// 📝 转换为 Map 格式
  Map<String, dynamic> toMap() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'bindingDate': bindingDate.toIso8601String(),
      'coupleId': coupleId,
      'intimacyLevel': intimacyLevel,
      'cookingTogether': cookingTogether,
    };
  }
  
  /// 🔄 复制并更新绑定信息
  CoupleBinding copyWith({
    String? partnerName,
    int? intimacyLevel,
    int? cookingTogether,
  }) {
    return CoupleBinding(
      partnerId: partnerId,
      partnerName: partnerName ?? this.partnerName,
      bindingDate: bindingDate,
      coupleId: coupleId,
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
      cookingTogether: cookingTogether ?? this.cookingTogether,
    );
  }
}

/// 📊 用户统计数据
/// 
/// 记录用户在应用中的使用统计和成长数据
@HiveType(typeId: 13)
class UserStats extends HiveObject {
  /// 用户等级
  @HiveField(0)
  final int level;
  
  /// 经验值
  @HiveField(1)
  final int experience;
  
  /// 创建的菜谱数量
  @HiveField(2)
  final int recipesCreated;
  
  /// 完成的烹饪次数
  @HiveField(3)
  final int cookingCompleted;
  
  /// 连续使用天数
  @HiveField(4)
  final int consecutiveDays;
  
  /// 最后活跃时间
  @HiveField(5)
  final DateTime lastActiveDate;
  
  /// 构造函数
  /// 
  /// [level] 用户等级
  /// [experience] 经验值
  /// [recipesCreated] 创建的菜谱数量
  /// [cookingCompleted] 完成的烹饪次数
  /// [consecutiveDays] 连续使用天数
  /// [lastActiveDate] 最后活跃时间
  UserStats({
    required this.level,
    required this.experience,
    required this.recipesCreated,
    required this.cookingCompleted,
    required this.consecutiveDays,
    required this.lastActiveDate,
  });
  
  /// 🏭 创建初始统计数据
  factory UserStats.initial() {
    return UserStats(
      level: 1,
      experience: 0,
      recipesCreated: 0,
      cookingCompleted: 0,
      consecutiveDays: 1,
      lastActiveDate: DateTime.now(),
    );
  }
  
  /// 🗺️ 从 Map 创建 UserStats
  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      recipesCreated: map['recipesCreated'] ?? 0,
      cookingCompleted: map['cookingCompleted'] ?? 0,
      consecutiveDays: map['consecutiveDays'] ?? 1,
      lastActiveDate: DateTime.parse(map['lastActiveDate'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// 📝 转换为 Map 格式
  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'experience': experience,
      'recipesCreated': recipesCreated,
      'cookingCompleted': cookingCompleted,
      'consecutiveDays': consecutiveDays,
      'lastActiveDate': lastActiveDate.toIso8601String(),
    };
  }
  
  /// 🔄 复制并更新统计数据
  UserStats copyWith({
    int? level,
    int? experience,
    int? recipesCreated,
    int? cookingCompleted,
    int? consecutiveDays,
    DateTime? lastActiveDate,
  }) {
    return UserStats(
      level: level ?? this.level,
      experience: experience ?? this.experience,
      recipesCreated: recipesCreated ?? this.recipesCreated,
      cookingCompleted: cookingCompleted ?? this.cookingCompleted,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
  
  /// 📈 计算升级所需经验值
  int get experienceToNextLevel {
    return (level * 100) - experience;
  }
  
  /// 🎯 获得经验值并检查是否升级
  UserStats gainExperience(int amount) {
    final newExperience = experience + amount;
    final newLevel = (newExperience / 100).floor() + 1;
    
    return copyWith(
      experience: newExperience,
      level: newLevel > level ? newLevel : level,
    );
  }
}