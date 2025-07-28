import 'package:flutter/material.dart';

/// 🥰 亲密度等级枚举
enum IntimacyTier {
  seedling,    // 萌芽期 🌱
  budding,     // 初恋期 🌸
  blooming,    // 热恋期 🌹
  mature,      // 稳定期 💕
  soulmate,    // 心有灵犀 💝
}

/// 🥰 互动行为类型
enum InteractionType {
  cookTogether,      // 一起做菜
  shareRecipe,       // 分享菜谱
  sendChallenge,     // 发送挑战
  completeChallenge, // 完成挑战
  saveMemory,        // 保存回忆
  dailyCheckIn,      // 每日签到
  sweetMessage,      // 甜蜜留言
  photoShare,        // 分享照片
}

/// 🥰 亲密度等级模型
class IntimacyLevel {
  final IntimacyTier tier;
  final String title;
  final String description;
  final String emoji;
  final int requiredPoints;
  final Color themeColor;
  final List<String> unlockFeatures;

  const IntimacyLevel({
    required this.tier,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredPoints,
    required this.themeColor,
    required this.unlockFeatures,
  });

  /// 获取等级进度百分比
  double getProgressPercentage(int currentPoints) {
    if (currentPoints >= requiredPoints) return 1.0;
    
    // 获取上一级的点数要求
    final previousLevelPoints = _getPreviousLevelPoints();
    final pointsNeeded = requiredPoints - previousLevelPoints;
    final currentProgress = currentPoints - previousLevelPoints;
    
    return (currentProgress / pointsNeeded).clamp(0.0, 1.0);
  }

  int _getPreviousLevelPoints() {
    switch (tier) {
      case IntimacyTier.seedling:
        return 0;
      case IntimacyTier.budding:
        return 100;
      case IntimacyTier.blooming:
        return 300;
      case IntimacyTier.mature:
        return 600;
      case IntimacyTier.soulmate:
        return 1000;
    }
  }

  /// 预定义的亲密度等级
  static const List<IntimacyLevel> allLevels = [
    IntimacyLevel(
      tier: IntimacyTier.seedling,
      title: '萌芽期',
      description: '刚刚开始的美好旅程',
      emoji: '🌱',
      requiredPoints: 100,
      themeColor: Color(0xFF90EE90),
      unlockFeatures: ['基础菜谱分享', '简单互动'],
    ),
    IntimacyLevel(
      tier: IntimacyTier.budding,
      title: '初恋期',
      description: '甜蜜的初相识时光',
      emoji: '🌸',
      requiredPoints: 300,
      themeColor: Color(0xFFFFB6C1),
      unlockFeatures: ['挑战功能', '照片分享', '甜蜜留言'],
    ),
    IntimacyLevel(
      tier: IntimacyTier.blooming,
      title: '热恋期',
      description: '激情四射的美好时光',
      emoji: '🌹',
      requiredPoints: 600,
      themeColor: Color(0xFFFF69B4),
      unlockFeatures: ['情侣模式', '3D时光机', '专属徽章'],
    ),
    IntimacyLevel(
      tier: IntimacyTier.mature,
      title: '稳定期',
      description: '相濡以沫的默契生活',
      emoji: '💕',
      requiredPoints: 1000,
      themeColor: Color(0xFFDC143C),
      unlockFeatures: ['AI智能推荐', '纪念日提醒', '成长报告'],
    ),
    IntimacyLevel(
      tier: IntimacyTier.soulmate,
      title: '心有灵犀',
      description: '心灵相通的最高境界',
      emoji: '💝',
      requiredPoints: 1500,
      themeColor: Color(0xFFB8860B),
      unlockFeatures: ['所有功能', '专属称号', '纪念册'],
    ),
  ];

  /// 根据点数获取当前等级
  static IntimacyLevel getCurrentLevel(int points) {
    for (int i = allLevels.length - 1; i >= 0; i--) {
      if (points >= allLevels[i].requiredPoints) {
        return allLevels[i];
      }
    }
    return allLevels.first;
  }

