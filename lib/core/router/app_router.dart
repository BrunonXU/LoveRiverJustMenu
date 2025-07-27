import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/pages/main_screen.dart';
import '../../features/timeline/presentation/pages/timeline_screen.dart';
import '../../features/ai_recommendation/presentation/pages/ai_recommendation_screen.dart';
import '../../features/cooking_mode/presentation/pages/cooking_mode_screen.dart';

/// 路由配置提供者
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// 应用路由配置
/// 基于go_router实现声明式路由管理
class AppRouter {
  // ==================== 路由路径常量 ====================
  
  static const String home = '/';
  static const String timeline = '/timeline';
  static const String aiRecommendation = '/ai-recommendation';
  static const String cookingMode = '/cooking-mode';
  static const String recipeDetail = '/recipe/:id';
  static const String createRecipe = '/create-recipe';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // ==================== 路由配置 ====================
  
  static final GoRouter router = GoRouter(
    // 初始路由
    initialLocation: home,
    
    // 调试日志
    debugLogDiagnostics: true,
    
    // 错误处理
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
    
    // 路由定义
    routes: [
      // 主页路由
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const MainScreen(),
          state: state,
        ),
      ),
      
      // 3D时光机路由
      GoRoute(
        path: timeline,
        name: 'timeline',
        builder: (context, state) => const TimelineScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const TimelineScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // AI推荐路由
      GoRoute(
        path: aiRecommendation,
        name: 'ai-recommendation',
        builder: (context, state) => const AiRecommendationScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const AiRecommendationScreen(),
          state: state,
          transitionType: PageTransitionType.fade,
        ),
      ),
      
      // 烹饪模式路由
      GoRoute(
        path: cookingMode,
        name: 'cooking-mode',
        builder: (context, state) => const CookingModeScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CookingModeScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
      
      // 菜谱详情路由
      GoRoute(
        path: recipeDetail,
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeDetailScreen(recipeId: recipeId);
        },
        pageBuilder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return _buildPageTransition(
            child: RecipeDetailScreen(recipeId: recipeId),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
      ),
      
      // 创建菜谱路由
      GoRoute(
        path: createRecipe,
        name: 'create-recipe',
        builder: (context, state) => const CreateRecipeScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CreateRecipeScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 个人中心路由
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const ProfileScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
      
      // 设置页面路由
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const SettingsScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
    ],
  );
  
  // ==================== 页面过渡动画 ====================
  
  /// 构建页面过渡动画
  static CustomTransitionPage _buildPageTransition({
    required Widget child,
    required GoRouterState state,
    PageTransitionType transitionType = PageTransitionType.fade,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _getTransition(
          transitionType: transitionType,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 600),
    );
  }
  
  /// 获取过渡动画
  static Widget _getTransition({
    required PageTransitionType transitionType,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    switch (transitionType) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
        
      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
          child: child,
        );
        
      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
          child: child,
        );
        
      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
          child: child,
        );
        
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: CurveTween(curve: Curves.easeOutCubic).animate(animation),
          child: child,
        );
        
      case PageTransitionType.liquid:
        // 液态过渡效果 - 高级动画
        return _LiquidTransition(
          animation: animation,
          child: child,
        );
    }
  }
}

/// 页面过渡类型枚举
enum PageTransitionType {
  fade,
  slideUp,
  slideRight,
  slideDown,
  scale,
  liquid,
}

/// 错误页面
class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 24),
            const Text(
              '页面走丢了',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '未知错误',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 液态过渡动画组件
class _LiquidTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  
  const _LiquidTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipPath(
          clipper: _LiquidClipper(animation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// 液态裁剪器
class _LiquidClipper extends CustomClipper<Path> {
  final double progress;
  
  _LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 50.0 * (1 - progress);
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * (1 - progress) + 
                (waveHeight * 0.5) * (1 + 
                (x / size.width) * 2 * 3.14159);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper oldClipper) => progress != oldClipper.progress;
}

// ==================== 临时占位页面 ====================
// 这些页面将在后续任务中实现

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('菜谱详情 $recipeId')),
      body: const Center(child: Text('菜谱详情页面')),
    );
  }
}

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建菜谱')),
      body: const Center(child: Text('创建菜谱页面')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: const Center(child: Text('个人中心页面')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(child: Text('设置页面')),
    );
  }
}