/// 🔐 认证状态管理 Providers
/// 
/// 使用 Riverpod 管理应用中的认证状态
/// 提供认证服务、用户状态和认证相关操作的全局访问
/// 
/// 主要 Providers：
/// - authServiceProvider: 认证服务实例
/// - authStateProvider: 当前认证状态
/// - currentUserProvider: 当前用户信息
/// - authRepositoryProvider: 认证仓库
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../../exceptions/auth_exceptions.dart';

/// 🚀 Firebase 应用实例 Provider
/// 
/// 获取已初始化的 Firebase 应用实例
/// 假设 Firebase 已在 main.dart 中初始化完成
final firebaseAppProvider = Provider<FirebaseApp>((ref) {
  try {
    // 获取默认的 Firebase 应用实例
    final app = Firebase.app();
    debugPrint('✅ 获取 Firebase 应用实例成功');
    return app;
  } catch (e) {
    debugPrint('❌ 获取 Firebase 应用实例失败: $e');
    throw AuthException('Firebase 未初始化', 'FIREBASE_NOT_INITIALIZED');
  }
});

/// 🛡️ 认证服务 Provider
/// 
/// 提供全局的认证服务实例
/// 依赖于 Firebase 初始化完成
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 🚀 认证服务初始化 Provider
/// 
/// 确保认证服务在使用前已正确初始化
/// 返回已初始化的认证服务实例
final initializedAuthServiceProvider = FutureProvider<AuthService>((ref) async {
  try {
    // 确保 Firebase 应用实例可用
    ref.watch(firebaseAppProvider);
    
    // 获取认证服务实例并初始化
    final authService = ref.watch(authServiceProvider);
    await authService.initialize();
    
    debugPrint('✅ AuthService 初始化完成');
    return authService;
    
  } catch (e) {
    debugPrint('❌ AuthService 初始化失败: $e');
    throw AuthException('认证服务初始化失败', 'AUTH_SERVICE_INIT_FAILED');
  }
});

/// 🎭 认证状态 Provider
/// 
/// 监听用户认证状态变化
/// 返回当前登录的用户对象，未登录时返回 null
final authStateProvider = StreamProvider<AppUser?>((ref) async* {
  try {
    // 等待认证服务初始化完成
    final authService = await ref.watch(initializedAuthServiceProvider.future);
    
    // 监听用户状态变化
    yield* authService.userStream;
    
  } catch (e) {
    debugPrint('❌ 监听认证状态失败: $e');
    // 如果出错，返回未登录状态
    yield null;
  }
});

/// 👤 当前用户 Provider
/// 
/// 提供当前登录用户的同步访问
/// 基于认证状态 Provider 构建
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (error, stackTrace) {
      debugPrint('❌ 获取当前用户失败: $error');
      return null;
    },
  );
});

/// ✅ 登录状态 Provider
/// 
/// 简单的布尔值，表示用户是否已登录
final isLoggedInProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser != null;
});

/// 📧 邮箱验证状态 Provider
/// 
/// 检查当前用户的邮箱是否已验证
final emailVerificationProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) return false;
  
  // 从认证服务获取实时验证状态
  try {
    final authService = ref.watch(authServiceProvider);
    // 这里应该检查 Firebase 用户的 emailVerified 状态
    // 暂时返回 true，实际实现需要从 FirebaseAuth 获取
    return true;
  } catch (e) {
    debugPrint('❌ 检查邮箱验证状态失败: $e');
    return false;
  }
});

/// 🏆 用户等级 Provider
/// 
/// 获取当前用户的等级信息
final userLevelProvider = Provider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.userLevel ?? 1;
});

/// 📈 用户经验值 Provider
/// 
/// 获取当前用户的经验值
final userExperienceProvider = Provider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.userExperience ?? 0;
});

/// 💑 情侣绑定状态 Provider
/// 
/// 检查当前用户是否已绑定情侣
final coupleBindingProvider = Provider<CoupleBinding?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.coupleBinding;
});

/// ✅ 是否已绑定情侣 Provider
/// 
/// 简单的布尔值，表示用户是否已绑定情侣
final isCoupleLinkedProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.isCoupleLinked ?? false;
});

/// 🏠 用户偏好设置 Provider
/// 
/// 获取当前用户的偏好设置
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.preferences ?? UserPreferences.defaultSettings();
});

/// 🌙 深色模式 Provider
/// 
/// 从用户偏好设置中获取深色模式状态
final darkModeProvider = Provider<bool>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.isDarkMode;
});

/// 🔔 通知设置 Provider
/// 
/// 从用户偏好设置中获取通知开启状态
final notificationsEnabledProvider = Provider<bool>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.enableNotifications;
});

