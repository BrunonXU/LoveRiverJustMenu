import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../new_user_initialization_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/models/app_user.dart';
import '../../firestore/repositories/recipe_repository.dart';

/// 🚀 新用户初始化服务Provider
final newUserInitializationServiceProvider = Provider<NewUserInitializationService>((ref) {
  return NewUserInitializationService();
});

/// 📋 用户初始化状态Provider
final userInitializationStatusProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.read(newUserInitializationServiceProvider);
  return await service.isUserInitialized(userId);
});

/// 🎯 当前用户初始化状态Provider
final currentUserInitializationStatusProvider = FutureProvider<bool>((ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return false;
  
  final service = ref.read(newUserInitializationServiceProvider);
  return await service.isUserInitialized(user.uid);
});

/// 📊 初始化统计信息Provider
final initializationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(newUserInitializationServiceProvider);
  return await service.getInitializationStats();
});

/// 🔄 新用户自动初始化监听器Provider
final newUserAutoInitializerProvider = Provider<NewUserAutoInitializer>((ref) {
  final service = ref.read(newUserInitializationServiceProvider);
  return NewUserAutoInitializer(ref, service);
});

/// 🤖 新用户自动初始化监听器类
class NewUserAutoInitializer {
  final Ref _ref;
  final NewUserInitializationService _service;
  
  // 缓存已处理的用户，避免重复初始化
  final Set<String> _processedUsers = {};
  
  NewUserAutoInitializer(this._ref, this._service) {
    _startListening();
  }

  /// 🎧 开始监听用户状态变化
  void _startListening() {
    // 监听认证状态变化
    _ref.listen<AsyncValue<AppUser?>>(
      authStateProvider,
      (previous, next) {
        _handleAuthStateChange(previous, next);
      },
    );
  }

  /// 🔄 处理认证状态变化
  void _handleAuthStateChange(
    AsyncValue<AppUser?>? previous, 
    AsyncValue<AppUser?>? next
  ) async {
    // 只处理成功登录的情况
    if (next?.value == null) return;
    
    final user = next!.value!;
    final userId = user.uid;
    
    // 检查是否已处理过这个用户
    if (_processedUsers.contains(userId)) {
      debugPrint('👤 用户已处理过，跳过初始化: $userId');
      return;
    }
    
    try {
      debugPrint('👤 检测到新登录用户: $userId');
      
      // 检查用户是否已初始化
      final isInitialized = await _service.isUserInitialized(userId);
      
      if (!isInitialized) {
        debugPrint('🚀 开始为新用户初始化预设菜谱: $userId');
        
        // 获取云端仓库
        final repository = await _ref.read(initializedCloudRecipeRepositoryProvider.future);
        
        // 执行初始化
        final success = await _service.initializeNewUser(userId, repository);
        
        if (success) {
          debugPrint('🎉 新用户初始化成功: $userId');
          
          // 可以在这里添加成功回调，比如显示欢迎消息
          _onInitializationSuccess(userId);
        } else {
          debugPrint('❌ 新用户初始化失败: $userId');
          
          // 可以在这里添加失败处理
          _onInitializationFailure(userId);
        }
      } else {
        debugPrint('✅ 用户已初始化，无需重复处理: $userId');
      }
      
      // 标记用户已处理
      _processedUsers.add(userId);
      
    } catch (e) {
      debugPrint('❌ 处理新用户初始化异常: $userId -> $e');
    }
  }

  /// 🎉 初始化成功回调
  void _onInitializationSuccess(String userId) {
    debugPrint('🎊 用户初始化成功回调: $userId');
    
    // 可以在这里添加：
    // - 显示欢迎提示
    // - 发送统计事件
    // - 刷新相关Provider
    
    // 刷新用户菜谱相关的Provider
    _ref.invalidate(currentUserInitializationStatusProvider);
  }

  /// 💔 初始化失败回调
  void _onInitializationFailure(String userId) {
    debugPrint('💥 用户初始化失败回调: $userId');
    
    // 可以在这里添加：
    // - 记录错误日志
    // - 安排重试逻辑
    // - 发送失败通知
  }

  /// 🔄 手动触发用户初始化
  Future<bool> manualInitializeUser(String userId) async {
    try {
      debugPrint('🔄 手动触发用户初始化: $userId');
      
      final repository = await _ref.read(initializedCloudRecipeRepositoryProvider.future);
      final success = await _service.initializeNewUser(userId, repository);
      
      if (success) {
        _processedUsers.add(userId);
        _onInitializationSuccess(userId);
      } else {
        _onInitializationFailure(userId);
      }
      
      return success;
      
    } catch (e) {
      debugPrint('❌ 手动初始化用户异常: $userId -> $e');
      return false;
    }
  }

  /// 🧹 清理处理缓存
  void clearProcessedCache() {
    _processedUsers.clear();
    debugPrint('🧹 已清理用户处理缓存');
  }

  /// 📊 获取处理状态
  Map<String, dynamic> getProcessingStatus() {
    return {
      'processedUsers': _processedUsers.toList(),
      'processedCount': _processedUsers.length,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// 🎯 新用户初始化操作Provider
final newUserInitializationActionsProvider = Provider<NewUserInitializationActions>((ref) {
  final service = ref.read(newUserInitializationServiceProvider);
  final autoInitializer = ref.read(newUserAutoInitializerProvider);
  
  return NewUserInitializationActions(service, autoInitializer, ref);
});

/// 🎭 新用户初始化操作类
class NewUserInitializationActions {
  final NewUserInitializationService _service;
  final NewUserAutoInitializer _autoInitializer;
  final Ref _ref;
  
  NewUserInitializationActions(this._service, this._autoInitializer, this._ref);

  /// 🔄 手动初始化当前用户
  Future<bool> initializeCurrentUser() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;
    
    return await _autoInitializer.manualInitializeUser(user.uid);
  }

  /// 🔄 重新初始化当前用户
  Future<bool> reinitializeCurrentUser() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;
    
    try {
      final repository = await _ref.read(initializedCloudRecipeRepositoryProvider.future);
      return await _service.reinitializeUser(user.uid, repository);
    } catch (e) {
      debugPrint('❌ 重新初始化当前用户失败: $e');
      return false;
    }
  }

  /// 📊 获取初始化统计
  Future<Map<String, dynamic>> getStats() async {
    return await _service.getInitializationStats();
  }

  /// 🔍 获取当前用户初始化详情
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return null;
    
    return await _service.getUserInitializationDetails(user.uid);
  }

  /// 🧹 清理缓存
  void clearCache() {
    _autoInitializer.clearProcessedCache();
  }
}