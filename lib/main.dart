import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/performance_monitor.dart';
import 'features/recipe/domain/models/recipe.dart';
import 'features/recipe/data/repositories/recipe_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive本地存储
  await Hive.initFlutter();
  
  // 🔧 注册Hive适配器（修复数据库保存bug）
  Hive.registerAdapter(RecipeAdapter());
  Hive.registerAdapter(RecipeStepAdapter());
  
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
  
  // 创建ProviderContainer并预先初始化Repository
  final container = ProviderContainer();
  
  // 🔧 关键修复：预先初始化Repository，避免LateInitializationError
  try {
    await container.read(initializedRecipeRepositoryProvider.future);
    print('✅ RecipeRepository 初始化成功');
  } catch (e) {
    print('❌ RecipeRepository 初始化失败: $e');
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
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: '爱心食谱',
      debugShowCheckedModeBanner: false,
      
      // 主题配置 - 严格遵循95%黑白灰原则
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // 路由配置
      routerConfig: router,
      
      // 字体配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // 固定文字缩放，保持设计一致性
          ),
          child: child!,
        );
      },
    );
  }
}