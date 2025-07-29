import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/models/recipe.dart';

/// 菜谱数据仓库
class RecipeRepository {
  static const String _boxName = 'recipes';
  late Box<Recipe> _recipeBox;

  /// 初始化数据库
  Future<void> initialize() async {
    _recipeBox = await Hive.openBox<Recipe>(_boxName);
  }

  /// 保存菜谱
  Future<void> saveRecipe(Recipe recipe) async {
    await _recipeBox.put(recipe.id, recipe);
  }

  /// 获取菜谱by ID
  Recipe? getRecipe(String id) {
    return _recipeBox.get(id);
  }

  /// 获取所有菜谱
  List<Recipe> getAllRecipes() {
    return _recipeBox.values.toList();
  }

  /// 获取用户创建的菜谱
  List<Recipe> getUserRecipes(String userId) {
    return _recipeBox.values
        .where((recipe) => recipe.createdBy == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 按创建时间倒序
  }

  /// 删除菜谱
  Future<void> deleteRecipe(String id) async {
    final recipe = _recipeBox.get(id);
    if (recipe != null) {
      // 删除关联的图片文件
      if (recipe.imagePath != null) {
        await _deleteImageFile(recipe.imagePath!);
      }
      
      // 删除步骤图片
      for (final step in recipe.steps) {
        if (step.imagePath != null) {
          await _deleteImageFile(step.imagePath!);
        }
      }
      
      await _recipeBox.delete(id);
    }
  }

  /// 更新菜谱
  Future<void> updateRecipe(Recipe recipe) async {
    final updatedRecipe = recipe.copyWith(
      updatedAt: DateTime.now(),
    );
    await _recipeBox.put(recipe.id, updatedRecipe);
  }

  /// 增加制作次数
  Future<void> incrementCookCount(String recipeId) async {
    final recipe = getRecipe(recipeId);
    if (recipe != null) {
      final updatedRecipe = recipe.copyWith(
        cookCount: recipe.cookCount + 1,
        updatedAt: DateTime.now(),
      );
      await saveRecipe(updatedRecipe);
    }
  }

  /// 保存图片文件并返回路径
  Future<String> saveImageFile(File imageFile, String recipeId, {String? stepId}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'recipe_images'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = stepId != null 
        ? '${recipeId}_step_${stepId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : '${recipeId}_main_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final savedFile = File(path.join(imagesDir.path, fileName));
    await imageFile.copy(savedFile.path);
    
    return savedFile.path;
  }

  /// 删除图片文件
  Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('删除图片文件失败: $e');
    }
  }

  /// 搜索菜谱
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return getAllRecipes();
    
    return _recipeBox.values
        .where((recipe) => 
            recipe.name.toLowerCase().contains(query.toLowerCase()) ||
            recipe.description.toLowerCase().contains(query.toLowerCase()) ||
            recipe.steps.any((step) => 
                step.title.toLowerCase().contains(query.toLowerCase()) ||
                step.description.toLowerCase().contains(query.toLowerCase())
            )
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// 获取热门菜谱（按制作次数排序）
  List<Recipe> getPopularRecipes({int limit = 10}) {
    final recipes = getAllRecipes()
      ..sort((a, b) => b.cookCount.compareTo(a.cookCount));
    
    return recipes.take(limit).toList();
  }

  /// 获取最新菜谱
  List<Recipe> getLatestRecipes({int limit = 10}) {
    final recipes = getAllRecipes()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return recipes.take(limit).toList();
  }

  /// 关闭数据库
  Future<void> close() async {
    await _recipeBox.close();
  }
}

/// RecipeRepository的Provider - 🔧 修复：确保Repository被正确初始化
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final repository = RecipeRepository();
  return repository;
});

/// 异步初始化的Repository Provider
final initializedRecipeRepositoryProvider = FutureProvider<RecipeRepository>((ref) async {
  final repository = RecipeRepository();
  await repository.initialize();
  return repository;
});

/// 用于管理菜谱状态的Provider - 🔧 使用异步初始化的Repository
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = await ref.watch(initializedRecipeRepositoryProvider.future);
  return repository.getAllRecipes();
});

/// 用户菜谱Provider - 🔧 使用异步初始化的Repository
final userRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final repository = await ref.watch(initializedRecipeRepositoryProvider.future);
  return repository.getUserRecipes(userId);
});