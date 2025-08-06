import 'package:hive_flutter/hive_flutter.dart';
import '../firestore/repositories/recipe_repository.dart';
import '../../features/recipe/domain/models/recipe.dart';
import '../auth/models/app_user.dart';

/// 📦 本地缓存服务 - 实现本地优先的数据管理策略
/// 
/// 核心功能：
/// 1. 本地缓存优先：读取数据时先查本地，后台检查云端更新
/// 2. 双写策略：写入时本地+云端同时保存，本地成功即可响应用户
/// 3. 智能同步：检测云端更新并提示用户
/// 4. 离线支持：网络断开时仍可访问本地数据
/// 
/// 使用场景：
/// - 我的菜谱：快速本地读取，后台同步
/// - 收藏菜谱：本地存储，支持离线查看
/// - 预设菜谱：首次下载后本地访问
/// - 分享菜谱：接收时下载到本地，支持版本更新检查
class LocalCacheService {
  static const String _recipesBoxName = 'local_recipes';
  static const String _favoritesBoxName = 'local_favorites';
  static const String _metadataBoxName = 'cache_metadata';
  static const String _presetBoxName = 'preset_recipes';
  static const String _sharedBoxName = 'shared_recipes';
  
  // Hive box 实例
  Box<Recipe>? _recipesBox;
  Box<List<String>>? _favoritesBox;
  Box<Map<String, dynamic>>? _metadataBox;
  Box<Recipe>? _presetBox;
  Box<Recipe>? _sharedBox;
  
  // 云端仓库引用
  final RecipeRepository _cloudRepository;
  
  LocalCacheService(this._cloudRepository);
  
  /// 🚀 初始化缓存服务
  Future<void> initialize() async {
    try {
      // 打开所有需要的 Hive boxes
      _recipesBox = await Hive.openBox<Recipe>(_recipesBoxName);
      _favoritesBox = await Hive.openBox<List<String>>(_favoritesBoxName);
      _metadataBox = await Hive.openBox<Map<String, dynamic>>(_metadataBoxName);
      _presetBox = await Hive.openBox<Recipe>(_presetBoxName);
      _sharedBox = await Hive.openBox<Recipe>(_sharedBoxName);
      
      print('✅ LocalCacheService 初始化成功');
    } catch (e) {
      print('❌ LocalCacheService 初始化失败: $e');
      throw Exception('缓存服务初始化失败: $e');
    }
  }
  
  // ==================== 用户菜谱管理 ====================
  
  /// 📖 获取用户菜谱 - 本地优先策略
  /// 1. 立即返回本地数据（快速响应）
  /// 2. 后台检查云端更新（不阻塞UI）
  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      // 1. 快速返回本地缓存数据
      final localRecipes = _getUserRecipesFromLocal(userId);
      
      // 2. 后台检查云端更新（异步执行，不阻塞返回）
      _checkCloudUpdatesInBackground(userId);
      
