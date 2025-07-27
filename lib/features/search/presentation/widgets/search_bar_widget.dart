import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';

/// 搜索栏组件
/// 极简设计，符合95%黑白灰原则
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final int filterCount;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onFilterTap,
    this.filterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 搜索输入框
        Expanded(
          child: _buildSearchInput(),
        ),
        
        Space.w12,
        
        // 筛选按钮
        _buildFilterButton(),
      ],
    );
  }
  
  /// 构建搜索输入框
  Widget _buildSearchInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDark).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '搜索菜谱、食材、标签...',
          hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.getTextSecondaryColor(isDark),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(
                    Icons.clear,
                    color: AppColors.getTextSecondaryColor(isDark),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
  
  /// 构建筛选按钮
  Widget _buildFilterButton() {
    final hasFilters = filterCount > 0;
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onFilterTap();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasFilters 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: hasFilters 
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.tune,
                  color: hasFilters 
                      ? AppColors.primary
                      : AppColors.getTextSecondaryColor(isDark),
                  size: 20,
                ),
              ),
              
              // 筛选数量指示器
              if (hasFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        filterCount.toString(),
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: AppTypography.medium,
                        ),
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
}