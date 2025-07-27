import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/app_icon_3d.dart';
import '../../domain/models/recipe_filter.dart';

/// 搜索结果组件
/// 显示根据筛选条件匹配的菜谱列表
class SearchResultsWidget extends StatefulWidget {
  final RecipeFilter filter;
  final Function(String) onRecipeTap;

  const SearchResultsWidget({
    super.key,
    required this.filter,
    required this.onRecipeTap,
  });

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(SearchResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _buildSearchResults(isDark);
  }

  /// 构建加载状态
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BreathingWidget(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Space.h16,
          
          Text(
            '正在搜索美味...',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 空状态图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
            
            Space.h24,
            
            Text(
              '没有找到匹配的菜谱',
              style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.light,
              ),
            ),
            
            Space.h8,
            
            Text(
              '试试调整筛选条件或搜索其他关键词',
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            
            Space.h32,
            
            // 建议操作
            _buildSuggestionChips(isDark),
          ],
        ),
      ),
    );
  }

  /// 构建建议标签
  Widget _buildSuggestionChips(bool isDark) {
    final suggestions = ['快手菜', '下饭菜', '汤品', '甜品'];
    
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () => _quickSearch(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              suggestion,
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(bool isDark) {
    return CustomScrollView(
      slivers: [
        // 顶部边距
        SliverPadding(
          padding: AppSpacing.pagePadding,
          sliver: SliverToBoxAdapter(
            child: _buildResultsHeader(isDark),
          ),
        ),
        
        // 结果网格
        SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.pagePadding.left,
            right: AppSpacing.pagePadding.right,
            top: AppSpacing.lg,
            bottom: AppSpacing.pagePadding.bottom,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = _searchResults[index];
                return _buildRecipeCard(recipe, isDark);
              },
              childCount: _searchResults.length,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建结果头部
  Widget _buildResultsHeader(bool isDark) {
    return Row(
      children: [
        Text(
          '找到 ${_searchResults.length} 道菜谱',
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
        
        const Spacer(),
        
        // 排序按钮
        GestureDetector(
          onTap: _showSortOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 16,
                  color: AppColors.getTextSecondaryColor(isDark),
                ),
                
                Space.w4,
                
                Text(
                  '排序',
                  style: AppTypography.captionStyle(isDark: isDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建菜谱卡片
  Widget _buildRecipeCard(Map<String, dynamic> recipe, bool isDark) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onRecipeTap(recipe['id']);
        },
        child: MinimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标区域
              Expanded(
                flex: 3,
                child: Center(
                  child: AppIcon3D(
                    type: recipe['iconType'] ?? AppIcon3DType.recipe,
                    size: 60,
                    isAnimated: false,
                  ),
                ),
              ),
              
              // 信息区域
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 菜名
                      Text(
                        recipe['name'],
                        style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      Space.h4,
                      
                      // 标签
                      if (recipe['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          ),
                          child: Text(
                            recipe['category'].displayName,
                            style: AppTypography.captionStyle(isDark: isDark).copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // 时间和难度
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.getTextSecondaryColor(isDark),
                          ),
                          
                          Space.w4,
                          
                          Text(
                            '${recipe['time']}分钟',
                            style: AppTypography.captionStyle(isDark: isDark).copyWith(
                              fontSize: 10,
                            ),
                          ),
                          
                          const Spacer(),
                          
                          if (recipe['difficulty'] != null)
                            Text(
                              recipe['difficulty'].icon,
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 数据处理方法 ====================

  /// 执行搜索
  void _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟搜索延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟搜索结果
    final allRecipes = _getMockRecipes();
    final filteredRecipes = _applyFilter(allRecipes, widget.filter);

    if (mounted) {
      setState(() {
        _searchResults = filteredRecipes;
        _isLoading = false;
      });
    }
  }

  /// 获取模拟菜谱数据
  List<Map<String, dynamic>> _getMockRecipes() {
    return [
      {
        'id': 'recipe_1',
        'name': '银耳莲子羹',
        'time': 20,
        'iconType': AppIcon3DType.bowl,
        'category': RecipeCategory.dessert,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['甜品', '养生', '补汤'],
      },
      {
        'id': 'recipe_2',
        'name': '番茄鸡蛋面',
        'time': 15,
        'iconType': AppIcon3DType.spoon,
        'category': RecipeCategory.chinese,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['快手菜', '下饭菜'],
      },
      {
        'id': 'recipe_3',
        'name': '红烧排骨',
        'time': 45,
        'iconType': AppIcon3DType.chef,
        'category': RecipeCategory.chinese,
        'difficulty': RecipeDifficulty.medium,
        'tags': ['下饭菜', '聚餐'],
      },
      {
        'id': 'recipe_4',
        'name': '蒸蛋羹',
        'time': 10,
        'iconType': AppIcon3DType.timer,
        'category': RecipeCategory.chinese,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['快手菜', '儿童餐'],
      },
      {
        'id': 'recipe_5',
        'name': '青椒肉丝',
        'time': 25,
        'iconType': AppIcon3DType.recipe,
        'category': RecipeCategory.chinese,
        'difficulty': RecipeDifficulty.medium,
        'tags': ['下饭菜'],
      },
      {
        'id': 'recipe_6',
        'name': '爱心早餐',
        'time': 30,
        'iconType': AppIcon3DType.heart,
        'category': RecipeCategory.western,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['情侣餐', '早餐'],
      },
      {
        'id': 'recipe_7',
        'name': '紫菜蛋花汤',
        'time': 8,
        'iconType': AppIcon3DType.bowl,
        'category': RecipeCategory.soup,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['快手菜', '补汤'],
      },
      {
        'id': 'recipe_8',
        'name': '蔬菜沙拉',
        'time': 12,
        'iconType': AppIcon3DType.recipe,
        'category': RecipeCategory.salad,
        'difficulty': RecipeDifficulty.easy,
        'tags': ['减脂餐', '素食'],
      },
    ];
  }

  /// 应用筛选条件
  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> recipes,
    RecipeFilter filter,
  ) {
    return recipes.where((recipe) {
      // 搜索关键词筛选
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchesName = recipe['name'].toLowerCase().contains(query);
        final matchesTags = (recipe['tags'] as List<String>)
            .any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesTags) {
          return false;
        }
      }

      // 分类筛选
      if (filter.categories.isNotEmpty) {
        if (!filter.categories.contains(recipe['category'])) {
          return false;
        }
      }

      // 难度筛选
      if (filter.difficulties.isNotEmpty) {
        if (!filter.difficulties.contains(recipe['difficulty'])) {
          return false;
        }
      }

      // 时长筛选
      if (filter.timeRange != null) {
        final time = recipe['time'] as int;
        if (!filter.timeRange!.contains(time)) {
          return false;
        }
      }

      // 标签筛选
      if (filter.tags.isNotEmpty) {
        final recipeTags = recipe['tags'] as List<String>;
        if (!filter.tags.any((tag) => recipeTags.contains(tag))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ==================== 交互方法 ====================

  /// 快速搜索
  void _quickSearch(String query) {
    HapticFeedback.lightImpact();
    // 这里可以触发父组件更新搜索条件
    // 暂时显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('搜索"$query"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 显示排序选项
  void _showSortOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.cardContentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '排序方式',
              style: AppTypography.titleMediumStyle(
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
            
            Space.h16,
            
            ...[
              '制作时间（短到长）',
              '制作时间（长到短）',
              '难度（简单到困难）',
              '最近添加',
            ].map((option) => ListTile(
              title: Text(option),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现排序逻辑
              },
            )),
          ],
        ),
      ),
    );
  }
}