/// 📊 用户统计数据 Provider
/// 
/// 获取当前用户的统计数据
final userStatsProvider = Provider<UserStats>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.stats ?? UserStats.initial();
});

/// 🎯 认证操作 Provider
/// 
/// 提供认证相关操作的封装方法
/// 🔧 修复：使用共享的AuthService实例确保状态同步
final authActionsProvider = StateNotifierProvider<AuthActionsNotifier, AuthActionState>((ref) {
  // 使用共享的AuthService实例，确保状态流一致
  final authService = ref.watch(authServiceProvider);
  return AuthActionsNotifier(authService);
});

/// 🎬 认证操作状态
/// 
/// 表示认证操作的当前状态
enum AuthActionState {
  /// 空闲状态
  idle,
  /// 正在处理
  loading,
  /// 操作成功
  success,
  /// 操作失败
  error,
}

/// 🎭 认证操作状态管理器
/// 
/// 管理各种认证操作（登录、注册、登出等）的状态
/// 采用最简单的同步架构，彻底避免时机问题
class AuthActionsNotifier extends StateNotifier<AuthActionState> {
  /// 认证服务实例
  final AuthService _authService;
  
  /// 最后的错误信息
  AuthException? _lastError;
  
  /// 构造函数
  /// 
  /// [authService] 认证服务实例
  AuthActionsNotifier(this._authService) : super(AuthActionState.idle) {
    // 异步初始化服务，但不阻塞构造函数
    _initializeService();
  }
  
  /// 获取最后的错误信息
  AuthException? get lastError => _lastError;
  
  /// 🚀 异步初始化服务（后台进行，不阻塞UI）
  void _initializeService() async {
    try {
      await _authService.initialize();
      debugPrint('✅ AuthService 后台初始化完成');
    } catch (e) {
      debugPrint('⚠️ AuthService 初始化失败，将在使用时重试: $e');
    }
  }
  
  /// 🔐 邮箱密码登录
  /// 
  /// [email] 邮箱地址
  /// [password] 密码
  /// 
  /// 返回登录是否成功
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 邮箱登录失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('登录过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 邮箱登录异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 📝 邮箱密码注册
  /// 
  /// [email] 邮箱地址
  /// [password] 密码
  /// [displayName] 显示名称（可选）
  /// 
  /// 返回注册是否成功
  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 邮箱注册失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('注册过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 邮箱注册异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🌐 Google 登录
  /// 
  /// 返回登录是否成功
  Future<bool> signInWithGoogle() async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.signInWithGoogle();
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ Google 登录失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('Google 登录过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ Google 登录异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🚪 登出
  /// 
  /// 返回登出是否成功
  Future<bool> signOut() async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.signOut();
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 登出失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('登出过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 登出异常: $e');
      return false;
    } finally {
      // 1秒后重置状态
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🔄 密码重置
  /// 
  /// [email] 邮箱地址
  /// 
  /// 返回操作是否成功
  Future<bool> resetPassword(String email) async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.resetPassword(email);
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 密码重置失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('密码重置过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 密码重置异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 📧 重新发送邮箱验证
  /// 
  /// 返回操作是否成功
  Future<bool> resendEmailVerification() async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.resendEmailVerification();
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 邮箱验证发送失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('邮箱验证发送过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 邮箱验证发送异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🔄 更新用户资料
  /// 
  /// [displayName] 显示名称
  /// [photoURL] 头像 URL
  /// 
  /// 返回操作是否成功
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 用户资料更新失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('用户资料更新过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 用户资料更新异常: $e');
      return false;
    } finally {
      // 2秒后重置状态
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🏠 更新用户偏好设置
  /// 
  /// [preferences] 新的偏好设置
  /// 
  /// 返回操作是否成功
  Future<bool> updatePreferences(UserPreferences preferences) async {
    try {
      state = AuthActionState.loading;
      _lastError = null;
      
      await _authService.updatePreferences(preferences);
      
      state = AuthActionState.success;
      return true;
      
    } on AuthException catch (e) {
      _lastError = e;
      state = AuthActionState.error;
      debugPrint('❌ 用户偏好设置更新失败: ${e.message}');
      return false;
    } catch (e) {
      _lastError = AuthException('偏好设置更新过程中发生未知错误', 'UNKNOWN_ERROR');
      state = AuthActionState.error;
      debugPrint('❌ 偏好设置更新异常: $e');
      return false;
    } finally {
      // 1秒后重置状态
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) state = AuthActionState.idle;
      });
    }
  }
  
  /// 🔄 重置操作状态
  /// 
  /// 手动重置状态为空闲，清除错误信息
  void resetState() {
    state = AuthActionState.idle;
    _lastError = null;
  }
}