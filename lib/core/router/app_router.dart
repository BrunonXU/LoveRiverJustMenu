import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../../features/profile/presentation/pages/personal_space_screen.dart';
import '../../features/profile/presentation/pages/my_recipes_screen.dart';
import '../../features/taste_circle/presentation/pages/create_or_join_screen.dart';
import '../../features/taste_circle/presentation/pages/create_circle_screen.dart';
import '../../features/achievement/presentation/pages/achievement_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';
import '../../features/food_map/presentation/pages/food_map_screen.dart';
import '../../features/food_map/presentation/pages/province_detail_screen.dart';
import '../../features/food_map/domain/models/province_cuisine.dart';
import '../../features/intimacy/presentation/pages/intimacy_screen.dart';
import '../../features/profile/presentation/pages/settings_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/login_methods_screen.dart';
import '../../features/auth/presentation/pages/register_methods_screen.dart';
import '../../features/food_journal/presentation/pages/food_journal_screen.dart';
import '../animations/liquid_transition.dart';
import '../auth/providers/auth_providers.dart';

/// 路由配置提供者
/// 
/// 提供带有认证守卫的路由配置实例
/// 根据用户登录状态自动重定向到相应页面
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter._createRouter(ref);
});

/// 应用路由配置
/// 基于go_router实现声明式路由管理
class AppRouter {
  // ==================== 路由路径常量 ====================
  
  // 认证相关路由
  static const String welcome = '/welcome';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  
  // 应用主要路由
  static const String home = '/home';
  static const String timeline = '/timeline';
  static const String foodJournal = '/food-journal';
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
  static const String personalSpace = '/personal-space';
  static const String myRecipes = '/personal-center/my-recipes';
  static const String achievements = '/personal-center/achievements';
  static const String foodMap = '/food-map';
  static const String provinceDetail = '/food-map/province/:provinceId';
  static const String intimacy = '/intimacy';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // 味道圈相关路由
  static const String tasteCircles = '/taste-circles';
  static const String createOrJoinCircle = '/taste-circles/create-or-join';
  static const String createCircle = '/taste-circles/create';
  static const String joinCircle = '/taste-circles/join';
  static const String tasteCircleAchievements = '/taste-circles/achievements';
  static const String tasteCircleDetail = '/taste-circles/:circleId';
  
  // 个人中心子页面路由
  static const String favorites = '/personal-center/favorites';
  static const String learningProgress = '/personal-center/learning-progress';
  static const String analytics = '/personal-center/analytics';
  
  // ==================== 路由配置 ====================
  
