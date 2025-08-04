import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';

/// 🔧 性能优化版成就系统状态管理
class AchievementNotifierOptimized extends StateNotifier<List<Achievement>> {
  AchievementNotifierOptimized() : super(_getSimpleAchievements()) {
    _loadSimpleProgress();
  }

  /// 🔧 简化的成就数据 - 减少数据量
  static List<Achievement> _getSimpleAchievements() {
    return [
      // 只保留核心成就，减少数据量
      Achievement(
        id: 'cooking_first_recipe',
        title: '初试牛刀',
        description: '成功创建第一个菜谱',
        emoji: '🍳',
        category: AchievementCategory.cooking,
        level: AchievementLevel.bronze,
        points: 10,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 1,
            description: '创建1个菜谱',
          ),
        ],
        isUnlocked: true,
        progress: 1.0,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Achievement(
        id: 'cooking_chef',
        title: '厨房高手',
        description: '累计创建10个菜谱',
        emoji: '👨‍🍳',
        category: AchievementCategory.cooking,
        level: AchievementLevel.silver,
        points: 50,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 10,
            description: '创建10个菜谱',
          ),
        ],
        progress: 0.7,
      ),
      Achievement(
        id: 'love_first_challenge',
        title: '甜蜜挑战',
        description: '发送第一个菜谱挑战',
        emoji: '💕',
        category: AchievementCategory.love,
        level: AchievementLevel.bronze,
        points: 20,
        conditions: [
          AchievementCondition(
            type: 'action',
            target: 1,
            description: '发送1个挑战',
          ),
        ],
        isUnlocked: true,
        progress: 1.0,
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Achievement(
        id: 'explore_cuisines',
        title: '美食探索家',
        description: '解锁5个不同菜系',
        emoji: '🗺️',
        category: AchievementCategory.exploration,
        level: AchievementLevel.gold,
        points: 100,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 5,
            description: '解锁5个菜系',
          ),
        ],
        progress: 0.8,
      ),
      Achievement(
        id: 'memory_keeper',
        title: '回忆收藏家',
        description: '保存10个美好回忆',
        emoji: '📷',
        category: AchievementCategory.memory,
        level: AchievementLevel.silver,
        points: 30,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 10,
            description: '保存10个回忆',
          ),
        ],
        progress: 0.3,
      ),
    ];
  }

  /// 🔧 简化的进度加载
  void _loadSimpleProgress() {
    // 使用预设数据，避免复杂计算
    // 实际应用中可以从缓存加载
  }

  /// 解锁成就
  void unlockAchievement(String achievementId) {
    final updatedAchievements = state.map((achievement) {
      if (achievement.id == achievementId && !achievement.isUnlocked) {
        HapticFeedback.heavyImpact();
        return achievement.copyWith(
          isUnlocked: true,
          progress: 1.0,
          unlockedAt: DateTime.now(),
        );
      }
      return achievement;
    }).toList();
    
    state = updatedAchievements;
  }

  /// 更新进度
  void updateProgress(String achievementId, double progress) {
    final updatedAchievements = state.map((achievement) {
      if (achievement.id == achievementId) {
        final newProgress = progress.clamp(0.0, 1.0);
        if (newProgress >= 1.0 && !achievement.isUnlocked) {
          HapticFeedback.heavyImpact();
          return achievement.copyWith(
            progress: newProgress,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
        return achievement.copyWith(progress: newProgress);
      }
      return achievement;
    }).toList();
    
    state = updatedAchievements;
  }
}

/// 🔧 性能优化的Provider定义
final achievementProviderOptimized = StateNotifierProvider<AchievementNotifierOptimized, List<Achievement>>((ref) {
  return AchievementNotifierOptimized();
});

/// 🔧 简化的统计信息Provider
final achievementStatisticsProviderOptimized = Provider<Map<String, dynamic>>((ref) {
  final achievements = ref.watch(achievementProviderOptimized);
  
  final unlockedCount = achievements.where((a) => a.isUnlocked).length;
  final totalPoints = achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + a.points);
  
  return {
    'totalCount': achievements.length,
    'unlockedCount': unlockedCount,
    'totalPoints': totalPoints,
    'completionRate': unlockedCount / achievements.length,
  };
});

/// 🔧 简化的用户等级Provider
final userLevelProviderOptimized = Provider<Map<String, dynamic>>((ref) {
  final statistics = ref.watch(achievementStatisticsProviderOptimized);
  final totalPoints = statistics['totalPoints'] as int;
  
  if (totalPoints >= 200) {
    return {'level': '厨房新星', 'emoji': '⭐', 'color': Color(0xFFC0C0C0)};
  } else if (totalPoints >= 100) {
    return {'level': '美食爱好者', 'emoji': '🍴', 'color': Color(0xFFCD7F32)};
  } else {
    return {'level': '美食萌新', 'emoji': '🌱', 'color': Color(0xFF90EE90)};
  }
});

/// 🔧 简化的已解锁成就Provider
final unlockedAchievementsProviderOptimized = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProviderOptimized);
  return achievements.where((a) => a.isUnlocked).toList();
});

/// 🔧 简化的即将完成成就Provider
final nearCompleteAchievementsProviderOptimized = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProviderOptimized);
  return achievements.where((a) => a.progress >= 0.8 && !a.isUnlocked).toList();
});