import 'package:flutter/material.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/intimacy_level.dart';
import 'intimacy_progress_ring.dart';

/// 🥰 亲密度等级卡片
class IntimacyLevelCard extends StatelessWidget {
  final IntimacyLevel currentLevel;
  final int totalPoints;
  final double progress;
  final int pointsToNext;
  final VoidCallback? onTap;

  const IntimacyLevelCard({
    super.key,
    required this.currentLevel,
    required this.totalPoints,
    required this.progress,
    required this.pointsToNext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MinimalCard(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentLevel.themeColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: currentLevel.themeColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 顶部：等级信息
              Row(
                children: [
                  // 等级图标
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          currentLevel.themeColor,
                          currentLevel.themeColor.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentLevel.themeColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentLevel.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  
                  Space.w16,
                  
                  // 等级信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLevel.title,
                          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                            fontWeight: FontWeight.w500,
                            color: currentLevel.themeColor,
                          ),
                        ),
                        Space.h4,
                        Text(
                          currentLevel.description,
                          style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Space.h4,
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              size: 16,
                              color: currentLevel.themeColor,
                            ),
                            Space.w4,
                            Text(
                              '$totalPoints 积分',
                              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                color: currentLevel.themeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 环形进度
                  IntimacyProgressRing(
                    progress: progress,
                    color: currentLevel.themeColor,
                    size: 50,
                    strokeWidth: 4,
                  ),
                ],
              ),
              
              Space.h16,
              
              // 底部：进度信息
              _buildProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final nextLevel = currentLevel.getNextLevel();
    
    if (nextLevel == null) {
      // 已达到最高等级
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withValues(alpha: 0.1),
              const Color(0xFFF0E68C).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👑', style: TextStyle(fontSize: 20)),
            Space.w8,
            Text(
              '已达到最高等级',
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                color: const Color(0xFFB8860B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // 进度条
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentLevel.themeColor,
                    nextLevel.themeColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        Space.h12,
        
        // 下一等级信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 当前等级
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前',
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      currentLevel.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Space.w4,
                    Text(
                      currentLevel.title,
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: currentLevel.themeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // 进度指示
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.emotionGradient.colors.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                '还需 $pointsToNext 积分',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: AppColors.emotionGradient.colors.first,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // 下一等级
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '下一级',
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      nextLevel.title,
                      style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                        color: nextLevel.themeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Space.w4,
                    Text(
                      nextLevel.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}