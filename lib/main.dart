import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive本地存储
  await Hive.initFlutter();
  
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
  
  runApp(
    const ProviderScope(
      child: LoveRecipeApp(),
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