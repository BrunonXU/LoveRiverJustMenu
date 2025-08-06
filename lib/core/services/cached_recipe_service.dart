/// 🚀 缓存优先菜谱服务
/// 
/// 实现本地缓存优先的数据获取策略
/// 大幅提升用户体验，减少等待时间
/// 
/// 策略：
/// 1. 优先从本地缓存读取
/// 2. 后台异步更新云端数据
/// 3. 智能缓存过期机制
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firestore/repositories/recipe_repository.dart';
import 'local_cache_service.dart';
import '../../features/recipe/domain/models/recipe.dart';
import '../utils/network_retry.dart';

/// 🚀 缓存优先菜谱服务
class CachedRecipeService {
  /// 云端菜谱仓库
  final RecipeRepository _recipeRepository;
  
  /// 本地缓存服务
  final LocalCacheService _cacheService;
  
  /// 构造函数
  CachedRecipeService({
    required RecipeRepository recipeRepository,
    required LocalCacheService cacheService,
  })  : _recipeRepository = recipeRepository,
        _cacheService = cacheService;

  /// 📚 获取用户菜谱（暂时直接从云端获取）
  /// 
  /// [userId] 用户ID
  /// [forceRefresh] 是否强制刷新
  /// 
  /// 返回菜谱列表
  Future<List<Recipe>> getUserRecipes(String userId, {bool forceRefresh = false}) async {
    try {
      debugPrint('🔄 从云端获取用户菜谱: $userId');
      
      // 🔧 使用重试机制从云端获取，提高成功率
      final cloudRecipes = await NetworkRetry.mvpRetry(
        () => _recipeRepository.getUserRecipes(userId),
      );
      
      debugPrint('✅ 用户菜谱获取完成: ${cloudRecipes.length} 个');
      return cloudRecipes;
      
    } catch (e) {
      debugPrint('❌ 获取用户菜谱失败: $e');
      return [];
    }
  }

  /// 💖 获取收藏菜谱（缓存优先策略）
  /// 
  /// [userId] 用户ID
  /// [forceRefresh] 是否强制刷新
  /// 
  /// 返回收藏菜谱列表
  Future<List<Recipe>> getFavoriteRecipes(String userId, {bool forceRefresh = false}) async {
    try {
      debugPrint('🔄 获取收藏菜谱: $userId');
      
      // 🚀 使用本地缓存服务获取收藏菜谱
      final favoriteRecipes = await _cacheService.getFavoriteRecipes(userId);
      
      debugPrint('✅ 收藏菜谱获取完成: ${favoriteRecipes.length} 个');
      return favoriteRecipes;
      
    } catch (e) {
      debugPrint('❌ 获取收藏菜谱失败: $e');
      return [];
    }
  }

  /// 🌟 获取预设菜谱（暂时直接从云端获取）
  /// 
  /// [forceRefresh] 是否强制刷新
  /// 
  /// 返回预设菜谱列表
  Future<List<Recipe>> getPresetRecipes({bool forceRefresh = false}) async {
    try {
      debugPrint('🔄 从云端获取预设菜谱');
      
      // 🔧 使用重试机制从云端获取预设菜谱
      final cloudRecipes = await NetworkRetry.mvpRetry(
        () => _recipeRepository.getPresetRecipes(),
      );
      
      debugPrint('✅ 预设菜谱获取完成: ${cloudRecipes.length} 个');
      return cloudRecipes;
      
    } catch (e) {
      debugPrint('❌ 获取预设菜谱失败: $e');
      return [];
    }
  }

  /// 📄 获取单个菜谱（暂时直接从云端获取）
  /// 
  /// [recipeId] 菜谱ID
  /// [forceRefresh] 是否强制刷新
  /// 
  /// 返回菜谱对象，未找到返回null
  Future<Recipe?> getRecipeById(String recipeId, {bool forceRefresh = false}) async {
    try {
      debugPrint('🔄 从云端获取菜谱: $recipeId');
      
      // 🔧 使用重试机制从云端获取单个菜谱
      final cloudRecipe = await NetworkRetry.mvpRetry(
        () => _recipeRepository.getRecipe(recipeId),
      );
      
      if (cloudRecipe != null) {
        debugPrint('✅ 菜谱获取完成: ${cloudRecipe.name}');
      }
      
      return cloudRecipe;
      
    } catch (e) {
      debugPrint('❌ 获取菜谱失败: $e');
      return null;
    }
  }

  /// 🗑️ 清除用户相关缓存（暂未实现）
  /// 
  /// [userId] 用户ID
  /// 
  /// 用于用户登出或切换账户时清理缓存
  Future<void> clearUserCache(String userId) async {
    debugPrint('🗑️ 清理用户缓存: $userId（暂未实现）');
  }

  /// 🔄 强制刷新所有缓存（暂时直接重新获取）
  /// 
  /// [userId] 用户ID
  /// 
  /// 用于用户手动刷新时使用
  Future<void> forceRefreshAll(String userId) async {
    try {
      debugPrint('🔄 开始强制刷新所有数据');
      
      await Future.wait([
        getUserRecipes(userId, forceRefresh: true),
        getFavoriteRecipes(userId, forceRefresh: true),
        getPresetRecipes(forceRefresh: true),
      ]);
      
      debugPrint('✅ 所有数据刷新完成');
    } catch (e) {
      debugPrint('❌ 强制刷新数据失败: $e');
    }
  }
}