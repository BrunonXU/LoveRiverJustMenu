/// 🚀 缓存菜谱服务 Providers
/// 
/// 提供缓存优先的菜谱数据访问
/// 大幅提升用户体验和应用性能
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/recipe/domain/models/recipe.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/models/app_user.dart';
import '../cached_recipe_service.dart';
import '../local_cache_service.dart';
import '../../firestore/repositories/recipe_repository.dart';
import 'cache_providers.dart';

/// 🚀 缓存菜谱服务 Provider
/// 
/// 提供完整的缓存优先菜谱数据访问服务
final cachedRecipeServiceProvider = FutureProvider<CachedRecipeService>((ref) async {
  final recipeRepository = RecipeRepository();
  final cacheService = await ref.watch(localCacheServiceProvider.future);
  
  return CachedRecipeService(
    recipeRepository: recipeRepository,
    cacheService: cacheService,
  );
});

/// 📚 用户菜谱 Provider（缓存优先）
/// 
/// 自动根据当前用户获取菜谱列表
/// 优先使用本地缓存，后台异步更新
final userRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final service = await ref.watch(cachedRecipeServiceProvider.future);
  return service.getUserRecipes(userId);
});

/// 💖 收藏菜谱 Provider（缓存优先）
/// 
/// 自动根据当前用户获取收藏菜谱列表
/// 优先使用本地缓存，后台异步更新
final favoriteRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final service = await ref.watch(cachedRecipeServiceProvider.future);
  return service.getFavoriteRecipes(userId);
});

/// 🌟 预设菜谱 Provider（缓存优先）
/// 
/// 获取系统预设菜谱列表
/// 优先使用本地缓存，后台异步更新
final presetRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final service = await ref.watch(cachedRecipeServiceProvider.future);
  return service.getPresetRecipes();
});

/// 📄 单个菜谱 Provider（缓存优先）
/// 
/// 根据菜谱ID获取单个菜谱详情
/// 优先使用本地缓存，后台异步更新
final recipeByIdProvider = FutureProvider.family<Recipe?, String>((ref, recipeId) async {
  final service = await ref.watch(cachedRecipeServiceProvider.future);
  return service.getRecipeById(recipeId);
});

/// 🏠 主页菜谱数据 Provider（缓存优先）
/// 
/// 为主页提供合并的菜谱数据（用户菜谱 + 预设菜谱）
/// 根据用户登录状态自动调整数据源
final homeRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user != null) {
        // 用户已登录，获取用户菜谱 + 预设菜谱
        final service = await ref.watch(cachedRecipeServiceProvider.future);
        
        final results = await Future.wait([
          service.getUserRecipes(user.uid),
          service.getPresetRecipes(),
        ]);
        
        final userRecipes = results[0];
        final presetRecipes = results[1];
        
        // 合并菜谱（预设菜谱在前，用户菜谱在后）
        return [...presetRecipes, ...userRecipes];
      } else {
        // 用户未登录，只显示预设菜谱
        final service = await ref.watch(cachedRecipeServiceProvider.future);
        return service.getPresetRecipes();
      }
    },
    loading: () => <Recipe>[],
    error: (error, stackTrace) => <Recipe>[],
  );
});

/// 🔄 刷新操作 Provider
/// 
/// 提供手动刷新缓存的功能
final refreshActionsProvider = FutureProvider<RefreshActions>((ref) async {
  final service = await ref.watch(cachedRecipeServiceProvider.future);
  final authState = ref.watch(authStateProvider);
  
  return RefreshActions(service, authState.value);
});

/// 🔄 刷新操作类
/// 
/// 封装各种刷新操作
class RefreshActions {
  final CachedRecipeService _service;
  final AppUser? _currentUser;
  
  const RefreshActions(this._service, this._currentUser);
  
  /// 刷新用户菜谱
  Future<void> refreshUserRecipes() async {
    if (_currentUser != null) {
      await _service.getUserRecipes(_currentUser!.uid, forceRefresh: true);
    }
  }
  
  /// 刷新收藏菜谱
  Future<void> refreshFavoriteRecipes() async {
    if (_currentUser != null) {
      await _service.getFavoriteRecipes(_currentUser!.uid, forceRefresh: true);
    }
  }
  
  /// 刷新预设菜谱
  Future<void> refreshPresetRecipes() async {
    await _service.getPresetRecipes(forceRefresh: true);
  }
  
  /// 刷新所有数据
  Future<void> refreshAll() async {
    if (_currentUser != null) {
      await _service.forceRefreshAll(_currentUser!.uid);
    } else {
      await refreshPresetRecipes();
    }
  }
  
  /// 清除用户缓存（用于登出）
  Future<void> clearUserCache() async {
    if (_currentUser != null) {
      await _service.clearUserCache(_currentUser!.uid);
    }
  }
}