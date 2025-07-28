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
  String? imagePath; // 🔧 新增：菜谱主图路径

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
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = true,
    this.rating = 0.0,
    this.cookCount = 0,
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
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPublic: json['isPublic'] ?? true,
      rating: json['rating']?.toDouble() ?? 0.0,
      cookCount: json['cookCount'] ?? 0,
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
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
      'rating': rating,
      'cookCount': cookCount,
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
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    double? rating,
    int? cookCount,
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
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      rating: rating ?? this.rating,
      cookCount: cookCount ?? this.cookCount,
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
  String? imagePath; // 🔧 新增：步骤图片路径

  @HiveField(5)
  List<String> ingredients; // 🔧 新增：此步骤需要的食材

  RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
    this.tips,
    this.imagePath,
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
    List<String>? ingredients,
  }) {
    return RecipeStep(
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      tips: tips ?? this.tips,
      imagePath: imagePath ?? this.imagePath,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}