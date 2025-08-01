import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/recipe/domain/models/recipe.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../auth/providers/auth_providers.dart';

/// 📥 JSON菜谱导入工具类
/// 
/// 功能：
/// - 从assets加载示例菜谱JSON
/// - 从文件选择器导入用户JSON
/// - 批量导入到云端Firestore
/// - 数据验证和转换
class JsonRecipeImporter {
  
  /// 📂 从assets加载示例菜谱
  static Future<List<Recipe>> loadSampleRecipes() async {
    try {
      debugPrint('📂 开始加载示例菜谱JSON...');
      
      // 从assets加载JSON文件
      final jsonString = await rootBundle.loadString('assets/data/sample_recipes.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      final recipesList = jsonData['recipes'] as List;
      final recipes = <Recipe>[];
      
      for (final recipeData in recipesList) {
        try {
          final recipe = _mapJsonToRecipe(recipeData as Map<String, dynamic>);
          recipes.add(recipe);
          debugPrint('✅ 解析菜谱: ${recipe.name}');
        } catch (e) {
          debugPrint('❌ 解析菜谱失败: $e');
        }
      }
      
      debugPrint('🎉 成功加载 ${recipes.length} 个示例菜谱');
      return recipes;
      
    } catch (e) {
      debugPrint('❌ 加载示例菜谱失败: $e');
      return [];
    }
  }
  
  /// 📤 批量导入菜谱到云端
  static Future<int> importRecipesToCloud(
    List<Recipe> recipes, 
    String userId, 
    RecipeRepository repository
  ) async {
    try {
      debugPrint('📤 开始批量导入 ${recipes.length} 个菜谱到云端...');
      
      int successCount = 0;
      
      for (final recipe in recipes) {
        try {
          // 重新设置创建者为当前用户
          final updatedRecipe = recipe.copyWith(
            id: '', // 清空ID，让Firestore自动生成
            createdBy: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            sourceType: 'preset', // 标记为预设菜谱
            isPreset: true,       // 预设菜谱标记
          );
          
          final recipeId = await repository.saveRecipe(updatedRecipe, userId);
          debugPrint('✅ 导入成功: ${recipe.name} -> $recipeId');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ 导入失败: ${recipe.name} - $e');
        }
      }
      
      debugPrint('🎉 批量导入完成: $successCount/${recipes.length}');
      return successCount;
      
    } catch (e) {
      debugPrint('❌ 批量导入异常: $e');
      return 0;
    }
  }

  /// 🔄 初始化root用户预设菜谱
  static Future<int> initializeRootPresetRecipes(
    String rootUserId,
    RecipeRepository repository
  ) async {
    try {
      debugPrint('🔄 开始初始化root用户预设菜谱...');
      
      // 1. 检查是否已经初始化过
      final existingRecipes = await repository.getUserRecipes(rootUserId);
      if (existingRecipes.isNotEmpty) {
        debugPrint('⚠️ Root用户已有菜谱，跳过初始化');
        return existingRecipes.length;
      }
      
      // 2. 加载示例菜谱
      final sampleRecipes = await loadSampleRecipes();
      if (sampleRecipes.isEmpty) {
        debugPrint('❌ 加载示例菜谱失败');
        return 0;
      }
      
      // 3. 批量保存为root用户的预设菜谱
      int successCount = 0;
      for (final recipe in sampleRecipes) {
        try {
          // 设置为root用户创建，并添加随机时间
          final randomDaysAgo = DateTime.now().subtract(
            Duration(days: 30 + (successCount * 15)) // 30-210天前分布
          );
          
          final rootRecipe = recipe.copyWith(
            id: '', // 清空ID，让Firestore自动生成
            createdBy: rootUserId,
            createdAt: randomDaysAgo,
            updatedAt: randomDaysAgo.add(Duration(days: 5)), // 几天后的更新时间
            sourceType: 'user', // root用户的正常菜谱
            isPreset: false,    // 不是预设标记，是root用户的"正常"菜谱
            rating: 4.5 + (0.4 * (successCount % 3)), // 4.5-4.9随机评分
            cookCount: 50 + (successCount * 10), // 50-170随机烹饪次数
          );
          
          final recipeId = await repository.saveRecipe(rootRecipe, rootUserId);
          debugPrint('✅ Root菜谱创建成功: ${recipe.name} -> $recipeId');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ Root菜谱创建失败: ${recipe.name} - $e');
        }
      }
      
      debugPrint('🎉 Root预设菜谱初始化完成: $successCount/${sampleRecipes.length}');
      return successCount;
      
    } catch (e) {
      debugPrint('❌ Root预设菜谱初始化异常: $e');
      return 0;
    }
  }

  /// 👤 新用户初始化：复制root用户的预设菜谱
  static Future<int> initializeNewUserWithPresets(
    String newUserId,
    String rootUserId,
    RecipeRepository repository
  ) async {
    try {
      debugPrint('👤 开始为新用户初始化预设菜谱: $newUserId');
      
      // 1. 检查新用户是否已有菜谱
      final existingRecipes = await repository.getUserRecipes(newUserId);
      if (existingRecipes.isNotEmpty) {
        debugPrint('⚠️ 用户已有菜谱，跳过初始化');
        return existingRecipes.length;
      }
      
      // 2. 获取root用户的所有菜谱
      final rootRecipes = await repository.getUserRecipes(rootUserId);
      if (rootRecipes.isEmpty) {
        debugPrint('❌ Root用户没有菜谱，先初始化root用户');
        await initializeRootPresetRecipes(rootUserId, repository);
        final retryRootRecipes = await repository.getUserRecipes(rootUserId);
        if (retryRootRecipes.isEmpty) {
          debugPrint('❌ Root用户初始化失败');
          return 0;
        }
      }
      
      // 3. 复制root菜谱到新用户账户
      final rootRecipesToCopy = await repository.getUserRecipes(rootUserId);
      int successCount = 0;
      
      for (final rootRecipe in rootRecipesToCopy) {
        try {
          // 为新用户创建菜谱副本，伪装成他们自己创建的
          final randomDaysAgo = DateTime.now().subtract(
            Duration(days: 5 + (successCount * 8)) // 5-95天前分布
          );
          
          final userRecipe = rootRecipe.copyWith(
            id: '', // 清空ID，让Firestore自动生成新的
            createdBy: newUserId, // 改为新用户
            createdAt: randomDaysAgo,
            updatedAt: randomDaysAgo.add(Duration(days: 2)), // 2天后更新
            sourceType: 'preset', // 标记为预设来源
            isPreset: true,       // 标记为预设菜谱
            originalRecipeId: rootRecipe.id, // 记录原始菜谱ID
            rating: 4.0 + (0.8 * (successCount % 4)), // 4.0-4.8随机评分
            cookCount: 1 + (successCount % 5), // 1-5次随机烹饪
          );
          
          final newRecipeId = await repository.saveRecipe(userRecipe, newUserId);
          debugPrint('✅ 预设菜谱复制成功: ${rootRecipe.name} -> $newRecipeId');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ 预设菜谱复制失败: ${rootRecipe.name} - $e');
        }
      }
      
      debugPrint('🎉 新用户预设菜谱初始化完成: $successCount/${rootRecipesToCopy.length}');
      return successCount;
      
    } catch (e) {
      debugPrint('❌ 新用户初始化异常: $e');
      return 0;
    }
  }
  
  /// 🔄 从文件导入JSON菜谱（Web端）
  static Future<List<Recipe>> importFromFile() async {
    try {
      if (!kIsWeb) {
        debugPrint('📱 移动端文件导入功能待实现');
        return [];
      }
      
      // TODO: 实现Web文件选择器导入
      debugPrint('🌐 Web端文件导入功能待实现');
      return [];
      
    } catch (e) {
      debugPrint('❌ 文件导入失败: $e');
      return [];
    }
  }
  
  /// 🔍 验证JSON数据格式
  static bool validateRecipeJson(Map<String, dynamic> json) {
    try {
      // 必须字段检查
      final requiredFields = ['name', 'description', 'steps'];
      for (final field in requiredFields) {
        if (!json.containsKey(field) || json[field] == null) {
          debugPrint('❌ 缺少必要字段: $field');
          return false;
        }
      }
      
      // steps必须是数组
      if (json['steps'] is! List) {
        debugPrint('❌ steps字段必须是数组');
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ JSON验证失败: $e');
      return false;
    }
  }
  
  // ==================== 私有方法 ====================
  
  /// 📋 JSON数据转换为Recipe对象
  static Recipe _mapJsonToRecipe(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconType: json['iconType'] as String? ?? 'AppIcon3DType.heart',
      totalTime: json['totalTime'] as int? ?? 30,
      difficulty: json['difficulty'] as String? ?? '简单',
      servings: json['servings'] as int? ?? 2,
      imageBase64: json['imageBase64'] as String?,
      steps: _parseSteps(json['steps'] as List? ?? []),
      createdBy: json['createdBy'] as String? ?? 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      cookCount: json['cookCount'] as int? ?? 0,
      // 新增字段的默认值
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      isShared: json['isShared'] as bool? ?? false,
      originalRecipeId: json['originalRecipeId'] as String?,
      sourceType: json['sourceType'] as String? ?? 'user',
      isPreset: json['isPreset'] as bool? ?? false,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
    );
  }
  
  /// 📝 解析步骤数据
  static List<RecipeStep> _parseSteps(List stepsList) {
    return stepsList.map((stepData) {
      final step = stepData as Map<String, dynamic>;
      return RecipeStep(
        title: step['title'] as String? ?? '',
        description: step['description'] as String? ?? '',
        duration: step['duration'] as int? ?? 0,
        tips: step['tips'] as String?,
        imageBase64: step['imageBase64'] as String?,
        ingredients: List<String>.from(step['ingredients'] as List? ?? []),
      );
    }).toList();
  }
}

/// 🌟 Recipe扩展方法
extension RecipeCopyWith on Recipe {
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? iconType,
    int? totalTime,
    String? difficulty,
    int? servings,
    String? imageBase64,
    List<RecipeStep>? steps,
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
      imageBase64: imageBase64 ?? this.imageBase64,
      steps: steps ?? this.steps,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      rating: rating ?? this.rating,
      cookCount: cookCount ?? this.cookCount,
    );
  }
}

/// 🚀 Riverpod Provider
final jsonRecipeImporterProvider = Provider<JsonRecipeImporter>((ref) {
  return JsonRecipeImporter();
});