  /// 🔐 创建带有认证守卫的路由器
  /// 
  /// [ref] Riverpod 引用，用于访问认证状态
  /// 返回配置完成的 GoRouter 实例
  static GoRouter _createRouter(Ref ref) {
    return GoRouter(
      // 初始路由 - 欢迎页面优先，支持游客和登录模式
      initialLocation: welcome,
      
      // 调试日志
      debugLogDiagnostics: true,
      
      // 错误处理
      errorBuilder: (context, state) => _ErrorScreen(error: state.error),
      
      // 🛡️ 路由重定向逻辑 - 认证守卫（支持游客模式）
      redirect: (context, state) {
        try {
          // 安全地获取当前用户状态
          final authState = ref.read(authStateProvider);
          
          // 当前访问的路径
          final currentPath = state.uri.toString();
          
          // 认证相关路径（无需登录即可访问）
          final authPaths = [welcome, login, register];
          
          // 🎯 游客模式支持 - 允许访问主页和其他功能页面
          final guestAllowedPaths = [
            home, 
            timeline,
            foodJournal,
            aiRecommendation, 
            search,
            personalSpace,
            personalCenter,
            myRecipes,
            favorites,
            achievements,
            learningProgress,
            analytics,
            tasteCircles,
            createOrJoinCircle,
            createCircle,
            joinCircle,
            tasteCircleAchievements,
            tasteCircleDetail,
            settings,
            foodMap,
            challenge,
            intimacy,
            cookingMode,
            recipeDetail,
            createRecipe,
            coupleBinding,
            coupleProfile,
            challengeSend,
            challengeDetail,
            memoryDetail,
            provinceDetail,
          ];
          
          // 🔧 修复：处理认证状态的各种情况
          return authState.when(
            // 用户已登录
            data: (user) {
              final isLoggedIn = user != null;
              
              // 如果用户已登录且在认证相关页面，重定向到主页
              if (isLoggedIn && (authPaths.contains(currentPath) || currentPath.startsWith('/auth/'))) {
                return home;
              }
              
              // 如果访问根路径 "/" 重定向到欢迎页面或主页
              if (currentPath == '/') {
                return isLoggedIn ? home : welcome;
              }
              
              // 如果用户未登录且不在认证相关页面，检查是否是游客允许的页面
              if (!isLoggedIn && !authPaths.contains(currentPath) && !currentPath.startsWith('/auth/')) {
                // 🎮 游客模式：允许访问主要功能页面
                // 检查当前路径是否匹配允许的路径（支持动态路由）
                bool isPathAllowed = false;
                for (final allowedPath in guestAllowedPaths) {
                  if (currentPath == allowedPath || 
                      currentPath.startsWith('${allowedPath}/') ||
                      _matchesDynamicRoute(currentPath, allowedPath)) {
                    isPathAllowed = true;
                    break;
                  }
                }
                
                if (isPathAllowed) {
                  return null; // 🎯 允许游客访问
                }
                return welcome; // 其他页面需要登录
              }
              
              return null; // 其他情况不重定向
            },
            // 认证状态加载中 - 不要重定向，让页面先渲染
            loading: () {
              debugPrint('🔄 认证状态加载中，允许访问当前路径: $currentPath');
              return null; // 🔧 关键修复：加载时不重定向
            },
            // 认证出错 - 只有在不是游客允许的页面时才重定向
            error: (error, stackTrace) {
              debugPrint('❌ 认证状态获取失败: $error');
              
              // 如果在认证相关页面，允许继续访问
              if (authPaths.contains(currentPath) || currentPath.startsWith('/auth/')) {
                return null;
              }
              
              // 检查是否是游客允许访问的页面
              bool isGuestAllowed = false;
              for (final allowedPath in guestAllowedPaths) {
                if (currentPath == allowedPath || 
                    currentPath.startsWith('${allowedPath}/') ||
                    _matchesDynamicRoute(currentPath, allowedPath)) {
                  isGuestAllowed = true;
                  break;
                }
              }
              
              if (isGuestAllowed) {
                debugPrint('🎮 认证失败但允许游客访问: $currentPath');
                return null; // 🔧 关键修复：允许游客模式
              }
              
              return welcome; // 其他情况回到欢迎页面
            },
          );
          
        } catch (e) {
          // 最后的异常处理 - 允许游客模式
          debugPrint('⚠️ 路由重定向时发生异常: $e');
          final currentPath = state.uri.toString();
          
          // 认证相关路径直接放行
          final authPaths = [welcome, login, register];
          if (authPaths.contains(currentPath) || currentPath.startsWith('/auth/')) {
            return null;
          }
          
          // 游客模式页面也放行
          final guestPaths = [home, timeline, foodJournal, aiRecommendation];
          for (final path in guestPaths) {
            if (currentPath == path) {
              debugPrint('🎮 异常情况下允许游客访问: $currentPath');
              return null;
            }
          }
          
          return welcome;
        }
      },
      
      // 路由定义
      routes: [
        // ==================== 认证相关路由 ====================
        
        // 欢迎页面路由
        GoRoute(
          path: welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
          pageBuilder: (context, state) => _buildPageTransition(
            child: const WelcomeScreen(),
            state: state,
            transitionType: PageTransitionType.fade,
          ),
        ),
        
        // 登录页面路由
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginMethodsScreen(),
          pageBuilder: (context, state) => _buildPageTransition(
            child: const LoginMethodsScreen(),
            state: state,
            transitionType: PageTransitionType.slideUp,
          ),
        ),
        
        // 注册页面路由
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterMethodsScreen(),
          pageBuilder: (context, state) => _buildPageTransition(
            child: const RegisterMethodsScreen(),
            state: state,
            transitionType: PageTransitionType.slideUp,
          ),
        ),
        
        // ==================== 应用主要路由 ====================
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
          transitionType: PageTransitionType.fade,
        ),
      ),
      
      // 美食日记路由 - 📖 翻页日记本设计
      GoRoute(
        path: foodJournal,
        name: 'food-journal',
        builder: (context, state) => const FoodJournalScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const FoodJournalScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // AI推荐路由 - 🤖 时间驱动界面+情境卡片+语音交互
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
      
      // 烹饪模式路由 - 🎨 使用极简大图版本
      GoRoute(
        path: cookingMode,
        name: 'cooking-mode',
        builder: (context, state) {
          final recipeId = state.uri.queryParameters['recipeId'] ?? 'recipe_1';
          return CookingModeScreen(recipeId: recipeId);
        },
        pageBuilder: (context, state) {
          final recipeId = state.uri.queryParameters['recipeId'] ?? 'recipe_1';
          return _buildPageTransition(
            child: CookingModeScreen(recipeId: recipeId),
            state: state,
            transitionType: PageTransitionType.slideRight,
          );
        },
      ),
      
      // 菜谱详情路由 - 🎨 使用新的极简设计版本
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
      
      // 创建菜谱路由 - 🎨 极简设计版本，支持编辑模式
      GoRoute(
        path: createRecipe,
        name: 'create-recipe',
        builder: (context, state) {
          final editId = state.uri.queryParameters['editId'];
          return CreateRecipeScreen(editId: editId);
        },
        pageBuilder: (context, state) {
          final editId = state.uri.queryParameters['editId'];
          return _buildPageTransition(
            child: CreateRecipeScreen(editId: editId),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
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

      // 个人空间路由（新）
      GoRoute(
        path: personalSpace,
        name: 'personal-space',
        builder: (context, state) => const PersonalSpaceScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PersonalSpaceScreen(),
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

      // 成就系统路由 - 🔧 性能优化版本
      GoRoute(
        path: achievements,
        name: 'achievements',
        builder: (context, state) => const AchievementScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const AchievementScreen(),
          state: state,
          transitionType: PageTransitionType.fade, // 🔧 简化过渡动画
        ),
      ),

      // 美食地图路由 - 🔧 性能优化版本
      GoRoute(
        path: foodMap,
        name: 'food-map',
        builder: (context, state) => const FoodMapScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const FoodMapScreen(),
          state: state,
          transitionType: PageTransitionType.fade, // 🔧 简化过渡动画  
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

      // 亲密度系统路由 ⭐ 新功能
      GoRoute(
        path: intimacy,
        name: 'intimacy',
        builder: (context, state) => const IntimacyScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const IntimacyScreen(),
          state: state,
          transitionType: PageTransitionType.fade,
        ),
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
          transitionType: PageTransitionType.fade,
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
      
      // ==================== 味道圈相关路由 ====================
      
      // 我的味道圈
      GoRoute(
        path: tasteCircles,
        name: 'taste-circles',
        builder: (context, state) => const PlaceholderScreen(
          title: '我的味道圈',
          subtitle: '味道圈功能正在开发中...',
          icon: Icons.group,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '我的味道圈',
            subtitle: '味道圈功能正在开发中...',
            icon: Icons.group,
          ),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
      
      // 创建或加入味道圈
      GoRoute(
        path: createOrJoinCircle,
        name: 'create-or-join-circle',
        builder: (context, state) => const CreateOrJoinScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CreateOrJoinScreen(),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 创建味道圈
      GoRoute(
        path: createCircle,
        name: 'create-circle',
        builder: (context, state) => const CreateCircleScreen(),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const CreateCircleScreen(),
          state: state,
          transitionType: PageTransitionType.slideRight,
        ),
      ),
      
      // 加入味道圈
      GoRoute(
        path: joinCircle,
        name: 'join-circle',
        builder: (context, state) => const PlaceholderScreen(
          title: '输入邀请码',
          subtitle: '加入味道圈功能正在开发中...',
          icon: Icons.vpn_key,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '输入邀请码',
            subtitle: '加入味道圈功能正在开发中...',
            icon: Icons.vpn_key,
          ),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 味道圈详情
      GoRoute(
        path: tasteCircleDetail,
        name: 'taste-circle-detail',
        builder: (context, state) {
          final circleId = state.pathParameters['circleId']!;
          return PlaceholderScreen(
            title: '味道圈详情',
            subtitle: '圈子「$circleId」的详情页面正在开发中...',
            icon: Icons.group,
          );
        },
        pageBuilder: (context, state) {
          final circleId = state.pathParameters['circleId']!;
          return _buildPageTransition(
            child: PlaceholderScreen(
              title: '味道圈详情',
              subtitle: '圈子「$circleId」的详情页面正在开发中...',
              icon: Icons.group,
            ),
            state: state,
            transitionType: PageTransitionType.slideUp,
          );
        },
      ),
      
      // 味道圈成就
      GoRoute(
        path: tasteCircleAchievements,
        name: 'taste-circle-achievements',
        builder: (context, state) => const PlaceholderScreen(
          title: '圈子成就',
          subtitle: '味道圈成就系统正在开发中...',
          icon: Icons.emoji_events,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '圈子成就',
            subtitle: '味道圈成就系统正在开发中...',
            icon: Icons.emoji_events,
          ),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 我的收藏
      GoRoute(
        path: favorites,
        name: 'favorites',
        builder: (context, state) => const PlaceholderScreen(
          title: '我的收藏',
          subtitle: '收藏功能正在开发中...',
          icon: Icons.favorite_border,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '我的收藏',
            subtitle: '收藏功能正在开发中...',
            icon: Icons.favorite_border,
          ),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 学习历程
      GoRoute(
        path: learningProgress,
        name: 'learning-progress',
        builder: (context, state) => const PlaceholderScreen(
          title: '学习历程',
          subtitle: '学习历程功能正在开发中...',
          icon: Icons.trending_up,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '学习历程',
            subtitle: '学习历程功能正在开发中...',
            icon: Icons.trending_up,
          ),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
      
      // 数据分析
      GoRoute(
        path: analytics,
        name: 'analytics',
        builder: (context, state) => const PlaceholderScreen(
          title: '数据分析',
          subtitle: '数据分析功能正在开发中...',
          icon: Icons.analytics,
        ),
        pageBuilder: (context, state) => _buildPageTransition(
          child: const PlaceholderScreen(
            title: '数据分析',
            subtitle: '数据分析功能正在开发中...',
            icon: Icons.analytics,
          ),
          state: state,
          transitionType: PageTransitionType.slideUp,
        ),
      ),
    ],
    );
  }
  
  /// 匹配动态路由
  static bool _matchesDynamicRoute(String currentPath, String routePattern) {
    // 处理动态路由，如 /taste-circles/:circleId
    if (routePattern.contains(':')) {
      final patternParts = routePattern.split('/');
      final currentParts = currentPath.split('/');
      
      if (patternParts.length != currentParts.length) {
        return false;
      }
      
      for (int i = 0; i < patternParts.length; i++) {
        if (patternParts[i].startsWith(':')) {
          // 动态参数，跳过检查
          continue;
        } else if (patternParts[i] != currentParts[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
  
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

// SettingsScreen已从 features/profile/presentation/pages/settings_screen.dart 导入