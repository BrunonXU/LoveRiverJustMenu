/// 🧹 清理孤立收藏记录脚本
/// 
/// 目的：删除用户收藏中已不存在的菜谱ID
/// 场景：当菜谱被删除后，收藏记录没有同步清理

import 'package:flutter/foundation.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../services/favorites_service.dart';

class CleanOrphanedFavoritesScript {
  
  /// 🧹 清理用户的孤立收藏记录
  static Future<Map<String, dynamic>> cleanUserOrphanedFavorites(
    String userId,
    RecipeRepository recipeRepository,
    FavoritesService favoritesService,
  ) async {
    try {
      debugPrint('🧹 开始清理用户孤立收藏记录: $userId');
      
      // 1. 获取用户所有收藏
      final userFavorites = await favoritesService.getUserFavorites(userId);
      final favoriteRecipeIds = userFavorites.favoriteRecipeIds;
      
      debugPrint('📋 用户收藏菜谱数量: ${favoriteRecipeIds.length}');
      
      if (favoriteRecipeIds.isEmpty) {
        return {
          'user_id': userId,
          'total_favorites': 0,
          'orphaned_count': 0,
          'cleaned_count': 0,
          'remaining_count': 0,
          'status': 'no_favorites',
        };
      }
      
      // 2. 检查每个收藏的菜谱是否仍然存在
      final validRecipeIds = <String>[];
      final orphanedRecipeIds = <String>[];
      
      for (final recipeId in favoriteRecipeIds) {
        try {
          final recipe = await recipeRepository.getRecipe(recipeId);
          if (recipe != null) {
            validRecipeIds.add(recipeId);
            debugPrint('✅ 有效收藏: ${recipe.name} ($recipeId)');
          } else {
            orphanedRecipeIds.add(recipeId);
            debugPrint('❌ 孤立收藏: $recipeId (菜谱不存在)');
          }
        } catch (e) {
          // 如果获取菜谱出错，也认为是孤立记录
          orphanedRecipeIds.add(recipeId);
          debugPrint('❌ 孤立收藏: $recipeId (获取失败: $e)');
        }
      }
      
      // 3. 删除孤立的收藏记录
      int cleanedCount = 0;
      for (final orphanedId in orphanedRecipeIds) {
        try {
          final success = await favoritesService.removeFavorite(userId, orphanedId);
          if (success) {
            cleanedCount++;
            debugPrint('🗑️ 已删除孤立收藏: $orphanedId');
          }
        } catch (e) {
          debugPrint('❌ 删除孤立收藏失败: $orphanedId - $e');
        }
      }
      
      final result = {
        'user_id': userId,
        'total_favorites': favoriteRecipeIds.length,
        'orphaned_count': orphanedRecipeIds.length,
        'cleaned_count': cleanedCount,
        'remaining_count': validRecipeIds.length,
        'status': cleanedCount == orphanedRecipeIds.length ? 'success' : 'partial_success',
      };
      
      debugPrint('🎉 用户收藏清理完成:');
      debugPrint('  总收藏数: ${result['total_favorites']}');
      debugPrint('  孤立记录: ${result['orphaned_count']}');
      debugPrint('  清理成功: ${result['cleaned_count']}');
      debugPrint('  剩余收藏: ${result['remaining_count']}');
      
      return result;
      
    } catch (e) {
      debugPrint('❌ 清理用户孤立收藏失败: $e');
      return {
        'user_id': userId,
        'error': e.toString(),
        'status': 'failed',
      };
    }
  }
  
  /// 🔍 分析用户收藏中的孤立记录（不执行删除）
  static Future<Map<String, dynamic>> analyzeUserOrphanedFavorites(
    String userId,
    RecipeRepository recipeRepository,
    FavoritesService favoritesService,
  ) async {
    try {
      debugPrint('🔍 开始分析用户孤立收藏记录: $userId');
      
      final userFavorites = await favoritesService.getUserFavorites(userId);
      final favoriteRecipeIds = userFavorites.favoriteRecipeIds;
      
      if (favoriteRecipeIds.isEmpty) {
        return {
          'user_id': userId,
          'total_favorites': 0,
          'valid_favorites': 0,
          'orphaned_favorites': 0,
          'orphaned_details': <Map<String, String>>[],
        };
      }
      
      final validRecipeIds = <String>[];
      final orphanedDetails = <Map<String, String>>[];
      
      for (final recipeId in favoriteRecipeIds) {
        try {
          final recipe = await recipeRepository.getRecipe(recipeId);
          if (recipe != null) {
            validRecipeIds.add(recipeId);
          } else {
            orphanedDetails.add({
              'recipe_id': recipeId,
              'reason': '菜谱不存在',
            });
          }
        } catch (e) {
          orphanedDetails.add({
            'recipe_id': recipeId,
            'reason': '获取失败: $e',
          });
        }
      }
      
      final analysis = {
        'user_id': userId,
        'total_favorites': favoriteRecipeIds.length,
        'valid_favorites': validRecipeIds.length,
        'orphaned_favorites': orphanedDetails.length,
        'orphaned_details': orphanedDetails,
      };
      
      debugPrint('📊 用户收藏分析结果:');
      debugPrint('  总收藏数: ${analysis['total_favorites']}');
      debugPrint('  有效收藏: ${analysis['valid_favorites']}');
      debugPrint('  孤立收藏: ${analysis['orphaned_favorites']}');
      
      return analysis;
      
    } catch (e) {
      debugPrint('❌ 分析用户孤立收藏失败: $e');
      return {
        'user_id': userId,
        'error': e.toString(),
      };
    }
  }
}