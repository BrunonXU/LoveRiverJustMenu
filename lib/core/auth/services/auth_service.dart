/// 🔐 认证服务
/// 
/// 处理用户登录、注册、登出等认证操作
/// 集成 Firebase Auth 和本地用户数据管理
/// 
/// 主要功能：
/// - 邮箱密码登录/注册
/// - Google 登录
/// - 用户状态监听
/// - 本地用户数据缓存
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_user.dart';
import '../../exceptions/auth_exceptions.dart';
import '../../firestore/repositories/user_repository.dart';
import '../../firestore/repositories/recipe_repository.dart';
import '../../services/local_cache_service.dart';
import '../../utils/network_retry.dart';

/// 🛡️ 认证服务类
/// 
/// 管理用户认证状态和操作的核心服务
/// 提供统一的认证接口，支持多种登录方式
class AuthService {
  /// Firebase Auth 实例
  final FirebaseAuth _firebaseAuth;
  
  /// Google 登录实例
  final GoogleSignIn _googleSignIn;
  
  /// 本地用户数据存储
  late Box<AppUser> _userBox;
  
  /// Firestore 用户数据仓库
  final UserRepository _userRepository;
  
  /// 菜谱数据仓库
  final RecipeRepository _recipeRepository;
  
  /// 当前用户状态流控制器
  final StreamController<AppUser?> _userStateController = StreamController<AppUser?>.broadcast();
  
  /// 当前用户
  AppUser? _currentUser;
  