  /// 获取下一等级
  IntimacyLevel? getNextLevel() {
    final currentIndex = allLevels.indexOf(this);
    if (currentIndex < allLevels.length - 1) {
      return allLevels[currentIndex + 1];
    }
    return null;
  }
}

/// 🥰 互动行为模型
class InteractionBehavior {
  final InteractionType type;
  final String title;
  final String description;
  final String emoji;
  final int basePoints;
  final int dailyLimit;
  final Color iconColor;

  const InteractionBehavior({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.basePoints,
    required this.dailyLimit,
    required this.iconColor,
  });

  /// 预定义的互动行为
  static const List<InteractionBehavior> allBehaviors = [
    InteractionBehavior(
      type: InteractionType.cookTogether,
      title: '一起做菜',
      description: '共同制作一道美食',
      emoji: '👫',
      basePoints: 20,
      dailyLimit: 3,
      iconColor: Color(0xFFFF6B6B),
    ),
    InteractionBehavior(
      type: InteractionType.shareRecipe,
      title: '分享菜谱',
      description: '向对方分享喜爱的菜谱',
      emoji: '📤',
      basePoints: 10,
      dailyLimit: 5,
      iconColor: Color(0xFF4ECDC4),
    ),
    InteractionBehavior(
      type: InteractionType.sendChallenge,
      title: '发送挑战',
      description: '发起烹饪挑战',
      emoji: '🎯',
      basePoints: 15,
      dailyLimit: 2,
      iconColor: Color(0xFFFFE66D),
    ),
    InteractionBehavior(
      type: InteractionType.completeChallenge,
      title: '完成挑战',
      description: '成功完成对方的挑战',
      emoji: '✅',
      basePoints: 25,
      dailyLimit: 2,
      iconColor: Color(0xFF95E1D3),
    ),
    InteractionBehavior(
      type: InteractionType.saveMemory,
      title: '保存回忆',
      description: '记录美好的用餐时光',
      emoji: '📷',
      basePoints: 12,
      dailyLimit: 3,
      iconColor: Color(0xFFB8860B),
    ),
    InteractionBehavior(
      type: InteractionType.dailyCheckIn,
      title: '每日签到',
      description: '坚持每天的爱的打卡',
      emoji: '📅',
      basePoints: 5,
      dailyLimit: 1,
      iconColor: Color(0xFF90EE90),
    ),
    InteractionBehavior(
      type: InteractionType.sweetMessage,
      title: '甜蜜留言',
      description: '给对方留下温暖的话语',
      emoji: '💌',
      basePoints: 8,
      dailyLimit: 10,
      iconColor: Color(0xFFFFB6C1),
    ),
    InteractionBehavior(
      type: InteractionType.photoShare,
      title: '分享照片',
      description: '分享美食或生活照片',
      emoji: '🖼️',
      basePoints: 6,
      dailyLimit: 5,
      iconColor: Color(0xFFDDA0DD),
    ),
  ];

  /// 根据类型获取行为
  static InteractionBehavior? getBehavior(InteractionType type) {
    try {
      return allBehaviors.firstWhere((behavior) => behavior.type == type);
    } catch (e) {
      return null;
    }
  }
}

/// 🥰 互动记录模型
class InteractionRecord {
  final String id;
  final InteractionType type;
  final DateTime timestamp;
  final int pointsEarned;
  final Map<String, dynamic>? metadata;

  const InteractionRecord({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.pointsEarned,
    this.metadata,
  });

  /// 从JSON创建记录
  factory InteractionRecord.fromJson(Map<String, dynamic> json) {
    return InteractionRecord(
      id: json['id'] as String,
      type: InteractionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => InteractionType.dailyCheckIn,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      pointsEarned: json['pointsEarned'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  /// 获取记录的显示文本
  String getDisplayText() {
    final behavior = InteractionBehavior.getBehavior(type);
    return behavior?.title ?? '互动行为';
  }

  /// 获取记录的emoji
  String getEmoji() {
    final behavior = InteractionBehavior.getBehavior(type);
    return behavior?.emoji ?? '❤️';
  }
}