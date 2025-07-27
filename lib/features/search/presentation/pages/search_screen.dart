import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../core/animations/christmas_snow_effect.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/search_results_widget.dart';
import '../../domain/models/recipe_filter.dart';

/// 搜索与分类页面
/// 优雅的搜索界面，保留随机探索，符合95%黑白灰设计原则
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  // 搜索状态
  RecipeFilter _currentFilter = RecipeFilter.empty();
  bool _isSearching = false;
  bool _showFilters = false;
  
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }
  
  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: ChristmasSnowEffect(
        enableClickEffect: true,
        snowflakeCount: 3, // 最少雪花保持性能
        clickEffectColor: const Color(0xFF00BFFF),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 搜索头部
                _buildSearchHeader(isDark),
                
                // 筛选器面板
                if (_showFilters) _buildFilterPanel(isDark),
                
                // 搜索结果或探索内容
                Expanded(
                  child: _isSearching
                      ? SearchResultsWidget(
                          filter: _currentFilter,
                          onRecipeTap: _navigateToRecipeDetail,
                        )
                      : _buildExploreContent(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 构建搜索头部
  Widget _buildSearchHeader(bool isDark) {
    return Container(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 顶部导航栏
          Row(
            children: [
              // 返回按钮
              BreathingWidget(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundSecondaryColor(isDark),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getShadowColor(isDark).withOpacity(0.1),
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
              ),
              
              Space.w16,
              
              // 页面标题
              Expanded(
                child: Text(
                  '美食搜索',
                  style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.light,
                  ),
                ),
              ),
              
              // 随机探索按钮
              _buildRandomButton(isDark),
            ],
          ),
          
          Space.h24,
          
          // 搜索栏
          SearchBarWidget(
            controller: _searchController,
            focusNode: _searchFocus,
            isDark: isDark,
            onChanged: _onSearchChanged,
            onFilterTap: _toggleFilters,
            filterCount: _currentFilter.filterCount,
          ),
        ],
      ),
    );
  }
  
  /// 构建随机探索按钮
  Widget _buildRandomButton(bool isDark) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: _randomExplore,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, // 5%彩色焦点
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.explore,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
  
  /// 构建筛选器面板
  Widget _buildFilterPanel(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDark).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CategoryFilterWidget(
          currentFilter: _currentFilter,
          onFilterChanged: _onFilterChanged,
          isDark: isDark,
        ),
      ),
    );
  }
  
  /// 构建探索内容（无搜索时显示）
  Widget _buildExploreContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门搜索
          _buildSection(
            title: '热门搜索',
            isDark: isDark,
            child: _buildPopularTags(isDark),
          ),
          
          Space.h32,
          
          // 分类快速入口
          _buildSection(
            title: '分类浏览',
            isDark: isDark,
            child: _buildCategoryGrid(isDark),
          ),
          
          Space.h32,
          
          // 推荐菜谱
          _buildSection(
            title: '精选推荐',
            isDark: isDark,
            child: _buildRecommendedRecipes(isDark),
          ),
        ],
      ),
    );
  }
  
  /// 构建区域组件
  Widget _buildSection({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
        
        Space.h16,
        
        child,
      ],
    );
  }
  
  /// 构建热门标签
  Widget _buildPopularTags(bool isDark) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: PopularTags.tags.map((tag) {
        return GestureDetector(
          onTap: () => _searchByTag(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
              border: Border.all(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              tag,
              style: AppTypography.bodySmallStyle(isDark: isDark),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// 构建分类网格
  Widget _buildCategoryGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: RecipeCategory.values.length,
      itemBuilder: (context, index) {
        final category = RecipeCategory.values[index];
        return GestureDetector(
          onTap: () => _searchByCategory(category),
          child: BreathingWidget(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  
                  Space.h4,
                  
                  Text(
                    category.displayName,
                    style: AppTypography.captionStyle(isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// 构建推荐菜谱
  Widget _buildRecommendedRecipes(bool isDark) {
    // 这里可以显示一些推荐的菜谱卡片
    return Container(
      height: 120,
      child: Center(
        child: Text(
          '基于你的喜好推荐',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }
  
  // ==================== 交互方法 ====================
  
  void _onSearchChanged(String query) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(searchQuery: query);
      _isSearching = query.trim().isNotEmpty || !_currentFilter.copyWith(searchQuery: null).isEmpty;
    });
  }
  
  void _onFilterChanged(RecipeFilter filter) {
    setState(() {
      _currentFilter = filter;
      _isSearching = !filter.isEmpty;
    });
  }
  
  void _toggleFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _showFilters = !_showFilters;
    });
  }
  
  void _searchByTag(String tag) {
    HapticFeedback.lightImpact();
    _searchController.text = tag;
    _onSearchChanged(tag);
    _searchFocus.unfocus();
  }
  
  void _searchByCategory(RecipeCategory category) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentFilter = _currentFilter.copyWith(
        categories: [category],
      );
      _isSearching = true;
    });
  }
  
  void _randomExplore() {
    HapticFeedback.mediumImpact();
    // TODO: 实现随机探索逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.explore, color: Colors.white, size: 20),
            Space.w8,
            const Text('随机探索新菜谱！'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _navigateToRecipeDetail(String recipeId) {
    HapticFeedback.lightImpact();
    // TODO: 导航到菜谱详情页面
    context.push('/recipe/$recipeId');
  }
}