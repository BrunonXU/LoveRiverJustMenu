import 'package:flutter/material.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/achievement.dart';

/// 🚀 极简高性能成就树
class AchievementTreeSimple extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementTreeSimple({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    // 按等级分组 - 一次性计算
    final levelGroups = <AchievementLevel, List<Achievement>>{};
    for (final achievement in achievements) {
      levelGroups.putIfAbsent(achievement.level, () => []).add(achievement);
    }

    return RepaintBoundary(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 简化的树干图标
            SizedBox(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🌳', style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    '成就之树',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // 各等级成就 - 自下而上
            ..._buildLevelSections(levelGroups),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLevelSections(Map<AchievementLevel, List<Achievement>> levelGroups) {
    final levels = [
      AchievementLevel.bronze,
      AchievementLevel.silver, 
      AchievementLevel.gold,
      AchievementLevel.diamond,
      AchievementLevel.legendary,
    ];

    return levels.map((level) {
      final achievements = levelGroups[level] ?? [];
      if (achievements.isEmpty) return const SizedBox.shrink();
      
      return _buildLevelSection(level, achievements);
    }).toList();
  }

  Widget _buildLevelSection(AchievementLevel level, List<Achievement> achievements) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // 等级标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getLevelColor(level).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getLevelEmoji(level), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _getLevelName(level),
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: _getLevelColor(level),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 成就网格 - 简化布局
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: achievements.map((achievement) => 
              _buildSimpleAchievementNode(achievement)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAchievementNode(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final isNearComplete = achievement.progress >= 0.8 && !isUnlocked;
    
    return GestureDetector(
      onTap: () => onAchievementTap?.call(achievement),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUnlocked 
              ? _getLevelColor(achievement.level).withValues(alpha: 0.2)
              : isNearComplete 
                  ? AppColors.emotionGradient.colors.first.withValues(alpha: 0.1)
                  : AppColors.backgroundSecondary,
          border: Border.all(
            color: isUnlocked 
                ? _getLevelColor(achievement.level)
                : isNearComplete 
                    ? AppColors.emotionGradient.colors.first
                    : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isUnlocked ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: isUnlocked ? 28 : 20,
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 2),
              Text(
                '${achievement.points}',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _getLevelColor(achievement.level),
                ),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                '${(achievement.progress * 100).round()}%',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        return const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        return const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        return const Color(0xFFB9F2FF);
      case AchievementLevel.legendary:
        return const Color(0xFFFF6B6B);
    }
  }

  String _getLevelName(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return '青铜成就';
      case AchievementLevel.silver:
        return '白银成就';
      case AchievementLevel.gold:
        return '黄金成就';
      case AchievementLevel.diamond:
        return '钻石成就';
      case AchievementLevel.legendary:
        return '传说成就';
    }
  }

  String _getLevelEmoji(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return '🥉';
      case AchievementLevel.silver:
        return '🥈';
      case AchievementLevel.gold:
        return '🥇';
      case AchievementLevel.diamond:
        return '💎';
      case AchievementLevel.legendary:
        return '👑';
    }
  }
}