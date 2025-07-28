import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/providers/achievement_provider.dart';

/// 用户等级头部组件
class UserLevelHeader extends ConsumerWidget {
  const UserLevelHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLevel = ref.watch(userLevelProvider);
    final statistics = ref.watch(achievementStatisticsProvider);
    final unlockedAchievements = ref.watch(unlockedAchievementsProvider);
    
    final totalPoints = unlockedAchievements.fold(0, (sum, achievement) => sum + achievement.points);
    
    return Container(
      margin: AppSpacing.pagePadding,
      child: BreathingWidget(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                userLevel['color'].withOpacity(0.1),
                userLevel['color'].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: userLevel['color'].withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // 等级图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        userLevel['color'],
                        userLevel['color'].withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: userLevel['color'].withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userLevel['emoji'],
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // 等级信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userLevel['level'],
                        style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w300,
                          color: userLevel['color'],
                        ),
                      ),
                      
                      Space.h4,
                      
                      Text(
                        '总积分：$totalPoints',
                        style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      Space.h8,
                      
                      // 成就统计
                      Row(
                        children: [
                          _buildStatItem(
                            '${statistics['unlocked']}',
                            '已解锁',
                            AppColors.primary,
                          ),
                          Space.w16,
                          _buildStatItem(
                            '${statistics['inProgress']}',
                            '进行中',
                            AppColors.emotionGradient.colors.first,
                          ),
                          Space.w16,
                          _buildStatItem(
                            '${(statistics['completionRate'] * 100).round()}%',
                            '完成度',
                            userLevel['color'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}