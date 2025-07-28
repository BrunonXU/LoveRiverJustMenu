import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/intimacy_level.dart';

/// 🥰 亲密度状态类
class IntimacyState {
  final int totalPoints;
  final IntimacyLevel currentLevel;
  final List<InteractionRecord> recentInteractions;
  final Map<InteractionType, int> dailyInteractionCounts;
  final DateTime lastUpdateDate;

  const IntimacyState({
    required this.totalPoints,
    required this.currentLevel,
    required this.recentInteractions,
    required this.dailyInteractionCounts,
    required this.lastUpdateDate,
  });

  IntimacyState copyWith({
    int? totalPoints,
    IntimacyLevel? currentLevel,
    List<InteractionRecord>? recentInteractions,
    Map<InteractionType, int>? dailyInteractionCounts,
    DateTime? lastUpdateDate,
  }) {
    return IntimacyState(
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      recentInteractions: recentInteractions ?? this.recentInteractions,
      dailyInteractionCounts: dailyInteractionCounts ?? this.dailyInteractionCounts,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
    );
  }
}

/// 🥰 亲密度状态管理器
class IntimacyNotifier extends StateNotifier<IntimacyState> {
  IntimacyNotifier() : super(_getInitialState()) {
    _loadFromStorage();
  }

  /// 初始状态
  static IntimacyState _getInitialState() {
    return IntimacyState(
      totalPoints: 150, // 初始化一些点数用于演示
      currentLevel: IntimacyLevel.getCurrentLevel(150),
      recentInteractions: _getInitialInteractions(),
      dailyInteractionCounts: {},
      lastUpdateDate: DateTime.now(),
    );
  }

  /// 初始化一些演示互动记录
  static List<InteractionRecord> _getInitialInteractions() {
    return [
      InteractionRecord(
        id: 'demo_1',
        type: InteractionType.cookTogether,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        pointsEarned: 20,
        metadata: {'recipeName': '番茄炒蛋'},
      ),
      InteractionRecord(
        id: 'demo_2',
        type: InteractionType.shareRecipe,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        pointsEarned: 10,
        metadata: {'recipeName': '红烧肉'},
      ),
      InteractionRecord(
        id: 'demo_3',
        type: InteractionType.dailyCheckIn,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        pointsEarned: 5,
      ),
      InteractionRecord(
        id: 'demo_4',
        type: InteractionType.sweetMessage,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        pointsEarned: 8,
        metadata: {'message': '今天的菜很好吃哦～'},
      ),
    ];
  }

  /// 从存储加载数据（实际应用中会从数据库或文件加载）
  void _loadFromStorage() {
    // 这里应该从持久化存储加载数据
    // 目前使用演示数据
  }

  /// 记录互动行为
  Future<bool> recordInteraction(InteractionType type, {Map<String, dynamic>? metadata}) async {
    final behavior = InteractionBehavior.getBehavior(type);
    if (behavior == null) return false;

    // 检查今日是否达到上限
    final today = DateTime.now();
    if (!_isSameDay(state.lastUpdateDate, today)) {
      // 新的一天，重置计数
      state = state.copyWith(
        dailyInteractionCounts: {},
        lastUpdateDate: today,
      );
    }

    final todayCount = state.dailyInteractionCounts[type] ?? 0;
    if (todayCount >= behavior.dailyLimit) {
      return false; // 已达到今日上限
    }

    // 创建互动记录
    final record = InteractionRecord(
      id: 'interaction_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      timestamp: today,
      pointsEarned: behavior.basePoints,
      metadata: metadata,
    );

    // 更新状态
    final newTotalPoints = state.totalPoints + behavior.basePoints;
    final newLevel = IntimacyLevel.getCurrentLevel(newTotalPoints);
    final newRecentInteractions = [record, ...state.recentInteractions.take(19)].toList();
    final newDailyCounts = Map<InteractionType, int>.from(state.dailyInteractionCounts);
    newDailyCounts[type] = todayCount + 1;

    // 检查是否升级
    final levelUp = newLevel.tier != state.currentLevel.tier;
    
    state = state.copyWith(
      totalPoints: newTotalPoints,
      currentLevel: newLevel,
      recentInteractions: newRecentInteractions,
      dailyInteractionCounts: newDailyCounts,
      lastUpdateDate: today,
    );

    // 触觉反馈
    if (levelUp) {
      HapticFeedback.heavyImpact(); // 升级时强烈反馈
      _showLevelUpDialog();
    } else {
      HapticFeedback.lightImpact(); // 普通互动轻微反馈
    }

    await _saveToStorage();
    return true;
  }