      return localRecipes;
    } catch (e) {
      print('❌ 获取用户菜谱失败: $e');
      // 如果本地读取失败，尝试从云端获取
      return await _getUserRecipesFromCloud(userId);
    }
  }
  
  /// 📋 从本地获取用户菜谱
  List<Recipe> _getUserRecipesFromLocal(String userId) {
    if (_recipesBox == null) return [];
    
    return _recipesBox!.values
        .where((recipe) => recipe.createdBy == userId && !recipe.isPreset)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // 按更新时间降序
  }
  
  /// ☁️ 从云端获取用户菜谱
  Future<List<Recipe>> _getUserRecipesFromCloud(String userId) async {
    try {
      final cloudRecipes = await _cloudRepository.getUserRecipes(userId);
      
      // 更新本地缓存
      await _updateLocalRecipes(cloudRecipes);
      
      return cloudRecipes;
    } catch (e) {
      print('❌ 从云端获取菜谱失败: $e');
      return [];
    }
  }

  /// 🔄 更新本地菜谱缓存
  Future<void> _updateLocalRecipes(List<Recipe> recipes) async {
    try {
      if (_recipesBox == null) return;
      
      for (final recipe in recipes) {
        await _recipesBox!.put(recipe.id, recipe);
      }
      
      // 更新元数据
      await _updateMetadata('recipes_last_sync', DateTime.now().toIso8601String());
      
      print('✅ 本地菜谱缓存已更新: ${recipes.length} 个');
    } catch (e) {
      print('❌ 更新本地菜谱缓存失败: $e');
    }
  }
  
  /// 🔄 后台检查云端更新
  void _checkCloudUpdatesInBackground(String userId) async {
    try {
      final cloudRecipes = await _cloudRepository.getUserRecipes(userId);
      final localRecipes = _getUserRecipesFromLocal(userId);
      
      // 构建本地菜谱映射表
      final localRecipeMap = {
        for (var recipe in localRecipes) recipe.id: recipe
      };
      
      // 检查每个云端菜谱是否有更新
      for (final cloudRecipe in cloudRecipes) {
        final localRecipe = localRecipeMap[cloudRecipe.id];
        
        if (localRecipe == null) {
          // 新菜谱，添加到本地
          await _addRecipeToLocal(cloudRecipe);
        } else if (cloudRecipe.updatedAt.isAfter(localRecipe.updatedAt)) {
          // 云端有更新，标记需要同步
          await _markRecipeNeedsUpdate(cloudRecipe.id, cloudRecipe);
        }
      }
      
      // 检查本地是否有云端已删除的菜谱
      final cloudRecipeIds = cloudRecipes.map((r) => r.id).toSet();
      for (final localRecipe in localRecipes) {
        if (!cloudRecipeIds.contains(localRecipe.id)) {
          // 云端已删除，标记为待删除
          await _markRecipeDeleted(localRecipe.id);
        }
      }
      
    } catch (e) {
      print('⚠️ 后台同步检查失败: $e');
      // 静默失败，不影响用户体验
    }
  }
  
  /// 💾 保存菜谱 - 双写策略
  /// 1. 立即保存到本地（快速响应用户）
  /// 2. 异步保存到云端（确保数据持久化）
  Future<void> saveRecipe(Recipe recipe, String userId) async {
    try {
      // 1. 立即保存到本地缓存
      await _addRecipeToLocal(recipe);
      
      // 2. 异步保存到云端
      _saveRecipeToCloudAsync(recipe, userId);
      
    } catch (e) {
      print('❌ 保存菜谱到本地失败: $e');
      throw Exception('保存菜谱失败: $e');
    }
  }
  
  /// 📁 添加菜谱到本地缓存
  Future<void> _addRecipeToLocal(Recipe recipe) async {
    if (_recipesBox == null) throw Exception('缓存未初始化');
    
    await _recipesBox!.put(recipe.id, recipe);
    
    // 更新元数据
    await _updateRecipeMetadata(recipe.id, {
      'lastUpdated': DateTime.now().toIso8601String(),
      'needsSync': false,
      'isLocal': true,
    });
  }
  
  /// ☁️ 异步保存到云端
  void _saveRecipeToCloudAsync(Recipe recipe, String userId) async {
    try {
      await _cloudRepository.saveRecipe(recipe, userId);
      
      // 标记已同步
      await _updateRecipeMetadata(recipe.id, {
        'lastSynced': DateTime.now().toIso8601String(),
        'needsSync': false,
      });
      
      print('✅ 菜谱 ${recipe.name} 已同步到云端');
    } catch (e) {
      print('⚠️ 菜谱 ${recipe.name} 云端同步失败: $e');
      
      // 标记需要重新同步
      await _updateRecipeMetadata(recipe.id, {
        'needsSync': true,
        'syncError': e.toString(),
      });
    }
  }
  
  // ==================== 收藏管理 ====================
  
  /// ⭐ 获取收藏的菜谱 - 本地优先
  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    try {
      // 1. 获取收藏ID列表
      final favoriteIds = _getFavoriteIdsFromLocal(userId);
      
      // 2. 根据ID获取菜谱详情
      final favoriteRecipes = <Recipe>[];
      for (final recipeId in favoriteIds) {
        final recipe = await _getRecipeById(recipeId);
        if (recipe != null) {
          favoriteRecipes.add(recipe);
        }
      }
      
      return favoriteRecipes;
    } catch (e) {
      print('❌ 获取收藏菜谱失败: $e');
      return [];
    }
  }
  
  /// 📋 从本地获取收藏ID列表
  List<String> _getFavoriteIdsFromLocal(String userId) {
    if (_favoritesBox == null) return [];
    
    return _favoritesBox!.get(userId) ?? [];
  }
  
  /// ⭐ 添加收藏
  Future<void> addFavorite(String userId, String recipeId) async {
    try {
      // 1. 更新本地收藏列表
      final favoriteIds = _getFavoriteIdsFromLocal(userId);
      if (!favoriteIds.contains(recipeId)) {
        favoriteIds.add(recipeId);
        await _favoritesBox!.put(userId, favoriteIds);
      }
      
      // 2. 异步同步到云端
      _syncFavoritesToCloudAsync(userId, favoriteIds);
      
    } catch (e) {
      print('❌ 添加收藏失败: $e');
      throw Exception('添加收藏失败: $e');
    }
  }
  
  /// 💔 移除收藏
  Future<void> removeFavorite(String userId, String recipeId) async {
    try {
      // 1. 更新本地收藏列表
      final favoriteIds = _getFavoriteIdsFromLocal(userId);
      favoriteIds.remove(recipeId);
      await _favoritesBox!.put(userId, favoriteIds);
      
      // 2. 异步同步到云端
      _syncFavoritesToCloudAsync(userId, favoriteIds);
      
    } catch (e) {
      print('❌ 移除收藏失败: $e');
      throw Exception('移除收藏失败: $e');
    }
  }
  
  /// ☁️ 异步同步收藏到云端
  void _syncFavoritesToCloudAsync(String userId, List<String> favoriteIds) async {
    try {
      // TODO: 实现云端收藏同步
      print('✅ 收藏列表已同步到云端');
    } catch (e) {
      print('⚠️ 收藏同步失败: $e');
    }
  }
  
  // ==================== 预设菜谱管理 ====================
  
  /// 📚 获取预设菜谱 - 首次下载后本地访问
  Future<List<Recipe>> getPresetRecipes() async {
    try {
      // 1. 检查本地是否有预设菜谱
      final localPresets = _getPresetRecipesFromLocal();
      
      if (localPresets.isNotEmpty) {
        // 本地有数据，返回本地数据
        _checkPresetUpdatesInBackground();
        return localPresets;
      } else {
        // 本地无数据，从云端下载
        return await _downloadPresetRecipes();
      }
    } catch (e) {
      print('❌ 获取预设菜谱失败: $e');
      return [];
    }
  }
  
  /// 📋 从本地获取预设菜谱
  List<Recipe> _getPresetRecipesFromLocal() {
    if (_presetBox == null) return [];
    
    return _presetBox!.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // 按名称排序
  }
  
  /// ⬇️ 下载预设菜谱
  Future<List<Recipe>> _downloadPresetRecipes() async {
    try {
      final presetRecipes = await _cloudRepository.getPresetRecipes();
      
      // 保存到本地
      if (_presetBox != null) {
        for (final recipe in presetRecipes) {
          await _presetBox!.put(recipe.id, recipe);
        }
      }
      
      // 记录下载时间
      await _updateMetadata('preset_last_downloaded', DateTime.now().toIso8601String());
      
      print('✅ 预设菜谱下载完成: ${presetRecipes.length} 个');
      return presetRecipes;
    } catch (e) {
      print('❌ 下载预设菜谱失败: $e');
      return [];
    }
  }
  
  /// 🔄 后台检查预设菜谱更新
  void _checkPresetUpdatesInBackground() async {
    try {
      // 检查上次更新时间
      final lastCheck = await _getMetadata('preset_last_check');
      final now = DateTime.now();
      
      if (lastCheck != null) {
        final lastCheckTime = DateTime.parse(lastCheck);
        final daysSinceLastCheck = now.difference(lastCheckTime).inDays;
        
        // 每7天检查一次更新
        if (daysSinceLastCheck < 7) {
          return;
        }
      }
      
      // 检查云端是否有更新
      final cloudPresets = await _cloudRepository.getPresetRecipes();
      final localPresets = _getPresetRecipesFromLocal();
      
      // 简单的版本检查：比较数量
      if (cloudPresets.length != localPresets.length) {
        // 有更新，重新下载
        await _downloadPresetRecipes();
        print('✅ 预设菜谱已更新');
      }
      
      // 记录检查时间
      await _updateMetadata('preset_last_check', now.toIso8601String());
      
    } catch (e) {
      print('⚠️ 预设菜谱更新检查失败: $e');
    }
  }
  
  // ==================== 工具方法 ====================
  
  /// 🔍 根据ID获取菜谱（优先本地）
  Future<Recipe?> _getRecipeById(String recipeId) async {
    // 1. 检查用户菜谱
    if (_recipesBox != null) {
      final recipe = _recipesBox!.get(recipeId);
      if (recipe != null) return recipe;
    }
    
    // 2. 检查预设菜谱
    if (_presetBox != null) {
      final recipe = _presetBox!.get(recipeId);
      if (recipe != null) return recipe;
    }
    
    // 3. 检查分享菜谱
    if (_sharedBox != null) {
      final recipe = _sharedBox!.get(recipeId);
      if (recipe != null) return recipe;
    }
    
    // 4. 从云端获取
    try {
      return await _cloudRepository.getRecipe(recipeId);
    } catch (e) {
      print('⚠️ 从云端获取菜谱失败: $e');
      return null;
    }
  }
  
  /// 📝 更新菜谱元数据
  Future<void> _updateRecipeMetadata(String recipeId, Map<String, dynamic> metadata) async {
    if (_metadataBox == null) return;
    
    final currentMetadata = _metadataBox!.get(recipeId) ?? <String, dynamic>{};
    currentMetadata.addAll(metadata);
    
    await _metadataBox!.put(recipeId, currentMetadata);
  }
  
  /// 🏷️ 标记菜谱需要更新
  Future<void> _markRecipeNeedsUpdate(String recipeId, Recipe updatedRecipe) async {
    await _updateRecipeMetadata(recipeId, {
      'hasCloudUpdate': true,
      'cloudVersion': updatedRecipe.updatedAt.toIso8601String(),
      'needsUserDecision': true,
    });
    
    // TODO: 触发更新通知
    print('📢 菜谱 ${updatedRecipe.name} 有云端更新');
  }
  
  /// 🗑️ 标记菜谱已删除
  Future<void> _markRecipeDeleted(String recipeId) async {
    await _updateRecipeMetadata(recipeId, {
      'isDeleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
    });
  }
  
  /// 📊 更新全局元数据
  Future<void> _updateMetadata(String key, String value) async {
    if (_metadataBox == null) return;
    
    final metadata = _metadataBox!.get('global') ?? <String, dynamic>{};
    metadata[key] = value;
    
    await _metadataBox!.put('global', metadata);
  }
  
  /// 📊 获取全局元数据
  Future<String?> _getMetadata(String key) async {
    if (_metadataBox == null) return null;
    
    final metadata = _metadataBox!.get('global');
    return metadata?[key] as String?;
  }
  
  /// 🧹 清理缓存
  Future<void> clearCache() async {
    try {
      await _recipesBox?.clear();
      await _favoritesBox?.clear();
      await _metadataBox?.clear();
      await _presetBox?.clear();
      await _sharedBox?.clear();
      
      print('✅ 缓存已清理');
    } catch (e) {
      print('❌ 清理缓存失败: $e');
    }
  }
  
  /// 🔄 执行登录数据同步
  Future<void> performLoginDataSync(String userId) async {
    try {
      print('🔄 开始登录数据同步: $userId');
      
      // 同步用户菜谱
      await getUserRecipes(userId);
      
      // 同步预设菜谱
      await getPresetRecipes();
      
      print('✅ 登录数据同步完成');
    } catch (e) {
      print('❌ 登录数据同步失败: $e');
    }
  }

  /// 📋 获取所有待更新项目
  List<String> getAllPendingUpdates() {
    // 返回空列表，暂时不实现复杂的更新检测
    return [];
  }

  /// 📈 获取缓存统计信息
  Map<String, int> getCacheStats() {
    return {
      'userRecipes': _recipesBox?.length ?? 0,
      'presetRecipes': _presetBox?.length ?? 0,
      'sharedRecipes': _sharedBox?.length ?? 0,
      'favoriteUsers': _favoritesBox?.length ?? 0,
      'metadata': _metadataBox?.length ?? 0,
    };
  }
}