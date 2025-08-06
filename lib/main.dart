import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/performance_monitor.dart';
import 'features/recipe/domain/models/recipe.dart';
import 'core/auth/models/app_user.dart';
import 'core/models/recipe_update_info.dart';
import 'core/auth/providers/auth_providers.dart';
import 'core/firestore/providers/firestore_providers.dart';
import 'core/services/providers/new_user_providers.dart';
import 'core/animations/breathing_manager.dart';
import 'core/animations/performance_mode.dart';
import 'core/performance/frame_budget_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 🔥 初始化Firebase - 支持多平台自动配置
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase 初始化成功');
  } catch (e) {
    debugPrint('❌ Firebase 初始化失败: $e');
    // 认证服务初始化失败时，应用会降级到游客模式
    // 用户仍可使用本地存储功能，只是无法享受云端同步
  }
  
  // 初始化Hive本地存储
  await Hive.initFlutter();
  
  // 🔧 注册Hive适配器（修复数据库保存bug）
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  Hive.registerAdapter(UserFavoritesAdapter());
  
  // 🔐 注册认证系统相关的Hive适配器
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());
  Hive.registerAdapter(CoupleBindingAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  
  // 🔄 注册更新系统相关的Hive适配器
  Hive.registerAdapter(RecipeUpdateInfoAdapter());
  Hive.registerAdapter(UpdateImportanceAdapter());
  
  // 设置系统UI样式 - 遵循极简设计
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 性能监控 - 企业级要求
  if (kDebugMode) {
    PerformanceMonitor.init();
  }
  
  // 🚀 初始化性能模式管理器
  PerformanceModeManager.instance.autoDetectPerformanceMode();
  
  // 🎯 初始化帧预算管理器 - 仅在调试模式下启用
  if (kDebugMode) {
    FrameBudgetManager.instance.setTargetFps(120);
  }
  
  // 创建ProviderContainer
  final container = ProviderContainer();
  
  // 🔧 关键修复：预先初始化Repository，避免LateInitializationError
  try {
    // 初始化Firestore服务，确保在使用前已连接
    final firestoreInstance = container.read(firestoreProvider);
    debugPrint('✅ FirebaseFirestore 实例初始化成功');
    
    // 初始化Recipe Repository
    final recipeRepo = container.read(recipeRepositoryProvider);
    debugPrint('✅ RecipeRepository 初始化成功');
  } catch (e) {
    debugPrint('❌ RecipeRepository 初始化失败: $e');
  }
  
  // 🔐 预先初始化认证服务 + 认证操作Provider
  try {
    await container.read(initializedAuthServiceProvider.future);
    debugPrint('✅ AuthService 初始化成功');
    
    // 🎯 关键修复：预初始化认证操作Provider，避免页面访问时的时机冲突
    final authActions = container.read(authActionsProvider.notifier);
    debugPrint('✅ AuthActionsProvider 预初始化完成 - 用户可立即使用登录功能');
    
  } catch (e) {
    debugPrint('❌ 认证系统初始化失败: $e');
    // 认证服务初始化失败不应该阻止应用启动，用户可以使用游客模式
  }
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LoveRecipeApp(),
    ),
  );
}

class LoveRecipeApp extends ConsumerWidget {
  const LoveRecipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    
    // 🚀 初始化新用户自动初始化监听器
    ref.watch(newUserAutoInitializerProvider);
    
    return BreathingManagerInitializer(
      child: MaterialApp.router(
        title: '爱心食谱',
        debugShowCheckedModeBanner: false,
        
        // 主题配置 - 严格遵循95%黑白灰原则
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // 路由配置
        routerConfig: appRouter,
        
        // 字体配置
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // 固定文字缩放，保持设计一致性
            ),
            child: child!,
          );
        },
      ),
    );
  }
}