  /// 检查是否为同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 显示升级对话框（这里只是标记，实际实现在UI层）
  void _showLevelUpDialog() {
    // UI层会监听状态变化并显示升级动画
  }

  /// 保存到存储
  Future<void> _saveToStorage() async {
    // 这里应该保存到持久化存储
    // 实际应用中会保存到SharedPreferences或数据库
  }

  /// 获取今日可获得的剩余点数
  int getTodayRemainingPoints() {
    int remainingPoints = 0;
    
    for (final behavior in InteractionBehavior.allBehaviors) {
      final todayCount = state.dailyInteractionCounts[behavior.type] ?? 0;
      final remainingCount = behavior.dailyLimit - todayCount;
      if (remainingCount > 0) {
        remainingPoints += remainingCount * behavior.basePoints;
      }
    }
    
    return remainingPoints;
  }

  /// 获取到下一级需要的点数
  int getPointsToNextLevel() {
    final nextLevel = state.currentLevel.getNextLevel();
    if (nextLevel == null) return 0;
    return nextLevel.requiredPoints - state.totalPoints;
  }

  /// 获取当前等级进度
  double getCurrentLevelProgress() {
    final nextLevel = state.currentLevel.getNextLevel();
    if (nextLevel == null) return 1.0;
    return nextLevel.getProgressPercentage(state.totalPoints);
  }

  /// 获取特定行为今日剩余次数
  int getRemainingCount(InteractionType type) {
    final behavior = InteractionBehavior.getBehavior(type);
    if (behavior == null) return 0;
    
    final todayCount = state.dailyInteractionCounts[type] ?? 0;
    return (behavior.dailyLimit - todayCount).clamp(0, behavior.dailyLimit);
  }

  /// 获取本周互动统计
  Map<String, int> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weeklyInteractions = state.recentInteractions
        .where((record) => record.timestamp.isAfter(weekAgo))
        .toList();
    
    final stats = <String, int>{
      'totalInteractions': weeklyInteractions.length,
      'pointsEarned': weeklyInteractions.fold(0, (sum, record) => sum + record.pointsEarned),
      'averageDaily': (weeklyInteractions.length / 7).round(),
    };
    
    return stats;
  }

  /// 获取连续签到天数
  int getConsecutiveCheckInDays() {
    var consecutiveDays = 0;
    var currentDate = DateTime.now();
    
    for (var i = 0; i < 30; i++) { // 最多检查30天
      final hasCheckIn = state.recentInteractions.any((record) =>
          record.type == InteractionType.dailyCheckIn &&
          _isSameDay(record.timestamp, currentDate));
      
      if (hasCheckIn) {
        consecutiveDays++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }
}

/// 🥰 Provider定义
final intimacyProvider = StateNotifierProvider<IntimacyNotifier, IntimacyState>((ref) {
  return IntimacyNotifier();
});

/// 当前亲密度等级Provider
final currentIntimacyLevelProvider = Provider<IntimacyLevel>((ref) {
  final intimacyState = ref.watch(intimacyProvider);
  return intimacyState.currentLevel;
});

/// 下一等级Provider
final nextIntimacyLevelProvider = Provider<IntimacyLevel?>((ref) {
  final currentLevel = ref.watch(currentIntimacyLevelProvider);
  return currentLevel.getNextLevel();
});

/// 等级进度Provider
final intimacyProgressProvider = Provider<double>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  return notifier.getCurrentLevelProgress();
});

/// 今日剩余点数Provider
final todayRemainingPointsProvider = Provider<int>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  return notifier.getTodayRemainingPoints();
});

/// 到下一级所需点数Provider  
final pointsToNextLevelProvider = Provider<int>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  return notifier.getPointsToNextLevel();
});

/// 本周统计Provider
final weeklyStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  return notifier.getWeeklyStats();
});

/// 连续签到天数Provider
final consecutiveCheckInDaysProvider = Provider<int>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  return notifier.getConsecutiveCheckInDays();
});

/// 可用互动行为Provider（过滤掉今日已达上限的）
final availableInteractionsProvider = Provider<List<InteractionBehavior>>((ref) {
  final notifier = ref.watch(intimacyProvider.notifier);
  
  return InteractionBehavior.allBehaviors.where((behavior) {
    final remaining = notifier.getRemainingCount(behavior.type);
    return remaining > 0;
  }).toList();
});