import 'package:hive/hive.dart';

part 'recipe.g.dart';

/// 菜谱数据模型
@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconType; // AppIcon3DType转为String存储

  @HiveField(4)
  int totalTime; // 总耗时（分钟）

  @HiveField(5)
  String difficulty; // 难度：简单/中等/困难

  @HiveField(6)
  int servings; // 几人份

  @HiveField(7)
  List<RecipeStep> steps;

  @HiveField(8)
  String? imagePath; // 🔧 新增：菜谱主图路径（已废弃）

  @HiveField(15)
  String? imageBase64; // 📷 Base64图片数据 - 确保部署后不丢失（已废弃，保留兼容性）

  @HiveField(16)
  String? imageUrl; // 🔗 新增：Firebase Storage图片URL（推荐使用）

  @HiveField(9)
  String createdBy; // 🔧 新增：创建者ID

  @HiveField(10)
  DateTime createdAt; // 🔧 新增：创建时间

  @HiveField(11)
  DateTime updatedAt; // 🔧 新增：更新时间

  @HiveField(12)
  bool isPublic; // 🔧 新增：是否公开

  @HiveField(13)
  double rating; // 🔧 新增：评分（0-5）

  @HiveField(14)
  int cookCount; // 🔧 新增：被制作次数

  @HiveField(17)
  List<String> sharedWith; // 🔧 新增：共享给谁（用户ID列表）

  @HiveField(18)
  bool isShared; // 🔧 新增：是否为别人共享给我的

  @HiveField(19)
  String? originalRecipeId; // 🔧 新增：如果是共享的，原菜谱ID

  @HiveField(20)
  String sourceType; // 🔧 新增：来源类型（user|preset|shared）

  @HiveField(21)
  bool isPreset; // 🔧 新增：是否为预设菜谱

  @HiveField(22)
  int favoriteCount; // 🔧 新增：收藏数量

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.iconType,
    required this.totalTime,
    required this.difficulty,
    required this.servings,
    required this.steps,
    this.imagePath,
    this.imageBase64, // 📷 Base64图片数据（已废弃）
    this.imageUrl, // 🔗 Firebase Storage图片URL
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
    this.rating = 0.0,
    this.cookCount = 0,
    this.sharedWith = const [],
    this.isShared = false,
    this.originalRecipeId,
    this.sourceType = 'user',
    this.isPreset = false,
    this.favoriteCount = 0,
  });

  /// 从JSON创建Recipe对象
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconType: json['iconType'],
      totalTime: json['totalTime'],
      difficulty: json['difficulty'],
      servings: json['servings'],
      steps: (json['steps'] as List)
          .map((step) => RecipeStep.fromJson(step))
          .toList(),
      imagePath: json['imagePath'],
      imageBase64: json['imageBase64'], // 📷 Base64图片数据（已废弃）
      imageUrl: json['imageUrl'], // 🔗 Firebase Storage图片URL
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPublic: json['isPublic'] ?? true,
      rating: json['rating']?.toDouble() ?? 0.0,
      cookCount: json['cookCount'] ?? 0,
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      isShared: json['isShared'] ?? false,
      originalRecipeId: json['originalRecipeId'],
      sourceType: json['sourceType'] ?? 'user',
      isPreset: json['isPreset'] ?? false,
      favoriteCount: json['favoriteCount'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconType': iconType,
      'totalTime': totalTime,
      'difficulty': difficulty,
      'servings': servings,
      'steps': steps.map((step) => step.toJson()).toList(),
      'imagePath': imagePath,
      'imageBase64': imageBase64, // 📷 Base64图片数据（已废弃）
      'imageUrl': imageUrl, // 🔗 Firebase Storage图片URL
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
      'rating': rating,
      'cookCount': cookCount,
      'sharedWith': sharedWith,
      'isShared': isShared,
      'originalRecipeId': originalRecipeId,
      'sourceType': sourceType,
      'isPreset': isPreset,
      'favoriteCount': favoriteCount,
    };
  }

  /// 创建副本（用于编辑）
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? iconType,
    int? totalTime,
    String? difficulty,
    int? servings,
    List<RecipeStep>? steps,
    String? imagePath,
    String? imageBase64, // 📷 Base64图片数据（已废弃）
    String? imageUrl, // 🔗 Firebase Storage图片URL
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    double? rating,
    int? cookCount,
    List<String>? sharedWith,
    bool? isShared,
    String? originalRecipeId,
    String? sourceType,
    bool? isPreset,
    int? favoriteCount,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconType: iconType ?? this.iconType,
      totalTime: totalTime ?? this.totalTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      steps: steps ?? this.steps,
      imagePath: imagePath ?? this.imagePath,
      imageBase64: imageBase64 ?? this.imageBase64, // 📷 Base64图片数据（已废弃）
      imageUrl: imageUrl ?? this.imageUrl, // 🔗 Firebase Storage图片URL
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      rating: rating ?? this.rating,
      cookCount: cookCount ?? this.cookCount,
      sharedWith: sharedWith ?? this.sharedWith,
      isShared: isShared ?? this.isShared,
      originalRecipeId: originalRecipeId ?? this.originalRecipeId,
      sourceType: sourceType ?? this.sourceType,
      isPreset: isPreset ?? this.isPreset,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}