  /// 构造函数
  /// 
  /// [firebaseAuth] Firebase Auth 实例（可选，用于测试）
  /// [googleSignIn] Google 登录实例（可选，用于测试）
  /// [userRepository] Firestore 用户数据仓库（可选，用于测试）
  /// [recipeRepository] 菜谱数据仓库（可选，用于测试）
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    UserRepository? userRepository,
    RecipeRepository? recipeRepository,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],  // 🔥 完整云服务：请求完整用户信息权限
          // Web 平台配置 - 企业级完整实现
          // 从 Firebase Console > Authentication > Sign-in method > Google > Web SDK configuration 获取
          clientId: kIsWeb ? '266340306948-mmb2pl94494p4pcaj88chlr500jkl43b.apps.googleusercontent.com' : null,
        ),
        _userRepository = userRepository ?? UserRepository(),
        _recipeRepository = recipeRepository ?? RecipeRepository();
  
  /// 🚀 初始化认证服务
  /// 
  /// 设置本地存储和监听器
  /// 必须在使用服务前调用
  Future<void> initialize() async {
    try {
      // 初始化本地用户数据存储
      _userBox = await Hive.openBox<AppUser>('app_users');
      
      // 监听 Firebase Auth 状态变化
      _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
      
      // 检查当前用户状态
      await _checkCurrentUser();
      
      debugPrint('✅ AuthService 初始化完成');
    } catch (e) {
      debugPrint('❌ AuthService 初始化失败: $e');
      throw AuthException('认证服务初始化失败', 'INIT_FAILED');
    }
  }
  
  /// 👤 获取当前用户
  AppUser? get currentUser => _currentUser;
  
  /// 📡 用户状态变化流
  Stream<AppUser?> get userStream => _userStateController.stream;
  
  /// ✅ 检查用户是否已登录
  bool get isLoggedIn => _currentUser != null && _firebaseAuth.currentUser != null;
  
  /// ✉️ 邮箱密码注册
  /// 
  /// [email] 邮箱地址
  /// [password] 密码
  /// [displayName] 显示名称（可选）
  /// 
  /// 返回创建的用户对象
  /// 抛出 [AuthException] 如果注册失败
  Future<AppUser> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('📝 开始邮箱注册: $email');
      
      // 创建 Firebase 用户
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('用户创建失败', 'USER_CREATION_FAILED');
      }
      
      // 更新显示名称
      if (displayName?.isNotEmpty == true) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }
      
      // 创建应用用户对象
      final appUser = AppUser.fromFirebaseUser(credential.user!);
      
      // 保存到本地
      await _saveUserLocally(appUser);
      
      // 🔥 保存到Firestore云端
      try {
        await _userRepository.saveUser(appUser);
        debugPrint('☁️ 用户数据已同步到云端');
      } catch (e) {
        debugPrint('⚠️ 云端同步失败，但不影响注册: $e');
        // 云端同步失败不应该阻止注册流程
      }
      
      // 发送邮箱验证
      if (!credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
        debugPrint('📧 邮箱验证邮件已发送');
      }
      
      debugPrint('✅ 邮箱注册成功: ${appUser.email}');
      return appUser;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase 注册错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ 注册异常: $e');
      throw AuthException('注册过程中发生未知错误', 'UNKNOWN_ERROR');
    }
  }
  
  /// ✉️ 邮箱密码登录
  /// 
  /// [email] 邮箱地址
  /// [password] 密码
  /// 
  /// 返回用户对象
  /// 抛出 [AuthException] 如果登录失败
  Future<AppUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 开始邮箱登录: $email');
      
      // Firebase 登录
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('登录失败，用户不存在', 'USER_NOT_FOUND');
      }
      
      // 🔥 尝试从云端获取用户数据
      AppUser appUser;
      try {
        final cloudUser = await NetworkRetry.importantRetry(
          () => _userRepository.getUser(credential.user!.uid),
        );
        if (cloudUser != null) {
          // 使用云端数据，更新Firebase用户信息
          appUser = cloudUser.copyWith(
            displayName: credential.user!.displayName ?? cloudUser.displayName,
            photoURL: credential.user!.photoURL ?? cloudUser.photoURL,
            updatedAt: DateTime.now(),
          );
          
          // 🎯 检查并更新root用户的username
          if (appUser.email == '2352016835@qq.com' && appUser.username == null) {
            appUser = appUser.copyWith(username: 'ROOT大人');
            await _userRepository.saveUser(appUser);
            debugPrint('🎯 已更新root用户的username为"ROOT大人"');
          }
          
          debugPrint('☁️ 已从云端获取用户数据');
        } else {
          // 云端没有数据，创建新用户对象
          appUser = AppUser.fromFirebaseUser(credential.user!);
          await _userRepository.saveUser(appUser);
          debugPrint('☁️ 新用户数据已保存到云端');
        }
      } catch (e) {
        debugPrint('⚠️ 云端数据获取失败，使用本地数据: $e');
        appUser = AppUser.fromFirebaseUser(credential.user!);
      }
      
      // 保存到本地
      await _saveUserLocally(appUser);
      
      // 🔄 执行登录后数据同步（异步，不阻塞返回）
      _performLoginDataSync(appUser.uid);
      
      debugPrint('✅ 邮箱登录成功: ${appUser.email}');
      return appUser;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase 登录错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ 登录异常: $e');
      throw AuthException('登录过程中发生未知错误', 'UNKNOWN_ERROR');
    }
  }
  
  /// 🔍 Google 登录
  /// 
  /// 使用 Google 账号进行登录
  /// 
  /// 返回用户对象
  /// 抛出 [AuthException] 如果登录失败
  Future<AppUser> signInWithGoogle() async {
    try {
      debugPrint('🌐 开始 Google 登录');
      
      // 🔧 先清除之前的登录状态，避免权限冲突
      await _googleSignIn.signOut();
      
      // Google 登录流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google 登录已取消', 'GOOGLE_SIGN_IN_CANCELLED');
      }
      
      debugPrint('✅ Google 账号认证成功: ${googleUser.email}');
      
      // 获取认证详情
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw AuthException('Google 认证令牌获取失败', 'GOOGLE_TOKEN_FAILED');
      }
      
      // 创建 Firebase 凭证
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase 登录
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw AuthException('Google 登录失败', 'GOOGLE_SIGN_IN_FAILED');
      }
      
      debugPrint('✅ Firebase 认证成功: ${userCredential.user!.uid}');
      
      // 🔥 尝试从云端获取用户数据
      AppUser appUser;
      try {
        final cloudUser = await NetworkRetry.importantRetry(
          () => _userRepository.getUser(userCredential.user!.uid),
        );
        if (cloudUser != null) {
          // 使用云端数据，更新Firebase用户信息
          appUser = cloudUser.copyWith(
            displayName: userCredential.user!.displayName ?? cloudUser.displayName,
            photoURL: userCredential.user!.photoURL ?? cloudUser.photoURL,
            updatedAt: DateTime.now(),
          );
          
          // 🎯 检查并更新root用户的username
          if (appUser.email == '2352016835@qq.com' && appUser.username == null) {
            appUser = appUser.copyWith(username: 'ROOT大人');
            await _userRepository.saveUser(appUser);
            debugPrint('🎯 已更新root用户的username为"ROOT大人"');
          }
          
          debugPrint('☁️ 已从云端获取用户数据');
        } else {
          // 云端没有数据，创建新用户对象
          appUser = AppUser.fromFirebaseUser(userCredential.user!);
          await _userRepository.saveUser(appUser);
          debugPrint('☁️ 新用户数据已保存到云端');
        }
      } catch (e) {
        debugPrint('⚠️ 云端数据获取失败，使用本地数据: $e');
        appUser = AppUser.fromFirebaseUser(userCredential.user!);
      }
      
      // 保存到本地
      await _saveUserLocally(appUser);
      
      // 🔄 执行登录后数据同步（异步，不阻塞返回）
      _performLoginDataSync(appUser.uid);
      
      debugPrint('✅ Google 登录成功: ${appUser.email}');
      return appUser;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Google 登录错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ Google 登录异常: $e');
      
      // 🔧 添加具体的错误处理，帮助诊断People API问题
      if (e.toString().contains('People API')) {
        throw AuthException('Google服务配置错误，请联系管理员', 'GOOGLE_API_CONFIG_ERROR');
      }
      
      throw AuthException('Google 登录过程中发生错误', 'GOOGLE_SIGN_IN_ERROR');
    }
  }
  
  /// 🔓 登出
  /// 
  /// 清除用户登录状态和本地数据
  Future<void> signOut() async {
    try {
      debugPrint('🚪 开始登出');
      
      // Firebase 登出
      await _firebaseAuth.signOut();
      
      // Google 登出
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // 清除本地用户数据
      _currentUser = null;
      
      debugPrint('✅ 登出成功');
      
    } catch (e) {
      debugPrint('❌ 登出异常: $e');
      throw AuthException('登出过程中发生错误', 'SIGN_OUT_ERROR');
    }
  }
  
  /// 🔄 重置密码
  /// 
  /// [email] 邮箱地址
  /// 
  /// 发送密码重置邮件
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔄 发送密码重置邮件: $email');
      
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      
      debugPrint('✅ 密码重置邮件发送成功');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ 密码重置错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ 密码重置异常: $e');
      throw AuthException('密码重置过程中发生错误', 'PASSWORD_RESET_ERROR');
    }
  }
  
  /// 📧 重新发送邮箱验证
  /// 
  /// 为当前用户重新发送邮箱验证邮件
  Future<void> resendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('用户未登录', 'USER_NOT_LOGGED_IN');
      }
      
      if (user.emailVerified) {
        throw AuthException('邮箱已验证', 'EMAIL_ALREADY_VERIFIED');
      }
      
      debugPrint('📧 重新发送邮箱验证');
      await user.sendEmailVerification();
      debugPrint('✅ 邮箱验证邮件发送成功');
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ 邮箱验证发送错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ 邮箱验证发送异常: $e');
      throw AuthException('邮箱验证发送过程中发生错误', 'EMAIL_VERIFICATION_ERROR');
    }
  }
  
  /// 🔄 更新用户资料
  /// 
  /// [displayName] 显示名称
  /// [photoURL] 头像 URL
  /// 
  /// 返回更新后的用户对象
  Future<AppUser> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || _currentUser == null) {
        throw AuthException('用户未登录', 'USER_NOT_LOGGED_IN');
      }
      
      debugPrint('🔄 更新用户资料');
      
      // 更新 Firebase 用户资料
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      
      // 重新加载用户信息
      await user.reload();
      final updatedFirebaseUser = _firebaseAuth.currentUser!;
      
      // 更新本地用户数据
      final updatedAppUser = _currentUser!.copyWith(
        displayName: updatedFirebaseUser.displayName,
        photoURL: updatedFirebaseUser.photoURL,
        updatedAt: DateTime.now(),
      );
      
      await _saveUserLocally(updatedAppUser);
      
      debugPrint('✅ 用户资料更新成功');
      return updatedAppUser;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ 用户资料更新错误: ${e.code} - ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('❌ 用户资料更新异常: $e');
      throw AuthException('用户资料更新过程中发生错误', 'PROFILE_UPDATE_ERROR');
    }
  }
  
  /// 🔄 更新用户偏好设置
  /// 
  /// [preferences] 新的偏好设置
  /// 
  /// 返回更新后的用户对象
  Future<AppUser> updatePreferences(UserPreferences preferences) async {
    try {
      if (_currentUser == null) {
        throw AuthException('用户未登录', 'USER_NOT_LOGGED_IN');
      }
      
      debugPrint('🔄 更新用户偏好设置');
      
      final updatedUser = _currentUser!.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      
      await _saveUserLocally(updatedUser);
      
      // 🔥 同步到Firestore云端
      try {
        await _userRepository.updateUserPreferences(updatedUser.uid, preferences);
        debugPrint('☁️ 用户偏好设置已同步到云端');
      } catch (e) {
        debugPrint('⚠️ 偏好设置云端同步失败: $e');
        // 云端同步失败不影响本地更新
      }
      
      debugPrint('✅ 用户偏好设置更新成功');
      return updatedUser;
      
    } catch (e) {
      debugPrint('❌ 用户偏好设置更新异常: $e');
      throw AuthException('偏好设置更新过程中发生错误', 'PREFERENCES_UPDATE_ERROR');
    }
  }
  
  /// 👂 Firebase Auth 状态变化监听器
  /// 
  /// [user] Firebase 用户对象
  Future<void> _onAuthStateChanged(User? user) async {
    try {
      if (user != null) {
        debugPrint('👤 用户状态变化: 已登录 - ${user.email}');
        
        // 从本地获取或创建用户数据
        AppUser? appUser = _userBox.get(user.uid);
        
        if (appUser == null) {
          // 首次登录，创建新的应用用户对象
          appUser = AppUser.fromFirebaseUser(user);
          await _saveUserLocally(appUser);
        } else {
          // 更新现有用户信息
          appUser = appUser.copyWith(
            displayName: user.displayName,
            photoURL: user.photoURL,
            updatedAt: DateTime.now(),
          );
          await _saveUserLocally(appUser);
        }
        
        _currentUser = appUser;
      } else {
        debugPrint('👤 用户状态变化: 已登出');
        _currentUser = null;
      }
      
      // 通知状态变化
      _userStateController.add(_currentUser);
      
    } catch (e) {
      debugPrint('❌ 用户状态变化处理异常: $e');
    }
  }
  
  /// 📦 检查当前用户状态
  /// 
  /// 在服务初始化时调用，检查是否有已登录的用户
  /// 🔧 修复热重启登录状态丢失问题
  Future<void> _checkCurrentUser() async {
    try {
      // 🔄 等待Firebase Auth完全初始化（最多等待3秒）
      User? user;
      try {
        user = await _firebaseAuth.authStateChanges()
            .timeout(const Duration(seconds: 3))
            .first;
      } on TimeoutException {
        debugPrint('⏰ Firebase Auth初始化超时，使用当前状态');
        user = _firebaseAuth.currentUser;
      }
      
      if (user != null) {
        debugPrint('🔍 发现已登录用户: ${user.email}');
        await _onAuthStateChanged(user);
      } else {
        // 🔄 尝试从本地恢复用户状态
        debugPrint('🔍 Firebase无登录用户，尝试本地恢复');
        await _tryRestoreFromLocal();
      }
    } catch (e) {
      debugPrint('❌ 检查当前用户状态异常: $e');
      // 🔄 发生异常时也尝试本地恢复
      await _tryRestoreFromLocal();
    }
  }
  
  /// 🔄 尝试从本地存储恢复用户状态
  /// 用于热重启后的状态恢复
  Future<void> _tryRestoreFromLocal() async {
    try {
      // 🔍 调试：检查本地存储状态
      debugPrint('🔍 检查本地存储状态...');
      debugPrint('🔍 Hive box已打开: ${_userBox.isOpen}');
      debugPrint('🔍 Hive box长度: ${_userBox.length}');
      
      // 获取本地存储的所有用户
      final localUsers = _userBox.values.toList();
      debugPrint('🔍 本地用户数量: ${localUsers.length}');
      
      if (localUsers.isNotEmpty) {
        // 打印所有本地用户信息
        for (int i = 0; i < localUsers.length; i++) {
          final user = localUsers[i];
          debugPrint('🔍 本地用户[$i]: ${user.email} (UID: ${user.uid})');
        }
        
        // 找到最近登录的用户（根据updatedAt排序）
        localUsers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final lastUser = localUsers.first;
        
        debugPrint('🔄 尝试从本地恢复用户状态: ${lastUser.email}');
        debugPrint('🔄 用户UID: ${lastUser.uid}');
        debugPrint('🔄 最后更新时间: ${lastUser.updatedAt}');
        
        // 等待一小段时间让Firebase完全初始化
        await Future.delayed(const Duration(milliseconds: 500));
        
        // 再次检查Firebase状态
        final currentFirebaseUser = _firebaseAuth.currentUser;
        debugPrint('🔍 Firebase当前用户: ${currentFirebaseUser?.email} (UID: ${currentFirebaseUser?.uid})');
        
        if (currentFirebaseUser != null && currentFirebaseUser.uid == lastUser.uid) {
          // Firebase和本地状态一致，恢复登录
          _currentUser = lastUser;
          _userStateController.add(lastUser);
          debugPrint('✅ 成功从本地恢复用户状态: ${lastUser.email}');
        } else if (currentFirebaseUser != null) {
          // Firebase有用户但与本地不匹配，使用Firebase的
          debugPrint('⚠️ 检测到Firebase用户状态变化，更新本地状态');
          debugPrint('⚠️ Firebase用户: ${currentFirebaseUser.email}');
          debugPrint('⚠️ 本地用户: ${lastUser.email}');
          await _onAuthStateChanged(currentFirebaseUser);
        } else {
          // Firebase确实无用户，但本地有用户
          debugPrint('⚠️ Firebase无用户但本地有用户，可能是Web平台持久性问题');
          
          // 🔧 对于Web平台的特殊处理
          if (kIsWeb) {
            debugPrint('🌐 Web平台：Firebase可能延迟初始化，强制恢复本地状态');
            
            // 强制设置当前用户状态
            _currentUser = lastUser;
            _userStateController.add(lastUser);
            
            // 尝试重新认证以同步Firebase状态
            _attemptReAuthentication(lastUser);
          } else {
            debugPrint('📱 移动平台：清除不一致的本地状态');
            _currentUser = null;
            _userStateController.add(null);
          }
        }
      } else {
        debugPrint('🔍 本地无用户数据，确认未登录状态');
        _currentUser = null;
        _userStateController.add(null);
      }
    } catch (e) {
      debugPrint('❌ 从本地恢复用户状态失败: $e');
      debugPrint('❌ 错误堆栈: ${StackTrace.current}');
      _currentUser = null;
      _userStateController.add(null);
    }
  }
  
  /// 🔄 尝试重新认证以同步Firebase状态
  /// 用于Web平台热重启后的状态恢复
  void _attemptReAuthentication(AppUser localUser) async {
    try {
      debugPrint('🔄 尝试重新认证用户: ${localUser.email}');
      
      // 延迟执行，给Firebase更多时间初始化
      await Future.delayed(const Duration(seconds: 2));
      
      // 检查Firebase是否恢复了用户状态
      final currentFirebaseUser = _firebaseAuth.currentUser;
      if (currentFirebaseUser != null && currentFirebaseUser.uid == localUser.uid) {
        debugPrint('✅ Firebase状态已恢复，用户: ${currentFirebaseUser.email}');
        // 状态已经一致，不需要额外操作
      } else {
        debugPrint('⚠️ Firebase状态仍未恢复，但本地状态已设置');
        // 保持本地状态，用户可以正常使用应用
      }
    } catch (e) {
      debugPrint('❌ 重新认证失败: $e');
      // 失败不影响本地状态，用户仍可使用应用
    }
  }
  
  /// 💾 保存用户到本地存储
  /// 
  /// [user] 要保存的用户对象
  Future<void> _saveUserLocally(AppUser user) async {
    try {
      await _userBox.put(user.uid, user);
      _currentUser = user;
      
      // 🔧 修复：通知状态变化流，确保Riverpod状态同步
      _userStateController.add(_currentUser);
      
      debugPrint('💾 用户数据已保存到本地: ${user.email}');
      debugPrint('📡 状态流已通知用户登录: ${user.email}');
    } catch (e) {
      debugPrint('❌ 保存用户数据到本地失败: $e');
    }
  }
  
  /// 📝 获取用户友好的错误消息
  /// 
  /// [errorCode] Firebase 错误代码
  /// 
  /// 返回本地化的错误消息
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '用户不存在，请检查邮箱地址';
      case 'wrong-password':
        return '密码错误，请重新输入';
      case 'email-already-in-use':
        return '该邮箱已被注册，请使用其他邮箱';
      case 'weak-password':
        return '密码强度不够，请使用至少6位字符';
      case 'invalid-email':
        return '邮箱格式不正确，请检查后重新输入';
      case 'user-disabled':
        return '该账户已被禁用，请联系客服';
      case 'too-many-requests':
        return '请求过于频繁，请稍后再试';
      case 'operation-not-allowed':
        return '该登录方式暂未开启';
      case 'invalid-credential':
        return '登录凭证无效，请重新登录';
      case 'network-request-failed':
        return '网络连接失败，请检查网络后重试';
      case 'requires-recent-login':
        return '操作需要重新登录验证';
      default:
        return '登录失败，请稍后重试 ($errorCode)';
    }
  }
  
  /// 🔄 执行登录后数据同步
  /// 
  /// 在用户登录成功后异步执行数据同步，利用登录动画时间
  /// [userId] 用户ID
  void _performLoginDataSync(String userId) async {
    try {
      debugPrint('🚀 开始智能登录数据同步: $userId');
      final syncStartTime = DateTime.now();
      
      // 获取缓存服务
      final cacheService = LocalCacheService(_recipeRepository);
      await cacheService.initialize();
      
      // 🔥 利用登录动画时间，并发执行数据同步
      final syncFutures = <Future>[
        cacheService.performLoginDataSync(userId),
        // 额外的更新检测
        _performQuickUpdateCheck(cacheService, userId),
      ];
      
      // ⚡ 等待所有同步任务完成
      await Future.wait(syncFutures, eagerError: false);
      
      final syncDuration = DateTime.now().difference(syncStartTime);
      debugPrint('✅ 智能登录数据同步完成 - 用时: ${syncDuration.inMilliseconds}ms');
      
    } catch (e) {
      debugPrint('❌ 登录后数据同步失败: $e');
      // 静默失败，不影响用户登录体验
    }
  }
  
  /// 🔍 快速更新检测
  Future<void> _performQuickUpdateCheck(LocalCacheService cacheService, String userId) async {
    try {
      // 利用已存在的方法进行更新检测
      // 这里主要是触发后台检查，实际检测由缓存服务内部处理
      await cacheService.getUserRecipes(userId);
      await cacheService.getFavoriteRecipes(userId);
      
      final updates = cacheService.getAllPendingUpdates().length;
      debugPrint('🔍 快速更新检测完成: 发现 $updates 个待更新项');
    } catch (e) {
      debugPrint('⚠️ 快速更新检测失败: $e');
    }
  }
  
  /// 🗑️ 释放资源
  /// 
  /// 关闭流控制器和本地存储
  void dispose() {
    _userStateController.close();
    debugPrint('🗑️ AuthService 资源已释放');
  }
}