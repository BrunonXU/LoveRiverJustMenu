import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_cache_service.dart';
import '../../firestore/repositories/recipe_repository.dart';

/// 🏪 缓存服务提供者 - 管理本地缓存服务的生命周期
/// 
/// 提供者层级：
/// 1. cloudRecipeRepositoryProvider - 云端仓库
/// 2. localCacheServiceProvider - 本地缓存服务
/// 3. hybrideDataServiceProvider - 混合数据服务（未来扩展）

/// ☁️ 云端菜谱仓库提供者
final cloudRecipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  throw UnimplementedError('请在 main.dart 中配置 cloudRecipeRepositoryProvider');
});

/// 📦 本地缓存服务提供者
final localCacheServiceProvider = FutureProvider<LocalCacheService>((ref) async {
  final cloudRepository = ref.read(cloudRecipeRepositoryProvider);
  final cacheService = LocalCacheService(cloudRepository);
  
  // 初始化缓存服务
  await cacheService.initialize();
  
  return cacheService;
});

/// 📊 缓存统计信息提供者
final cacheStatsProvider = Provider<Map<String, int>>((ref) {
  final cacheServiceAsync = ref.watch(localCacheServiceProvider);
  
  return cacheServiceAsync.when(
    data: (cacheService) => cacheService.getCacheStats(),
    loading: () => {'loading': 1},
    error: (error, stack) => {'error': 1},
  );
});

/// 🔄 缓存同步状态提供者
final cacheSyncStatusProvider = StateNotifierProvider<CacheSyncStatusNotifier, CacheSyncStatus>((ref) {
  return CacheSyncStatusNotifier();
});

/// 🔄 缓存同步状态管理器
class CacheSyncStatusNotifier extends StateNotifier<CacheSyncStatus> {
  CacheSyncStatusNotifier() : super(const CacheSyncStatus());
  
  /// 开始同步
  void startSync(String operation) {
    state = state.copyWith(
      isSyncing: true,
      currentOperation: operation,
      lastSyncTime: DateTime.now(),
    );
  }
  
  /// 同步完成
  void completSync() {
    state = state.copyWith(
      isSyncing: false,
      currentOperation: null,
      lastSyncTime: DateTime.now(),
    );
  }
  
  /// 同步失败
  void failSync(String error) {
    state = state.copyWith(
      isSyncing: false,
      currentOperation: null,
      lastError: error,
      lastSyncTime: DateTime.now(),
    );
  }
  
  /// 清除错误
  void clearError() {
    state = state.copyWith(lastError: null);
  }
}

/// 🔄 缓存同步状态数据类
class CacheSyncStatus {
  final bool isSyncing;
  final String? currentOperation;
  final String? lastError;
  final DateTime? lastSyncTime;
  
  const CacheSyncStatus({
    this.isSyncing = false,
    this.currentOperation,
    this.lastError,
    this.lastSyncTime,
  });
  
  CacheSyncStatus copyWith({
    bool? isSyncing,
    String? currentOperation,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return CacheSyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      currentOperation: currentOperation ?? this.currentOperation,
      lastError: lastError ?? this.lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// 📱 用户菜谱缓存提供者 - 实现本地优先策略
final userRecipesCacheProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final cacheService = await ref.read(localCacheServiceProvider.future);
  return await cacheService.getUserRecipes(userId);
});

/// ⭐ 收藏菜谱缓存提供者
final favoriteRecipesCacheProvider = FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final cacheService = await ref.read(localCacheServiceProvider.future);
  return await cacheService.getFavoriteRecipes(userId);
});

/// 📚 预设菜谱缓存提供者
final presetRecipesCacheProvider = FutureProvider<List<Recipe>>((ref) async {
  final cacheService = await ref.read(localCacheServiceProvider.future);
  return await cacheService.getPresetRecipes();
});

// 导入 Recipe 类型
import '../../../features/recipe/domain/models/recipe.dart';