import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/pages/main_screen.dart';
import '../../features/timeline/presentation/pages/timeline_screen.dart';
import '../../features/ai_recommendation/presentation/pages/ai_recommendation_screen.dart';
import '../../features/cooking_mode/presentation/pages/cooking_mode_screen.dart';
import '../../features/recipe/presentation/pages/recipe_detail_screen.dart';
import '../../features/recipe/presentation/pages/create_recipe_screen.dart';
import '../../features/search/presentation/pages/search_screen.dart';
import '../../features/couple/presentation/pages/couple_binding_screen.dart';
import '../../features/couple/presentation/pages/couple_profile_screen.dart';
import '../../features/challenge/presentation/pages/challenge_screen.dart';
import '../../features/challenge/presentation/pages/send_challenge_screen.dart';
import '../../features/challenge/presentation/pages/challenge_detail_screen.dart';
import '../../features/timeline/presentation/pages/memory_detail_screen.dart';
import '../../features/timeline/domain/models/memory.dart';
import '../../features/challenge/domain/models/challenge.dart';
import '../../features/profile/presentation/pages/personal_center_screen.dart';
import '../../features/profile/presentation/pages/my_recipes_screen.dart';
import '../../features/achievement/presentation/pages/achievement_screen.dart';
import '../../features/food_map/presentation/pages/food_map_screen.dart';
import '../../features/food_map/presentation/pages/province_detail_screen.dart';
import '../../features/food_map/domain/models/province_cuisine.dart';
import '../animations/liquid_transition.dart';

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
  static const String search = '/search';
  static const String coupleBinding = '/couple/binding';
  static const String coupleProfile = '/couple/profile';
  static const String challenge = '/challenge';
  static const String challengeSend = '/challenge/send';
  static const String challengeDetail = '/challenge/:id';
  static const String memoryDetail = '/memory/:id';
  static const String personalCenter = '/personal-center';
  static const String myRecipes = '/personal-center/my-recipes';
  static const String achievements = '/personal-center/achievements';
  static const String foodMap = '/food-map';
  static const String provinceDetail = '/food-map/province/:provinceId';
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
          transitionType: PageTransitionType.liquid,
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
          transitionType: PageTransitionType.liquid,
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
      
      // 搜索页面路由
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const SearchScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 情侣绑定路由
      GoRoute(
        path: coupleBinding,
        name: 'couple-binding',
        builder: (context, state) => const CoupleBindingScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CoupleBindingScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 情侣档案路由
      GoRoute(
        path: coupleProfile,
        name: 'couple-profile',
        builder: (context, state) => const CoupleProfileScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CoupleProfileScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
      
      // 个人中心路由
      GoRoute(
        path: personalCenter,
        name: 'personal-center',
        builder: (context, state) => const PersonalCenterScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PersonalCenterScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),

      // 我的菜谱路由
      GoRoute(
        path: myRecipes,
        name: 'my-recipes',
        builder: (context, state) => const MyRecipesScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const MyRecipesScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),

      // 成就系统路由
      GoRoute(
        path: achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const AchievementScreen(),
          state: state,
          transitionType: PageTransitionType.liquid,
        ),
      ),

      // 美食地图路由
      GoRoute(
        path: foodMap,
        name: 'food-map',
        builder: (context, state) => const FoodMapScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const FoodMapScreen(),
          state: state,
          transitionType: PageTransitionType.liquid,
        ),
      ),

      // 省份详情路由
      GoRoute(
        path: provinceDetail,
        name: 'province-detail',
        builder: (context, state) {
          final provinceIdStr = state.pathParameters['provinceId']!;
          final province = _getProvinceFromString(provinceIdStr);
          return ProvinceDetailScreen(province: province);
        },
        pageBuilder: (context, state) {
          final provinceIdStr = state.pathParameters['provinceId']!;
          final province = _getProvinceFromString(provinceIdStr);
          return _buildPageTransition(
            child: ProvinceDetailScreen(province: province),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
      ),

      // 个人档案路由（保留兼容性）
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
      
      // 挑战系统路由
      GoRoute(
        path: challenge,
        name: 'challenge',
        builder: (context, state) => const ChallengeScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const ChallengeScreen(),
          state: state,
          transitionType: PageTransitionType.liquid,
        ),
      ),
      
      // 发送挑战路由
      GoRoute(
        path: challengeSend,
        name: 'challenge-send',
        builder: (context, state) => const SendChallengeScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const SendChallengeScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 挑战详情路由
      GoRoute(
        path: challengeDetail,
        name: 'challenge-detail',
        builder: (context, state) {
          final challengeId = state.pathParameters['id']!;
          return ChallengeDetailScreen(
            challenge: _getChallengeById(challengeId),
          );
        },
        pageBuilder: (context, state) {
          final challengeId = state.pathParameters['id']!;
          return _buildPageTransition(
            child: ChallengeDetailScreen(
              challenge: _getChallengeById(challengeId),
            ),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
      ),
      
      // 记忆详情路由
      GoRoute(
        path: memoryDetail,
        name: 'memory-detail',
        builder: (context, state) {
          final memoryId = state.pathParameters['id']!;
          // 这里需要根据ID获取Memory对象，暂时使用示例数据
          return MemoryDetailScreen(
            memory: _getMemoryById(memoryId),
          );
        },
        pageBuilder: (context, state) {
          final memoryId = state.pathParameters['id']!;
          return _buildPageTransition(
            child: MemoryDetailScreen(
              memory: _getMemoryById(memoryId),
            ),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
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
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 800),
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
        return LiquidTransitionBuilder(
          animation: animation,
          child: child,
          transitionType: LiquidTransitionType.wave,
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

// ==================== 辅助方法 ====================

/// 根据ID获取Memory对象的辅助方法
/// 在实际应用中，这应该从数据层获取
Memory _getMemoryById(String memoryId) {
  // 示例数据 - 实际应用中应该从Provider或Repository获取
  return Memory(
    id: memoryId,
    title: '经典银耳莲子羹',
    emoji: '🥣',
    mood: '温馨',
    date: DateTime.now().subtract(const Duration(days: 3)),
    description: '第一次为她做的养生甜品',
    story: '那天她说想要养颜的甜品，我就想到了妈妈经常做的银耳莲子羹。虽然是第一次做，但看到她满足的表情，觉得一切都值得了。',
    cookId: 'user1',
    cookingTime: 45,
    difficulty: 2,
    special: true,
  );
}

/// 根据ID获取Challenge对象的辅助方法
/// 在实际应用中，这应该从数据层获取
Challenge _getChallengeById(String challengeId) {
  // 示例数据 - 实际应用中应该从Provider或Repository获取
  return Challenge(
    id: challengeId,
    recipeId: 'recipe_1',
    recipeName: '银耳莲子羹',
    recipeIcon: '🥣',
    senderId: 'user1',
    receiverId: 'user2',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: ChallengeStatus.pending,
    message: '想看你做这道养生甜品~',
    difficulty: 2,
    estimatedTime: 45,
  );
}

/// 根据字符串获取省份枚举的辅助方法
ChineseProvince _getProvinceFromString(String provinceStr) {
  switch (provinceStr.toLowerCase()) {
    case 'sichuan': return ChineseProvince.sichuan;
    case 'guangdong': return ChineseProvince.guangdong;
    case 'beijing': return ChineseProvince.beijing;
    case 'shanghai': return ChineseProvince.shanghai;
    case 'jiangsu': return ChineseProvince.jiangsu;
    case 'zhejiang': return ChineseProvince.zhejiang;
    case 'fujian': return ChineseProvince.fujian;
    case 'hunan': return ChineseProvince.hunan;
    case 'shandong': return ChineseProvince.shandong;
    case 'anhui': return ChineseProvince.anhui;
    case 'xinjiang': return ChineseProvince.xinjiang;
    case 'yunnan': return ChineseProvince.yunnan;
    case 'xizang': return ChineseProvince.xizang;
    default: return ChineseProvince.sichuan;
  }
}

// ==================== 临时占位页面 ====================
// 这些页面将在后续任务中实现

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