import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../../../../core/firestore/repositories/recipe_repository.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/services/providers/favorites_providers.dart';
import '../../../../core/utils/json_recipe_importer.dart';

/// 我的菜谱页面
/// 显示预设菜谱、用户创建的菜谱和收藏的菜谱
class MyRecipesScreen extends ConsumerStatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  ConsumerState<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends ConsumerState<MyRecipesScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  int _currentTabIndex = 0;
  
  // 🚀 性能优化：缓存Future避免重复请求
  Future<List<Recipe>>? _userRecipesFuture;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // 顶部标题栏
              _buildHeader(isDark),

              const SizedBox(height: AppSpacing.md),

              // Tab切换器
              _buildTabBar(isDark),

              // Tab内容（不需要额外间距）
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPresetRecipes(isDark),
                    _buildCreatedRecipes(isDark),
                    _buildFavoriteRecipes(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 顶部标题栏
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: AppSpacing.pagePadding.copyWith(bottom: 0),
      child: Row(
        children: [
          // 返回按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.getTextPrimaryColor(isDark),
                  size: 24,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 页面标题
          Expanded(
            child: Text(
              '我的菜谱',
              style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.medium,
                fontSize: 24,
              ),
            ),
          ),

          // 标签数量指示器
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_tabController.index + 1}/3',
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: AppColors.primary,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab切换器
  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding.copyWith(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(4),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.getTextSecondaryColor(isDark),
        labelStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
          fontWeight: AppTypography.medium,
          fontSize: 15,
        ),
        unselectedLabelStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
          fontWeight: AppTypography.light,
          fontSize: 15,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 18),
                const SizedBox(width: 6),
                const Text('预设'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 18),
                const SizedBox(width: 6),
                const Text('创建'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 18),
                const SizedBox(width: 6),
                const Text('收藏'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 预设菜谱列表
  Widget _buildPresetRecipes(bool isDark) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return _buildEmptyState(
        isDark,
        icon: '👤',
        title: '请先登录',
        description: '登录后才能查看预设菜谱',
        actionText: '去登录',
        onAction: () => context.go('/login'),
      );
    }
    
    return FutureBuilder<List<Recipe>>(
      future: _loadPresetRecipes(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return _buildEmptyState(
            isDark,
            icon: '❌',
            title: '加载失败',
            description: '无法加载预设菜谱：${snapshot.error}',
            actionText: '重试',
            onAction: () => _refreshRecipes(),
          );
        }
        
        final presetRecipes = snapshot.data ?? [];

        if (presetRecipes.isEmpty) {
          return _buildEmptyState(
            isDark,
            icon: '🍳',
            title: '预设菜谱未初始化',
            description: '点击按钮初始化12个经典预设菜谱',
            actionText: '初始化预设菜谱',
            onAction: () => _initializePresetRecipes(),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // 预设菜谱说明
                _buildPresetInfo(presetRecipes, isDark),
                const SizedBox(height: AppSpacing.md),
                // 菜谱列表
                Expanded(child: _buildRecipeList(presetRecipes, isDark, showPresetTag: true)),
              ],
            ),
            // 悬浮操作按钮
            if (presetRecipes.length < 12)
              Positioned(
                bottom: 24,
                right: 24,
                child: _buildFloatingActionButton(
                  icon: Icons.refresh,
                  label: '重新初始化',
                  onTap: () => _initializePresetRecipes(),
                  isDark: isDark,
                ),
              ),
          ],
        );
      },
    );
  }

  /// 我创建的菜谱列表
  Widget _buildCreatedRecipes(bool isDark) {
    // 🐥 从云端获取当前用户的菜谱
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return _buildEmptyState(
        isDark,
        icon: '👤',
        title: '请先登录',
        description: '登录后才能查看您的菜谱',
        actionText: '去登录',
        onAction: () => context.go('/login'),
      );
    }
    
    // 🚀 性能优化：只在用户变化或初始化时重新请求
    if (_userRecipesFuture == null) {
      _userRecipesFuture = _loadUserRecipes(currentUser.uid);
    }
    
    return FutureBuilder<List<Recipe>>(
      future: _userRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return _buildEmptyState(
            isDark,
            icon: '❌',
            title: '加载失败',
            description: '无法加载菜谱数据：${snapshot.error}',
            actionText: '重试',
            onAction: () => _refreshRecipes(),
          );
        }
        
        final userRecipes = snapshot.data ?? [];

        if (userRecipes.isEmpty) {
          return _buildEmptyState(
            isDark,
            icon: '📝',
            title: '还没有菜谱',
            description: '您还没有创建任何菜谱',
            actionText: '立即创建',
            onAction: () => context.push('/create-recipe'),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // 📊 数据库统计信息
                _buildDatabaseStats(userRecipes, isDark),
                const SizedBox(height: AppSpacing.md),
                // 菜谱列表
                Expanded(child: _buildRecipeList(userRecipes, isDark)),
              ],
            ),
            // 悬浮创建按钮
            Positioned(
              bottom: 24,
              right: 24,
              child: _buildFloatingActionButton(
                icon: Icons.add,
                label: '创建菜谱',
                onTap: () => context.push('/create-recipe'),
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 加载用户菜谱数据（只包含用户自己创建的）
  Future<List<Recipe>> _loadUserRecipes(String userId) async {
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final allUserRecipes = await repository.getUserRecipes(userId);
      // 过滤出用户自己创建的菜谱（排除预设菜谱）
      return allUserRecipes.where((recipe) => !recipe.isPreset).toList();
    } catch (e) {
      print('加载用户菜谱失败: $e');
      rethrow;
    }
  }

  /// 🔧 修复：加载公共预设菜谱数据（所有用户共享）
  Future<List<Recipe>> _loadPresetRecipes(String userId) async {
    try {
      debugPrint('🔍 开始加载公共预设菜谱...');
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      // 🔧 直接查询公共预设菜谱，不从用户菜谱中过滤
      final presetRecipes = await repository.getPresetRecipes();
      debugPrint('✅ 成功加载 ${presetRecipes.length} 个公共预设菜谱');
      return presetRecipes;
    } catch (e) {
      debugPrint('❌ 加载公共预设菜谱失败: $e');
      rethrow;
    }
  }

  /// 加载收藏菜谱数据
  Future<List<Recipe>> _loadFavoriteRecipes(String userId) async {
    try {
      debugPrint('🌟 开始加载用户收藏菜谱: $userId');
      
      // 1. 获取用户收藏的菜谱ID列表
      final favoritesService = ref.read(favoritesServiceProvider);
      final favoriteIds = await favoritesService.getFavoriteRecipeIds(userId);
      
      debugPrint('📋 获取到收藏菜谱ID列表: ${favoriteIds.length} 个');
      
      if (favoriteIds.isEmpty) {
        debugPrint('📝 用户暂无收藏菜谱');
        return [];
      }
      
      // 2. 根据ID获取菜谱详情
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final List<Recipe> favoriteRecipes = [];
      
      for (final recipeId in favoriteIds) {
        try {
          final recipe = await repository.getRecipe(recipeId);
          if (recipe != null) {
            favoriteRecipes.add(recipe);
            debugPrint('✅ 成功加载收藏菜谱: ${recipe.name}');
          } else {
            debugPrint('⚠️ 收藏的菜谱不存在: $recipeId');
          }
        } catch (e) {
          debugPrint('❌ 加载收藏菜谱失败: $recipeId -> $e');
        }
      }
      
      debugPrint('🎉 成功加载 ${favoriteRecipes.length} 个收藏菜谱');
      return favoriteRecipes;
    } catch (e) {
      debugPrint('❌ 加载收藏菜谱失败: $e');
      rethrow;
    }
  }
  
  /// 🔄 刷新菜谱列表
  void _refreshRecipes() {
    setState(() {
      _userRecipesFuture = null; // 清空缓存，触发重新加载
    });
  }

  /// 🍳 初始化预设菜谱
  Future<void> _initializePresetRecipes() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('初始化预设菜谱'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在为您准备12个经典预设菜谱...'),
            ],
          ),
        ),
      );

      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      const rootUserId = '2352016835@qq.com'; // Root用户ID
      
      // 使用JsonRecipeImporter初始化预设菜谱
      final successCount = await JsonRecipeImporter.initializeNewUserWithPresets(
        currentUser.uid,
        rootUserId,
        repository,
      );

      if (mounted) {
        context.pop(); // 关闭加载对话框
        
        if (successCount > 0) {
          // 显示成功结果
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('初始化成功'),
              content: Text(
                '🎉 成功为您准备了 $successCount 个经典预设菜谱！\n\n'
                '包括：银耳汤、番茄面、红烧排骨、宫保鸡丁等经典菜谱。'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    _refreshRecipes(); // 刷新菜谱列表
                  },
                  child: const Text('开始体验'),
                ),
              ],
            ),
          );
        } else {
          _showErrorMessage('初始化失败，请重试');
        }
      }
    } catch (e) {
      if (mounted) {
        context.pop(); // 关闭加载对话框
        _showErrorMessage('初始化失败：$e');
      }
    }
  }

  /// ❌ 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 我收藏的菜谱列表
  Widget _buildFavoriteRecipes(bool isDark) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return _buildEmptyState(
        isDark,
        icon: '👤',
        title: '请先登录',
        description: '登录后才能查看收藏的菜谱',
        actionText: '去登录',
        onAction: () => context.go('/login'),
      );
    }
    
    return FutureBuilder<List<Recipe>>(
      future: _loadFavoriteRecipes(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return _buildEmptyState(
            isDark,
            icon: '❌',
            title: '加载失败',
            description: '无法加载收藏菜谱：${snapshot.error}',
            actionText: '重试',
            onAction: () => _refreshRecipes(),
          );
        }
        
        final favoriteRecipes = snapshot.data ?? [];

        if (favoriteRecipes.isEmpty) {
          return _buildEmptyState(
            isDark,
            icon: '💕',
            title: '还没有收藏菜谱',
            description: '在菜谱详情页点击爱心收藏喜欢的菜谱',
            actionText: '去发现',
            onAction: () => context.go('/'),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // 收藏统计信息
                _buildFavoriteInfo(favoriteRecipes, isDark),
                const SizedBox(height: AppSpacing.md),
                // 菜谱列表
                Expanded(child: _buildRecipeList(favoriteRecipes, isDark, showFavoriteTag: true)),
              ],
            ),
            // 悬浮探索按钮
            if (favoriteRecipes.length < 5)
              Positioned(
                bottom: 24,
                right: 24,
                child: _buildFloatingActionButton(
                  icon: Icons.explore,
                  label: '探索更多',
                  onTap: () => context.go('/'),
                  isDark: isDark,
                ),
              ),
          ],
        );
      },
    );
  }

  /// 🍳 预设菜谱信息
  Widget _buildPresetInfo(List<Recipe> recipes, bool isDark) {
    return Container(
      margin: AppSpacing.pagePadding.copyWith(bottom: 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '经典预设菜谱',
                  style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '为您精选的 ${recipes.length} 道经典家常菜',
                  style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                    color: AppColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💕 收藏菜谱信息
  Widget _buildFavoriteInfo(List<Recipe> recipes, bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '我的收藏夹',
                  style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '已收藏 ${recipes.length} 道菜谱，记录您喜爱的美食时光',
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 数据库统计信息
  Widget _buildDatabaseStats(List<Recipe> recipes, bool isDark) {
    final userGroups = <String, int>{};
    for (var recipe in recipes) {
      userGroups[recipe.createdBy] = (userGroups[recipe.createdBy] ?? 0) + 1;
    }
    
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '数据库状况',
                  style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _buildStatChip('📊 总计: ${recipes.length}个菜谱', isDark),
                ...userGroups.entries.map((entry) => 
                  _buildStatChip('👤 ${entry.key}: ${entry.value}个', isDark)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 统计信息芯片
  Widget _buildStatChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.captionStyle(isDark: isDark).copyWith(
          color: AppColors.primary,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }

  /// 菜谱列表
  Widget _buildRecipeList(List<Recipe> recipes, bool isDark, {
    bool showPresetTag = false,
    bool showFavoriteTag = false,
  }) {
    return ListView.separated(
      padding: AppSpacing.pagePadding.copyWith(
        bottom: AppSpacing.xxl + 80, // 为底部操作留出足够空间
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: recipes.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(
          recipe, 
          isDark, 
          index,
          showPresetTag: showPresetTag,
          showFavoriteTag: showFavoriteTag,
        );
      },
    );
  }

  /// 单个菜谱卡片
  Widget _buildRecipeCard(Recipe recipe, bool isDark, int index, {
    bool showPresetTag = false,
    bool showFavoriteTag = false,
  }) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/recipe/${recipe.id}');
        },
        child: MinimalCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 菜谱图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AppIcon3D(
                    type: _parseIconType(recipe.iconType),
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // 菜谱信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 菜谱名称和标签
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                              fontWeight: AppTypography.medium,
                              color: AppColors.getTextPrimaryColor(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 标签
                        if (showPresetTag) ...[const SizedBox(width: 8), _buildTypeTag('经典', Colors.orange, isDark)],
                        if (showFavoriteTag) ...[const SizedBox(width: 8), _buildTypeTag('收藏', AppColors.primary, isDark)],
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // 菜谱描述
                    Text(
                      recipe.description,
                      style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 菜谱元数据
                    Row(
                      children: [
                        _buildMetaChip('⏱ ${recipe.totalTime}分钟', isDark),
                        const SizedBox(width: AppSpacing.sm),
                        _buildMetaChip('👥 ${recipe.servings}人份', isDark),
                        const SizedBox(width: AppSpacing.sm),
                        _buildMetaChip('⭐ ${recipe.difficulty}', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              // 更多操作按钮
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showRecipeActions(recipe, isDark),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.getTextSecondaryColor(isDark),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 元数据芯片
  Widget _buildMetaChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.captionStyle(isDark: isDark).copyWith(
          color: AppColors.getTextSecondaryColor(isDark),
          fontSize: 11,
          fontWeight: AppTypography.light,
        ),
      ),
    );
  }

  /// 类型标签
  Widget _buildTypeTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.captionStyle(isDark: isDark).copyWith(
          color: color,
          fontWeight: AppTypography.medium,
        ),
      ),
    );
  }

  /// 空状态显示
  Widget _buildEmptyState(
    bool isDark, {
    required String icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 空状态图标
            BreathingWidget(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 标题
            Text(
              title,
              style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.medium,
                color: AppColors.getTextPrimaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // 描述
            Text(
              description,
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // 操作按钮
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onAction();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  actionText,
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示菜谱操作菜单
  void _showRecipeActions(Recipe recipe, bool isDark) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.lg + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getTextSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 菜谱信息
            Row(
              children: [
                AppIcon3D(
                  type: _parseIconType(recipe.iconType),
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: AppTypography.titleMediumStyle(isDark: isDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${recipe.steps.length}个步骤 · ${recipe.totalTime}分钟',
                        style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            const SizedBox(height: AppSpacing.md),

            // 操作按钮组
            _buildActionButton(
              icon: Icons.edit_outlined,
              title: '编辑菜谱',
              subtitle: '修改菜谱信息和步骤',
              onTap: () {
                context.pop();
                // TODO: 导航到编辑页面
              },
              isDark: isDark,
            ),

            _buildActionButton(
              icon: Icons.share_outlined,
              title: '分享菜谱',
              subtitle: '分享给好友或家人',
              onTap: () {
                context.pop();
                // TODO: 实现分享功能
              },
              isDark: isDark,
            ),

            _buildActionButton(
              icon: Icons.delete_outline,
              title: '删除菜谱',
              subtitle: '永久删除此菜谱',
              onTap: () {
                context.pop();
                _confirmDeleteRecipe(recipe);
              },
              isDark: isDark,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDestructive 
                  ? Colors.red.withOpacity(0.05)
                  : AppColors.getBackgroundSecondaryColor(isDark).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.withOpacity(0.2)
                    : AppColors.getBackgroundSecondaryColor(isDark),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : AppColors.getBackgroundSecondaryColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive 
                        ? Colors.red 
                        : AppColors.getTextPrimaryColor(isDark),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                          color: isDestructive 
                              ? Colors.red 
                              : AppColors.getTextPrimaryColor(isDark),
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                          color: isDestructive
                              ? Colors.red.withOpacity(0.7)
                              : AppColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDestructive
                      ? Colors.red.withOpacity(0.5)
                      : AppColors.getTextSecondaryColor(isDark),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 确认删除菜谱
  void _confirmDeleteRecipe(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除菜谱'),
        content: Text('确定要删除菜谱「${recipe.name}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              final currentUser = ref.read(currentUserProvider);
              if (currentUser == null) return;
              
              try {
                final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
                await repository.deleteRecipe(recipe.id, currentUser.uid);
                if (mounted) {
                  _refreshRecipes(); // 🔄 刷新列表
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('菜谱「${recipe.name}」已删除'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败：$e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🧹 清理步骤图片数据 - 解决Firebase控制台卡死问题
  void _cleanupStepImages() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    
    try {
      // 显示清理对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('清理数据'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在清理所有图片数据，这可能需要几秒钟...'),
            ],
          ),
        ),
      );
      
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final cleanedCount = await repository.cleanupAllImagesBase64(currentUser.uid);
      
      if (mounted) {
        context.pop(); // 关闭清理对话框
        
        // 显示清理结果
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('清理完成'),
            content: Text(
              '🎉 成功清理了 $cleanedCount 个菜谱中的所有图片数据！\n\n'
              'Firebase控制台现在应该能正常查看菜谱数据了。'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                  _refreshRecipes(); // 刷新菜谱列表
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        context.pop(); // 关闭清理对话框
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清理失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 解析图标类型
  AppIcon3DType _parseIconType(String iconTypeString) {
    switch (iconTypeString) {
      case 'AppIcon3DType.heart':
        return AppIcon3DType.heart;
      case 'AppIcon3DType.star':
        return AppIcon3DType.heart;
      case 'AppIcon3DType.chef':
        return AppIcon3DType.chef;
      case 'AppIcon3DType.fire':
        return AppIcon3DType.timer;
      default:
        return AppIcon3DType.heart;
    }
  }

  /// 悬浮操作按钮
  Widget _buildFloatingActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                color: Colors.white,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}