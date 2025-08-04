import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/typography.dart';
import '../../core/themes/spacing.dart';
import 'breathing_widget.dart';

/// 🚧 占位页面 - 用于未实现的功能
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle = '功能正在开发中...',
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // 返回按钮
                  BreathingWidget(
                    child: GestureDetector(
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
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    title,
                    style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.light,
                    ),
                  ),
                ],
              ),
            ),

            // 中心内容
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 图标
                      BreathingWidget(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.getBackgroundSecondaryColor(isDark),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 48,
                            color: AppColors.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 标题
                      Text(
                        title,
                        style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                          fontWeight: AppTypography.light,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 副标题
                      Text(
                        subtitle,
                        style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // 返回按钮
                      BreathingWidget(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getBackgroundSecondaryColor(isDark),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                              border: Border.all(
                                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '返回',
                              style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                                fontWeight: AppTypography.light,
                                color: AppColors.getTextPrimaryColor(isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}