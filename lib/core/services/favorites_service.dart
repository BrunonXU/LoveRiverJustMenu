import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/recipe/domain/models/recipe.dart';

/// 🌟 用户收藏功能服务
/// 
/// 功能：
/// - 添加/移除菜谱收藏
/// - 获取用户收藏列表
/// - 检查菜谱收藏状态
/// - 同步云端收藏数据
class FavoritesService {
  static const String _collectionName = 'user_favorites';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📋 获取用户收藏列表
  Future<UserFavorites> getUserFavorites(String userId) async {
    try {
      debugPrint('📋 获取用户收藏列表: $userId');
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();
          
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserFavorites.fromJson(data);
      } else {
        // 创建新的收藏记录
        final newFavorites = UserFavorites(
          userId: userId,
          favoriteRecipeIds: [],
          updatedAt: DateTime.now(),
        );
        
        await _firestore
            .collection(_collectionName)
            .doc(userId)
            .set(newFavorites.toJson());
            
        debugPrint('✅ 创建新用户收藏记录: $userId');
        return newFavorites;
      }
    } catch (e) {
      debugPrint('❌ 获取用户收藏失败: $e');
      // 返回空的收藏列表
      return UserFavorites(
        userId: userId,
        favoriteRecipeIds: [],
        updatedAt: DateTime.now(),
      );
    }
  }

  /// ⭐ 添加收藏
  Future<bool> addFavorite(String userId, String recipeId) async {
    try {
      debugPrint('⭐ 添加收藏: $userId -> $recipeId');
      
      final userFavorites = await getUserFavorites(userId);
      
      if (userFavorites.isFavorite(recipeId)) {
        debugPrint('⚠️ 菜谱已经收藏过了: $recipeId');
        return true;
      }
      
      userFavorites.addFavorite(recipeId);
      
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update(userFavorites.toJson());
          
      // 更新菜谱的收藏数量
      await _updateRecipeFavoriteCount(recipeId, 1);
      
      debugPrint('✅ 添加收藏成功: $recipeId');
      return true;
      
    } catch (e) {
      debugPrint('❌ 添加收藏失败: $e');
      return false;
    }
  }

  /// 💔 移除收藏
  Future<bool> removeFavorite(String userId, String recipeId) async {
    try {
      debugPrint('💔 移除收藏: $userId -> $recipeId');
      
      final userFavorites = await getUserFavorites(userId);
      
      if (!userFavorites.isFavorite(recipeId)) {
        debugPrint('⚠️ 菜谱未收藏: $recipeId');
        return true;
      }
      
      userFavorites.removeFavorite(recipeId);
      
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .update(userFavorites.toJson());
          
      // 更新菜谱的收藏数量
      await _updateRecipeFavoriteCount(recipeId, -1);
      
      debugPrint('✅ 移除收藏成功: $recipeId');
      return true;
      
    } catch (e) {
      debugPrint('❌ 移除收藏失败: $e');
      return false;
    }
  }

  /// 🔍 检查是否收藏
  Future<bool> isFavorite(String userId, String recipeId) async {
    try {
      final userFavorites = await getUserFavorites(userId);
      return userFavorites.isFavorite(recipeId);
    } catch (e) {
      debugPrint('❌ 检查收藏状态失败: $e');
      return false;
    }
  }

  /// 🔄 切换收藏状态
  Future<bool> toggleFavorite(String userId, String recipeId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(userId, recipeId);
      
      if (isCurrentlyFavorite) {
        return await removeFavorite(userId, recipeId);
      } else {
        return await addFavorite(userId, recipeId);
      }
    } catch (e) {
      debugPrint('❌ 切换收藏状态失败: $e');
      return false;
    }
  }

  /// 📊 获取收藏的菜谱列表
  Future<List<String>> getFavoriteRecipeIds(String userId) async {
    try {
      final userFavorites = await getUserFavorites(userId);
      return userFavorites.favoriteRecipeIds;
    } catch (e) {
      debugPrint('❌ 获取收藏菜谱ID列表失败: $e');
      return [];
    }
  }

  /// 🔢 获取菜谱收藏数量
  Future<int> getRecipeFavoriteCount(String recipeId) async {
    try {
      // 查询所有收藏了这个菜谱的用户数量
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('favoriteRecipeIds', arrayContains: recipeId)
          .get();
          
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ 获取菜谱收藏数量失败: $e');
      return 0;
    }
  }

  /// 📈 更新菜谱收藏数量
  Future<void> _updateRecipeFavoriteCount(String recipeId, int increment) async {
    try {
      // 这里需要更新菜谱文档的favoriteCount字段
      // 由于我们使用子集合存储，需要查找菜谱所属的用户
      // 为简化实现，暂时跳过这个功能
      // TODO: 实现菜谱收藏数量更新
      debugPrint('📈 更新菜谱收藏数量: $recipeId ($increment)');
    } catch (e) {
      debugPrint('❌ 更新菜谱收藏数量失败: $e');
    }
  }

  /// 🧹 清理用户收藏数据
  Future<bool> clearUserFavorites(String userId) async {
    try {
      debugPrint('🧹 清理用户收藏数据: $userId');
      
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .delete();
          
      debugPrint('✅ 清理用户收藏数据成功');
      return true;
      
    } catch (e) {
      debugPrint('❌ 清理用户收藏数据失败: $e');
      return false;
    }
  }

  /// 📊 获取热门收藏菜谱
  Future<Map<String, int>> getPopularFavorites({int limit = 10}) async {
    try {
      debugPrint('📊 获取热门收藏菜谱');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
          
      final Map<String, int> favoriteCount = {};
      
      for (final doc in querySnapshot.docs) {
        if (doc.exists && doc.data().containsKey('favoriteRecipeIds')) {
          final favoriteIds = List<String>.from(doc.data()['favoriteRecipeIds'] ?? []);
          for (final recipeId in favoriteIds) {
            favoriteCount[recipeId] = (favoriteCount[recipeId] ?? 0) + 1;
          }
        }
      }
      
      // 按收藏数量排序并限制数量
      final sortedFavorites = Map.fromEntries(
        favoriteCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(limit)
      );
      
      debugPrint('✅ 获取到 ${sortedFavorites.length} 个热门收藏');
      return sortedFavorites;
      
    } catch (e) {
      debugPrint('❌ 获取热门收藏失败: $e');
      return {};
    }
  }
}