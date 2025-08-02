/// 简化的菜谱模型 - 专为烹饪模式使用
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeStep> steps;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final double rating;
  final int cookCount;
  final List<String> sharedWith;
  final bool isShared;
  final String? originalRecipeId;
  final String sourceType;
  final bool isPreset;
  final int favoriteCount;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.imageUrl,
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
      steps: (json['steps'] as List)
          .map((step) => RecipeStep.fromJson(step))
          .toList(),
      imageUrl: json['imageUrl'],
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
}

/// 简化的菜谱步骤模型
class RecipeStep {
  final String title;
  final String description;
  final int duration; // 预计时长（分钟）
  final String? tips;
  final String? imagePath;
  final String? imageBase64;
  final List<String> ingredients;

  RecipeStep({
    required this.title,
    required this.description,
    required this.duration,
    this.tips,
    this.imagePath,
    this.imageBase64,
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
      imageBase64: json['imageBase64'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }
}