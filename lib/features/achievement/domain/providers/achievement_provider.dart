import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';

/// 成就系统状态管理
class AchievementNotifier extends StateNotifier<List<Achievement>> {
  AchievementNotifier() : super(AchievementData.getAllAchievements()) {
    _loadAchievements();
  }

  /// 从本地存储加载成就数据
  void _loadAchievements() {
    // TODO: 从Hive数据库加载实际的成就进度
    // 目前使用模拟数据进行演示
    _simulateProgress();
  }

  /// 模拟成就进度 - 演示用
  void _simulateProgress() {
    final updatedAchievements = state.map((achievement) {
      switch (achievement.id) {
        case 'cooking_first_recipe':
          return achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
            progress: 1.0,
          );
        case 'cooking_chef':
          return achievement.copyWith(
            progress: 0.7, // 7/10 进度
          );
        case 'love_first_challenge':
          return achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
            progress: 1.0,
          );
        case 'love_sweet_couple':
          return achievement.copyWith(
            progress: 0.4, // 4/10 进度
          );
        case 'explore_cuisines':
          return achievement.copyWith(
            progress: 0.8, // 4/5 进度，接近完成
          );
        case 'memory_keeper':
          return achievement.copyWith(
            progress: 0.3, // 3/10 进度
          );
        default:
          return achievement;
      }
    }).toList();

    state = updatedAchievements;
  }

  /// 更新成就进度
  void updateProgress(String achievementId, double newProgress) {
    final updatedAchievements = state.map((achievement) {
      if (achievement.id == achievementId) {
        final updated = achievement.copyWith(progress: newProgress.clamp(0.0, 1.0));
        
        // 如果达到100%且未解锁，则解锁成就
        if (updated.progress >= 1.0 && !updated.isUnlocked) {
          _unlockAchievement(achievementId);
          return updated.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
        
        return updated;
      }
      return achievement;
    }).toList();

    state = updatedAchievements;
  }

  /// 解锁成就 - 触发庆祝动画和反馈
  void _unlockAchievement(String achievementId) {
    final achievement = state.firstWhere((a) => a.id == achievementId);
    
    // 触觉反馈
    HapticFeedback.heavyImpact();
    
    // TODO: 显示成就解锁动画
    // TODO: 播放庆祝音效
    // TODO: 发送通知给恋人
    
    print('🎉 恭喜解锁成就: ${achievement.title}');
  }

  /// 根据用户行为触发成就检查
  void checkAchievements({
    int? recipesCreated,
    int? challengesSent,
    int? challengesCompleted,
    int? memoriesAdded,
    List<String>? cuisineTypes,
    bool? isMidnight,
    bool? isBirthday,
  }) {
    // 检查烹饪成就
    if (recipesCreated != null) {
      _checkCookingAchievements(recipesCreated);
    }

    // 检查爱情成就
    if (challengesSent != null) {
      _checkLoveAchievements(challengesSent, challengesCompleted ?? 0);
    }

    // 检查探索成就
    if (cuisineTypes != null) {
      _checkExplorationAchievements(cuisineTypes);
    }

    // 检查记忆成就
    if (memoriesAdded != null) {
      _checkMemoryAchievements(memoriesAdded);
    }

    // 检查隐藏成就
    _checkSecretAchievements(
      isMidnight: isMidnight,
      isBirthday: isBirthday,
    );
  }

  void _checkCookingAchievements(int recipesCreated) {
    // 检查"初试牛刀" (1个菜谱)
    if (recipesCreated >= 1) {
      updateProgress('cooking_first_recipe', 1.0);
    }
    
    // 检查"小厨神" (10个菜谱)
    updateProgress('cooking_chef', (recipesCreated / 10).clamp(0.0, 1.0));
    
    // 检查"料理大师" (50个菜谱)
    updateProgress('cooking_master', (recipesCreated / 50).clamp(0.0, 1.0));
  }

  void _checkLoveAchievements(int challengesSent, int challengesCompleted) {
    // 检查"爱的初体验" (1个挑战)
    if (challengesSent >= 1) {
      updateProgress('love_first_challenge', 1.0);
    }
    
    // 检查"甜蜜情侣" (10次互动)
    updateProgress('love_sweet_couple', (challengesCompleted / 10).clamp(0.0, 1.0));
    
    // 检查"灵魂伴侣" (50次互动)
    updateProgress('love_soulmate', (challengesCompleted / 50).clamp(0.0, 1.0));
  }

  void _checkExplorationAchievements(List<String> cuisineTypes) {
    final uniqueCuisines = cuisineTypes.toSet().length;
    
    // 检查"美食探险家" (5种菜系)
    updateProgress('explore_cuisines', (uniqueCuisines / 5).clamp(0.0, 1.0));
    
    // 检查"环球美食家" (15种菜系)
    updateProgress('explore_master', (uniqueCuisines / 15).clamp(0.0, 1.0));
  }

  void _checkMemoryAchievements(int memoriesAdded) {
    // 检查"回忆收藏家" (10个回忆)
    updateProgress('memory_keeper', (memoriesAdded / 10).clamp(0.0, 1.0));
  }

  void _checkSecretAchievements({
    bool? isMidnight,
    bool? isBirthday,
  }) {
    // 检查"深夜料理人"
    if (isMidnight == true) {
      updateProgress('secret_midnight_chef', 1.0);
    }
    
    // 检查"完美时机"
    if (isBirthday == true) {
      updateProgress('secret_perfect_timing', 1.0);
    }
  }

  /// 获取已解锁的成就
  List<Achievement> get unlockedAchievements {
    return state.where((a) => a.isUnlocked).toList();
  }

  /// 获取接近完成的成就
  List<Achievement> get nearCompleteAchievements {
    return state.where((a) => !a.isUnlocked && a.isNearComplete).toList();
  }

  /// 获取按分类分组的成就
  Map<AchievementCategory, List<Achievement>> get achievementsByCategory {
    final Map<AchievementCategory, List<Achievement>> grouped = {};
    
    for (final category in AchievementCategory.values) {
      grouped[category] = state.where((a) => a.category == category).toList();
    }
    
    return grouped;
  }

  /// 获取用户总积分
  int get totalPoints {
    return AchievementData.getTotalPoints(unlockedAchievements);
  }

  /// 获取用户等级信息
  Map<String, dynamic> get userLevel {
    return AchievementData.getUserLevel(totalPoints);
  }

  /// 获取完成率统计
  Map<String, dynamic> get statistics {
    final total = state.length;
    final unlocked = unlockedAchievements.length;
    final inProgress = state.where((a) => !a.isUnlocked && a.progress > 0).length;
    
    return {
      'total': total,
      'unlocked': unlocked,
      'inProgress': inProgress,
      'completionRate': unlocked / total,
    };
  }
}

/// 成就系统Provider
final achievementProvider = StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  return AchievementNotifier();
});

/// 已解锁成就Provider
final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements.where((a) => a.isUnlocked).toList();
});

/// 接近完成成就Provider
final nearCompleteAchievementsProvider = Provider<List<Achievement>>((ref) {
  final achievements = ref.watch(achievementProvider);
  return achievements.where((a) => !a.isUnlocked && a.isNearComplete).toList();
});

/// 用户等级Provider
final userLevelProvider = Provider<Map<String, dynamic>>((ref) {
  final unlockedAchievements = ref.watch(unlockedAchievementsProvider);
  final totalPoints = AchievementData.getTotalPoints(unlockedAchievements);
  return AchievementData.getUserLevel(totalPoints);
});

/// 成就统计Provider
final achievementStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final achievements = ref.watch(achievementProvider);
  final unlocked = achievements.where((a) => a.isUnlocked).length;
  final inProgress = achievements.where((a) => !a.isUnlocked && a.progress > 0).length;
  
  return {
    'total': achievements.length,
    'unlocked': unlocked,
    'inProgress': inProgress,
    'completionRate': unlocked / achievements.length,
  };
});