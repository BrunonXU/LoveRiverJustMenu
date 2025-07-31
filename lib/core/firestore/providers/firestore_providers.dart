/// 🔥 Firestore 数据仓库提供者
/// 
/// 管理Firestore数据仓库的依赖注入
/// 提供用户和菜谱数据的统一访问接口
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../repositories/recipe_repository.dart';
import '../../auth/models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../features/recipe/domain/models/recipe.dart';

// ==================== 基础服务提供者 ====================

/// Firestore 实例提供者
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// 用户数据仓库提供者
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserRepository(firestore: firestore);
});

/// 菜谱数据仓库提供者
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return RecipeRepository(firestore: firestore);
});

// ==================== 用户数据提供者 ====================

/// 当前用户Firestore数据流提供者
/// 
/// 监听当前登录用户的云端数据变化
final currentUserFirestoreProvider = StreamProvider<AppUser?>((ref) async* {
  // 直接监听当前用户状态
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    yield null;
    return;
  }
  
  // 监听用户的Firestore数据
  final userRepository = ref.read(userRepositoryProvider);
  await for (final firestoreUser in userRepository.watchUser(currentUser.uid)) {
    yield firestoreUser ?? currentUser; // 如果云端没有数据，使用本地用户数据
  }
});

/// 用户偏好设置更新方法提供者
final updateUserPreferencesProvider = Provider<Future<bool> Function(UserPreferences)>((ref) {
  return (preferences) async {
    final userRepository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await userRepository.updateUserPreferences(currentUser.uid, preferences);
  };
});

/// 用户统计数据更新方法提供者
final updateUserStatsProvider = Provider<Future<bool> Function(UserStats)>((ref) {
  return (stats) async {
    final userRepository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await userRepository.updateUserStats(currentUser.uid, stats);
  };
});

// ==================== 菜谱数据提供者 ====================

/// 用户菜谱列表流提供者
/// 
/// 监听当前用户的所有菜谱（包括共享菜谱）
final userRecipesFirestoreProvider = StreamProvider<List<Recipe>>((ref) async* {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    yield [];
    return;
  }
  
  final recipeRepository = ref.read(recipeRepositoryProvider);
  await for (final recipes in recipeRepository.watchUserRecipes(currentUser.uid)) {
    yield recipes;
  }
});

/// 个人菜谱列表流提供者（不包括共享菜谱）
final personalRecipesFirestoreProvider = StreamProvider<List<Recipe>>((ref) async* {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    yield [];
    return;
  }
  
  final recipeRepository = ref.read(recipeRepositoryProvider);
  await for (final recipes in recipeRepository.watchUserRecipes(
    currentUser.uid, 
    includeShared: false,
  )) {
    yield recipes;
  }
});

/// 保存菜谱方法提供者
final saveRecipeProvider = Provider<Future<String> Function(Recipe)>((ref) {
  return (recipe) async {
    final recipeRepository = ref.read(recipeRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await recipeRepository.saveRecipe(recipe, currentUser.uid);
  };
});

/// 删除菜谱方法提供者
final deleteRecipeProvider = Provider<Future<bool> Function(String)>((ref) {
  return (recipeId) async {
    final recipeRepository = ref.read(recipeRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await recipeRepository.deleteRecipe(recipeId, currentUser.uid);
  };
});

/// 搜索菜谱方法提供者
final searchRecipesProvider = Provider<Future<List<Recipe>> Function(String)>((ref) {
  return (keyword) async {
    final recipeRepository = ref.read(recipeRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await recipeRepository.searchRecipes(keyword, currentUser.uid);
  };
});

/// 共享菜谱给伴侣方法提供者
final shareRecipeWithPartnerProvider = Provider<Future<bool> Function(String, String)>((ref) {
  return (recipeId, partnerId) async {
    final recipeRepository = ref.read(recipeRepositoryProvider);
    return await recipeRepository.shareRecipeWithPartner(recipeId, partnerId);
  };
});

/// 更新菜谱统计方法提供者
final updateRecipeStatsProvider = Provider<Future<bool> Function(String, String)>((ref) {
  return (recipeId, action) async {
    final recipeRepository = ref.read(recipeRepositoryProvider);
    return await recipeRepository.updateRecipeStats(recipeId, action);
  };
});

/// 热门菜谱提供者
final popularRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final recipeRepository = ref.read(recipeRepositoryProvider);
  return await recipeRepository.getPopularRecipes(limit: 20);
});

// ==================== 情侣功能提供者 ====================

/// 绑定情侣关系方法提供者
final bindCoupleProvider = Provider<Future<bool> Function(CoupleBinding)>((ref) {
  return (coupleBinding) async {
    final userRepository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await userRepository.bindCouple(currentUser.uid, coupleBinding);
  };
});

/// 解除情侣关系方法提供者
final unbindCoupleProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final userRepository = ref.read(userRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser == null) {
      throw Exception('用户未登录');
    }
    
    return await userRepository.unbindCouple(currentUser.uid);
  };
});

/// 通过邮箱查找用户方法提供者
final getUserByEmailProvider = Provider<Future<AppUser?> Function(String)>((ref) {
  return (email) async {
    final userRepository = ref.read(userRepositoryProvider);
    return await userRepository.getUserByEmail(email);
  };
});

// ==================== 数据同步提供者 ====================

/// 数据同步状态提供者
final dataSyncStateProvider = StateProvider<DataSyncState>((ref) {
  return DataSyncState.idle;
});

/// 手动同步用户数据方法提供者
final syncUserDataProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return false;
    
    ref.read(dataSyncStateProvider.notifier).state = DataSyncState.syncing;
    
    try {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.saveUser(currentUser);
      
      ref.read(dataSyncStateProvider.notifier).state = DataSyncState.success;
      return true;
    } catch (e) {
      ref.read(dataSyncStateProvider.notifier).state = DataSyncState.error;
      return false;
    }
  };
});

/// 离线模式检测提供者
final isOfflineModeProvider = StateProvider<bool>((ref) {
  return false; // 默认在线模式
});

// ==================== 错误处理提供者 ====================

/// Firestore错误处理提供者
final firestoreErrorProvider = StateProvider<String?>((ref) {
  return null;
});

/// 清除错误方法提供者
final clearFirestoreErrorProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(firestoreErrorProvider.notifier).state = null;
  };
});

// ==================== 枚举和常量 ====================

/// 数据同步状态枚举
enum DataSyncState {
  idle,      // 空闲
  syncing,   // 同步中
  success,   // 同步成功
  error,     // 同步失败
}

// 认证提供者已在文件开头导入