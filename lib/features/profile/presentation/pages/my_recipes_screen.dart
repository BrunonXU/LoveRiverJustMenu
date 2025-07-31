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

/// 我的菜谱页面
/// 显示用户创建的菜谱和收藏的菜谱
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
    _tabController = TabController(length: 2, vsync: this);
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

              const SizedBox(height: AppSpacing.lg),

              // Tab切换器
              _buildTabBar(isDark),

              const SizedBox(height: AppSpacing.lg),

              // Tab内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
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
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.getTextPrimaryColor(isDark),
                size: 18,
              ),
            ),
          ),

          const Spacer(),

          // 页面标题
          BreathingWidget(
            child: Text(
              '我的菜谱',
              style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.light,
              ),
            ),
          ),

          const Spacer(),

          // 添加按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/create-recipe');
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab切换器
  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.getTextSecondaryColor(isDark),
          labelStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            fontWeight: AppTypography.medium,
          ),
          unselectedLabelStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            fontWeight: AppTypography.light,
          ),
          tabs: const [
            Tab(text: '我创建的'),
            Tab(text: '我收藏的'),
          ],
        ),
      ),
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

        return Column(
          children: [
            // 📊 数据库统计信息
            _buildDatabaseStats(userRecipes, isDark),
            const SizedBox(height: AppSpacing.md),
            // 菜谱列表
            Expanded(child: _buildRecipeList(userRecipes, isDark)),
          ],
        );
      },
    );
  }
  
  /// 加载用户菜谱数据
  Future<List<Recipe>> _loadUserRecipes(String userId) async {
    try {
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      return await repository.getUserRecipes(userId);
    } catch (e) {
      print('加载用户菜谱失败: $e');
      rethrow;
    }
  }
  
  /// 🔄 刷新菜谱列表
  void _refreshRecipes() {
    setState(() {
      _userRecipesFuture = null; // 清空缓存，触发重新加载
    });
  }

  /// 我收藏的菜谱列表（暂时显示空状态）
  Widget _buildFavoriteRecipes(bool isDark) {
    // TODO: 实现收藏功能后从数据库获取收藏的菜谱
    return _buildEmptyState(
      isDark,
      icon: '💕',
      title: '还没有收藏菜谱',
      description: '在菜谱详情页点击爱心收藏喜欢的菜谱',
      actionText: '去发现',
      onAction: () => context.go('/'),
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
  Widget _buildRecipeList(List<Recipe> recipes, bool isDark) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      physics: const BouncingScrollPhysics(),
      itemCount: recipes.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(recipe, isDark, index);
      },
    );
  }

  /// 单个菜谱卡片
  Widget _buildRecipeCard(Recipe recipe, bool isDark, int index) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.push('/recipe/${recipe.id}');
        },
        child: MinimalCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // 菜谱图标
              AppIcon3D(
                type: _parseIconType(recipe.iconType),
                size: 60,
              ),

              const SizedBox(width: AppSpacing.lg),

              // 菜谱信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 菜谱名称
                    Text(
                      recipe.name,
                      style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                        fontWeight: AppTypography.medium,
                        color: AppColors.getTextPrimaryColor(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    
                    // 📊 调试信息：显示数据库详细信息
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _buildMetaChip('👤 ${recipe.createdBy}', isDark),
                        const SizedBox(width: AppSpacing.sm),
                        _buildMetaChip('📊 ID: ${recipe.id.substring(0, 8)}...', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // 更多操作按钮
              GestureDetector(
                onTap: () => _showRecipeActions(recipe, isDark),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.getBackgroundSecondaryColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.getTextSecondaryColor(isDark),
                    size: 16,
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
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.captionStyle(isDark: isDark).copyWith(
          color: AppColors.getTextSecondaryColor(isDark),
          fontWeight: AppTypography.light,
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLarge),
            topRight: Radius.circular(AppSpacing.radiusLarge),
          ),
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

            // 操作按钮
            _buildActionButton('编辑菜谱', Icons.edit, () {
              context.pop();
              // TODO: 导航到编辑页面
            }, isDark),

            const SizedBox(height: AppSpacing.sm),

            _buildActionButton('分享菜谱', Icons.share, () {
              context.pop();
              // TODO: 实现分享功能
            }, isDark),

            const SizedBox(height: AppSpacing.sm),

            // 🧹 临时数据清理按钮 - 解决Firebase控制台卡死问题
            _buildActionButton('清理数据', Icons.cleaning_services, () {
              context.pop();
              _cleanupStepImages();
            }, isDark),

            const SizedBox(height: AppSpacing.sm),

            _buildActionButton('删除菜谱', Icons.delete, () {
              context.pop();
              _confirmDeleteRecipe(recipe);
            }, isDark, isDestructive: true),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? Colors.red 
                  : AppColors.getTextPrimaryColor(isDark),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: isDestructive 
                    ? Colors.red 
                    : AppColors.getTextPrimaryColor(isDark),
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
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
              Text('正在清理步骤图片数据，这可能需要几秒钟...'),
            ],
          ),
        ),
      );
      
      final repository = await ref.read(initializedCloudRecipeRepositoryProvider.future);
      final cleanedCount = await repository.cleanupStepImagesBase64(currentUser.uid);
      
      if (mounted) {
        context.pop(); // 关闭清理对话框
        
        // 显示清理结果
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('清理完成'),
            content: Text(
              '🎉 成功清理了 $cleanedCount 个菜谱中的步骤图片数据！\n\n'
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
}