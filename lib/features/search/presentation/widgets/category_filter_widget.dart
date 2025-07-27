import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../domain/models/recipe_filter.dart';

/// 分类筛选组件
/// 提供多维度筛选：分类、难度、时长、标签
class CategoryFilterWidget extends StatefulWidget {
  final RecipeFilter currentFilter;
  final Function(RecipeFilter) onFilterChanged;
  final bool isDark;

  const CategoryFilterWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  late RecipeFilter _workingFilter;

  @override
  void initState() {
    super.initState();
    _workingFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部
          _buildHeader(),
          
          Space.h16,
          
          // 分类筛选
          _buildSection(
            title: '菜系分类',
            child: _buildCategoryFilters(),
          ),
          
          Space.h16,
          
          // 难度筛选
          _buildSection(
            title: '制作难度',
            child: _buildDifficultyFilters(),
          ),
          
          Space.h16,
          
          // 时长筛选
          _buildSection(
            title: '制作时长',
            child: _buildTimeFilters(),
          ),
          
          Space.h16,
          
          // 操作按钮
          _buildActions(),
        ],
      ),
    );
  }
  
  /// 构建头部
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.tune,
          color: AppColors.getTextPrimaryColor(widget.isDark),
          size: 20,
        ),
        
        Space.w8,
        
        Text(
          '筛选条件',
          style: AppTypography.titleMediumStyle(isDark: widget.isDark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
        
        const Spacer(),
        
        // 清除所有筛选
        if (!_workingFilter.isEmpty)
          GestureDetector(
            onTap: _clearAllFilters,
            child: Text(
              '清除全部',
              style: AppTypography.bodySmallStyle(isDark: widget.isDark).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
  
  /// 构建区域
  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
        
        Space.h8,
        
        child,
      ],
    );
  }
  
  /// 构建分类筛选
  Widget _buildCategoryFilters() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: RecipeCategory.values.map((category) {
        final isSelected = _workingFilter.categories.contains(category);
        
        return GestureDetector(
          onTap: () => _toggleCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.getBackgroundColor(widget.isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(widget.isDark).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                
                Space.w4,
                
                Text(
                  category.displayName,
                  style: AppTypography.captionStyle(isDark: widget.isDark).copyWith(
                    color: isSelected 
                        ? AppColors.primary
                        : AppColors.getTextPrimaryColor(widget.isDark),
                    fontWeight: isSelected ? AppTypography.medium : AppTypography.light,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// 构建难度筛选
  Widget _buildDifficultyFilters() {
    return Row(
      children: RecipeDifficulty.values.map((difficulty) {
        final isSelected = _workingFilter.difficulties.contains(difficulty);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _toggleDifficulty(difficulty),
            child: Container(
              margin: EdgeInsets.only(
                right: difficulty != RecipeDifficulty.values.last ? AppSpacing.xs : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.getBackgroundColor(widget.isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.getTextSecondaryColor(widget.isDark).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    difficulty.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  Space.h2,
                  
                  Text(
                    difficulty.displayName,
                    style: AppTypography.captionStyle(isDark: widget.isDark).copyWith(
                      color: isSelected 
                          ? AppColors.primary
                          : AppColors.getTextPrimaryColor(widget.isDark),
                      fontWeight: isSelected ? AppTypography.medium : AppTypography.light,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// 构建时长筛选
  Widget _buildTimeFilters() {
    return Column(
      children: TimeRange.presets.map((timeRange) {
        final isSelected = _workingFilter.timeRange == timeRange;
        
        return GestureDetector(
          onTap: () => _toggleTimeRange(timeRange),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.getBackgroundColor(widget.isDark),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(widget.isDark).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.getTextSecondaryColor(widget.isDark),
                ),
                
                Space.w8,
                
                Text(
                  timeRange.displayName,
                  style: AppTypography.bodySmallStyle(isDark: widget.isDark).copyWith(
                    color: isSelected 
                        ? AppColors.primary
                        : AppColors.getTextPrimaryColor(widget.isDark),
                    fontWeight: isSelected ? AppTypography.medium : AppTypography.light,
                  ),
                ),
                
                const Spacer(),
                
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActions() {
    return Row(
      children: [
        // 取消按钮
        Expanded(
          child: GestureDetector(
            onTap: _cancel,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(widget.isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(
                  color: AppColors.getTextSecondaryColor(widget.isDark).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '取消',
                  style: AppTypography.bodyMediumStyle(isDark: widget.isDark),
                ),
              ),
            ),
          ),
        ),
        
        Space.w12,
        
        // 应用按钮
        Expanded(
          child: GestureDetector(
            onTap: _apply,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '应用筛选',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // ==================== 交互方法 ====================
  
  void _toggleCategory(RecipeCategory category) {
    HapticFeedback.lightImpact();
    setState(() {
      final categories = List<RecipeCategory>.from(_workingFilter.categories);
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
      _workingFilter = _workingFilter.copyWith(categories: categories);
    });
  }
  
  void _toggleDifficulty(RecipeDifficulty difficulty) {
    HapticFeedback.lightImpact();
    setState(() {
      final difficulties = List<RecipeDifficulty>.from(_workingFilter.difficulties);
      if (difficulties.contains(difficulty)) {
        difficulties.remove(difficulty);
      } else {
        difficulties.add(difficulty);
      }
      _workingFilter = _workingFilter.copyWith(difficulties: difficulties);
    });
  }
  
  void _toggleTimeRange(TimeRange timeRange) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_workingFilter.timeRange == timeRange) {
        _workingFilter = _workingFilter.copyWith(timeRange: null);
      } else {
        _workingFilter = _workingFilter.copyWith(timeRange: timeRange);
      }
    });
  }
  
  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _workingFilter = RecipeFilter.empty();
    });
  }
  
  void _cancel() {
    HapticFeedback.lightImpact();
    setState(() {
      _workingFilter = widget.currentFilter;
    });
    // 这里可以关闭筛选面板
  }
  
  void _apply() {
    HapticFeedback.mediumImpact();
    widget.onFilterChanged(_workingFilter);
    // 这里可以关闭筛选面板
  }
}