/// 菜谱步骤模型
@HiveType(typeId: 1)
class RecipeStep extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int duration; // 预计时长（分钟）

  @HiveField(3)
  String? tips; // 小贴士

  @HiveField(4)
  String? imagePath; // 🔧 新增：步骤图片路径（已废弃）

  @HiveField(6)
  String? imageBase64; // 📷 Base64图片数据 - 确保部署后不丢失

  @HiveField(5)
  List<String> ingredients; // 🔧 新增：此步骤需要的食材

  RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
    this.tips,
    this.imagePath,
    this.imageBase64, // 📷 Base64图片数据
    this.ingredients = const [],
  });

  /// 从JSON创建RecipeStep对象
  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      tips: json['tips'],
      imagePath: json['imagePath'],
      imageBase64: json['imageBase64'], // 📷 Base64图片数据
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'tips': tips,
      'imagePath': imagePath,
      'imageBase64': imageBase64, // 📷 Base64图片数据
      'ingredients': ingredients,
    };
  }

  /// 创建副本
  RecipeStep copyWith({
    String? title,
    String? description,
    int? duration,
    String? tips,
    String? imagePath,
    String? imageBase64, // 📷 Base64图片数据
    List<String>? ingredients,
  }) {
    return RecipeStep(
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      tips: tips ?? this.tips,
      imagePath: imagePath ?? this.imagePath,
      imageBase64: imageBase64 ?? this.imageBase64, // 📷 Base64图片数据
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

/// 用户收藏数据模型
@HiveType(typeId: 2)
class UserFavorites extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  List<String> favoriteRecipeIds; // 收藏的菜谱ID列表

  @HiveField(2)
  DateTime updatedAt; // 更新时间

  UserFavorites({
    required this.userId,
    this.favoriteRecipeIds = const [],
    required this.updatedAt,
  });

  /// 从JSON创建UserFavorites对象
  factory UserFavorites.fromJson(Map<String, dynamic> json) {
    return UserFavorites(
      userId: json['userId'],
      favoriteRecipeIds: List<String>.from(json['favoriteRecipeIds'] ?? []),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteRecipeIds': favoriteRecipeIds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 添加收藏
  void addFavorite(String recipeId) {
    if (!favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds = [...favoriteRecipeIds, recipeId];
      updatedAt = DateTime.now();
    }
  }

  /// 移除收藏
  void removeFavorite(String recipeId) {
    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds = favoriteRecipeIds.where((id) => id != recipeId).toList();
      updatedAt = DateTime.now();
    }
  }

  /// 检查是否收藏
  bool isFavorite(String recipeId) {
    return favoriteRecipeIds.contains(recipeId);
  }
}