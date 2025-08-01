import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../favorites_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../features/recipe/domain/models/recipe.dart';

/// 🌟 收藏服务Provider
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

/// 📋 用户收藏列表Provider
final userFavoritesProvider = StreamProvider.family<UserFavorites, String>((ref, userId) {
  final service = ref.read(favoritesServiceProvider);
  
  // 返回Stream以便实时更新
  return Stream.periodic(const Duration(seconds: 30))
      .asyncMap((_) => service.getUserFavorites(userId))
      .handleError((error) {
        // 错误处理：返回空收藏列表
        return UserFavorites(
          userId: userId,
          favoriteRecipeIds: [],
          updatedAt: DateTime.now(),
        );
      });
});

/// ⭐ 当前用户收藏列表Provider
final currentUserFavoritesProvider = StreamProvider<UserFavorites>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    // 未登录用户返回空收藏
    return Stream.value(UserFavorites(
      userId: '',
      favoriteRecipeIds: [],
      updatedAt: DateTime.now(),
    ));
  }
  
  return ref.watch(userFavoritesProvider(user.uid).stream);
});

/// 🔍 检查菜谱收藏状态Provider
final recipeFavoriteStatusProvider = FutureProvider.family<bool, String>((ref, recipeId) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return false;
  
  final service = ref.read(favoritesServiceProvider);
  return await service.isFavorite(user.uid, recipeId);
});

/// 📊 热门收藏菜谱Provider
final popularFavoritesProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(favoritesServiceProvider);
  return await service.getPopularFavorites(limit: 20);
});

/// 🔄 收藏操作Provider（用于UI操作）
final favoriteActionsProvider = Provider<FavoriteActions>((ref) {
  final service = ref.read(favoritesServiceProvider);
  final user = ref.read(currentUserProvider);
  
  return FavoriteActions(
    service: service,
    userId: user?.uid ?? '',
  );
});

/// 🎯 收藏操作类
class FavoriteActions {
  final FavoritesService service;
  final String userId;
  
  FavoriteActions({
    required this.service,
    required this.userId,
  });
  
  /// ⭐ 添加收藏
  Future<bool> addFavorite(String recipeId) async {
    if (userId.isEmpty) return false;
    return await service.addFavorite(userId, recipeId);
  }
  
  /// 💔 移除收藏
  Future<bool> removeFavorite(String recipeId) async {
    if (userId.isEmpty) return false;
    return await service.removeFavorite(userId, recipeId);
  }
  
  /// 🔄 切换收藏状态
  Future<bool> toggleFavorite(String recipeId) async {
    if (userId.isEmpty) return false;
    return await service.toggleFavorite(userId, recipeId);
  }
  
  /// 🔍 检查收藏状态
  Future<bool> isFavorite(String recipeId) async {
    if (userId.isEmpty) return false;
    return await service.isFavorite(userId, recipeId);
  }
}

/// 📝 收藏状态管理Provider（用于UI状态管理）
class FavoriteStateNotifier extends StateNotifier<Map<String, bool>> {
  final FavoritesService _service;
  final String _userId;
  
  FavoriteStateNotifier(this._service, this._userId) : super({});
  
  /// 🔍 获取菜谱收藏状态
  Future<bool> getFavoriteStatus(String recipeId) async {
    // 如果缓存中有，直接返回
    if (state.containsKey(recipeId)) {
      return state[recipeId]!;
    }
    
    // 从服务获取状态
    final isFavorite = await _service.isFavorite(_userId, recipeId);
    
    // 更新缓存
    state = {...state, recipeId: isFavorite};
    
    return isFavorite;
  }
  
  /// ⭐ 添加收藏
  Future<bool> addFavorite(String recipeId) async {
    final success = await _service.addFavorite(_userId, recipeId);
    if (success) {
      state = {...state, recipeId: true};
    }
    return success;
  }
  
  /// 💔 移除收藏
  Future<bool> removeFavorite(String recipeId) async {
    final success = await _service.removeFavorite(_userId, recipeId);
    if (success) {
      state = {...state, recipeId: false};
    }
    return success;
  }
  
  /// 🔄 切换收藏状态
  Future<bool> toggleFavorite(String recipeId) async {
    final currentStatus = await getFavoriteStatus(recipeId);
    
    if (currentStatus) {
      return await removeFavorite(recipeId);
    } else {
      return await addFavorite(recipeId);
    }
  }
  
  /// 🧹 清理缓存
  void clearCache() {
    state = {};
  }
}

/// 📝 收藏状态管理Provider
final favoriteStateProvider = StateNotifierProvider<FavoriteStateNotifier, Map<String, bool>>((ref) {
  final service = ref.read(favoritesServiceProvider);
  final user = ref.read(currentUserProvider);
  
  return FavoriteStateNotifier(service, user?.uid ?? '');
});