import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/json_recipe_importer.dart';
import '../firestore/repositories/recipe_repository.dart';

/// 🚀 新用户初始化服务
/// 
/// 功能：
/// - 检测新用户首次登录
/// - 自动初始化预设菜谱
/// - 记录初始化状态
/// - 提供初始化统计
class NewUserInitializationService {
  static const String _collectionName = 'user_initialization';
  static const String _rootUserId = '2352016835@qq.com';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📋 检查用户是否已初始化
  Future<bool> isUserInitialized(String userId) async {
    try {
      debugPrint('📋 检查用户初始化状态: $userId');
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();
          
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final isInitialized = data['isInitialized'] as bool? ?? false;
        debugPrint('✅ 用户初始化状态: $userId -> $isInitialized');
        return isInitialized;
      }
      
      debugPrint('⚠️ 用户未找到初始化记录: $userId');
      return false;
      
    } catch (e) {
      debugPrint('❌ 检查用户初始化状态失败: $e');
      return false; // 保守策略：出错时认为未初始化
    }
  }

  /// 🚀 为新用户初始化预设菜谱
  Future<bool> initializeNewUser(String userId, RecipeRepository repository) async {
    try {
      debugPrint('🚀 开始初始化新用户: $userId');
      
      // 1. 检查是否已经初始化过
      final alreadyInitialized = await isUserInitialized(userId);
      if (alreadyInitialized) {
        debugPrint('⚠️ 用户已初始化，跳过: $userId');
        return true;
      }
      
      // 2. 检查用户是否已有菜谱（避免重复初始化）
      final existingRecipes = await repository.getUserRecipes(userId);
      if (existingRecipes.isNotEmpty) {
        debugPrint('⚠️ 用户已有菜谱，标记为已初始化: $userId');
        await _markUserAsInitialized(userId, existingRecipes.length);
        return true;
      }
      
      // 3. 执行预设菜谱初始化
      final successCount = await JsonRecipeImporter.initializeNewUserWithPresets(
        userId,
        _rootUserId,
        repository,
      );
      
      // 4. 记录初始化结果
      if (successCount > 0) {
        await _markUserAsInitialized(userId, successCount);
        debugPrint('🎉 新用户初始化成功: $userId -> $successCount 个菜谱');
        return true;
      } else {
        debugPrint('❌ 新用户初始化失败: $userId -> 0 个菜谱');
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ 新用户初始化异常: $userId -> $e');
      return false;
    }
  }

  /// ✅ 标记用户为已初始化
  Future<void> _markUserAsInitialized(String userId, int recipeCount) async {
    try {
      final initData = {
        'userId': userId,
        'isInitialized': true,
        'recipeCount': recipeCount,
        'initializedAt': DateTime.now().toIso8601String(),
        'rootUserId': _rootUserId,
        'version': '1.0.0',
      };
      
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(initData);
          
      debugPrint('✅ 用户初始化状态已记录: $userId');
      
    } catch (e) {
      debugPrint('❌ 记录用户初始化状态失败: $e');
    }
  }

  /// 🔄 重新初始化用户（调试用）
  Future<bool> reinitializeUser(String userId, RecipeRepository repository) async {
    try {
      debugPrint('🔄 重新初始化用户: $userId');
      
      // 1. 清除初始化记录
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .delete();
      
      // 2. 执行初始化
      return await initializeNewUser(userId, repository);
      
    } catch (e) {
      debugPrint('❌ 重新初始化用户失败: $e');
      return false;
    }
  }

  /// 📊 获取初始化统计信息
  Future<Map<String, dynamic>> getInitializationStats() async {
    try {
      debugPrint('📊 获取初始化统计信息');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
      
      int totalInitializedUsers = 0;
      int totalRecipes = 0;
      DateTime? earliestInit;
      DateTime? latestInit;
      
      for (final doc in querySnapshot.docs) {
        if (doc.exists && doc.data()['isInitialized'] == true) {
          totalInitializedUsers++;
          
          final recipeCount = doc.data()['recipeCount'] as int? ?? 0;
          totalRecipes += recipeCount;
          
          final initDateStr = doc.data()['initializedAt'] as String?;
          if (initDateStr != null) {
            final initDate = DateTime.parse(initDateStr);
            if (earliestInit == null || initDate.isBefore(earliestInit)) {
              earliestInit = initDate;
            }
            if (latestInit == null || initDate.isAfter(latestInit)) {
              latestInit = initDate;
            }
          }
        }
      }
      
      final stats = {
        'totalInitializedUsers': totalInitializedUsers,
        'totalRecipesDistributed': totalRecipes,
        'averageRecipesPerUser': totalInitializedUsers > 0 ? totalRecipes / totalInitializedUsers : 0,
        'earliestInitialization': earliestInit?.toIso8601String(),
        'latestInitialization': latestInit?.toIso8601String(),
        'generatedAt': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ 初始化统计信息: $stats');
      return stats;
      
    } catch (e) {
      debugPrint('❌ 获取初始化统计信息失败: $e');
      return {
        'error': e.toString(),
        'totalInitializedUsers': 0,
        'totalRecipesDistributed': 0,
      };
    }
  }

  /// 🧹 清理初始化记录（管理员功能）
  Future<int> cleanupInitializationRecords() async {
    try {
      debugPrint('🧹 清理初始化记录');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
      
      int deletedCount = 0;
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      debugPrint('✅ 清理完成: $deletedCount 条记录');
      return deletedCount;
      
    } catch (e) {
      debugPrint('❌ 清理初始化记录失败: $e');
      return 0;
    }
  }

  /// 🔍 获取用户初始化详情
  Future<Map<String, dynamic>?> getUserInitializationDetails(String userId) async {
    try {
      debugPrint('🔍 获取用户初始化详情: $userId');
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        debugPrint('✅ 用户初始化详情: $data');
        return data;
      }
      
      debugPrint('⚠️ 未找到用户初始化记录: $userId');
      return null;
      
    } catch (e) {
      debugPrint('❌ 获取用户初始化详情失败: $e');
      return null;
    }
  }

  /// 🌟 批量初始化多个用户（管理员功能）
  Future<Map<String, int>> batchInitializeUsers(
    List<String> userIds, 
    RecipeRepository repository
  ) async {
    debugPrint('🌟 批量初始化用户: ${userIds.length} 个');
    
    int successCount = 0;
    int failureCount = 0;
    
    for (final userId in userIds) {
      try {
        final success = await initializeNewUser(userId, repository);
        if (success) {
          successCount++;
        } else {
          failureCount++;
        }
      } catch (e) {
        debugPrint('❌ 批量初始化用户失败: $userId -> $e');
        failureCount++;
      }
    }
    
    final result = {
      'success': successCount,
      'failure': failureCount,
      'total': userIds.length,
    };
    
    debugPrint('🎉 批量初始化完成: $result');
    return result;
  }
}