import 'package:flutter/material.dart';

/// 成就类型枚举
enum AchievementCategory {
  cooking,    // 烹饪技能
  love,       // 爱情指数
  exploration, // 探索精神
  creativity,  // 创意料理
  memory,     // 美食记忆
  challenge,  // 挑战精神
}

/// 成就等级枚举
enum AchievementLevel {
  bronze,   // 青铜 - 入门级
  silver,   // 白银 - 进阶级
  gold,     // 黄金 - 高级
  diamond,  // 钻石 - 大师级
  legendary, // 传说 - 传奇级
}

/// 成就解锁条件
class AchievementCondition {
  final String type;        // 条件类型: 'count', 'streak'等
  final dynamic target;     // 目标值
  final String description; // 条件描述

  const AchievementCondition({
    required this.type,
    required this.target,
    required this.description,
  });
}

/// 成就模型
class Achievement {
  final String id;
  final String title;           // 成就标题
  final String description;     // 成就描述
  final String emoji;          // 成就图标
  final AchievementCategory category;
  final AchievementLevel level;
  final int points;            // 成就积分
  final List<AchievementCondition> conditions; // 解锁条件
  final bool isUnlocked;       // 是否已解锁
  final DateTime? unlockedAt;  // 解锁时间
  final double progress;       // 完成进度 (0.0 - 1.0)
  final bool isSecret;         // 是否为隐藏成就
  final String? tip;           // 解锁提示

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.level,
    required this.points,
    required this.conditions,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
    this.isSecret = false,
    this.tip,
  });

  /// 获取成就等级颜色
  Color get levelColor {
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

  /// 获取成就等级名称
  String get levelName {
    switch (level) {
      case AchievementLevel.bronze:
        return '青铜';
      case AchievementLevel.silver:
        return '白银';
      case AchievementLevel.gold:
        return '黄金';
      case AchievementLevel.diamond:
        return '钻石';
      case AchievementLevel.legendary:
        return '传说';
    }
  }

  /// 获取分类名称
  String get categoryName {
    switch (category) {
      case AchievementCategory.cooking:
        return '烹饪技能';
      case AchievementCategory.love:
        return '爱情指数';
      case AchievementCategory.exploration:
        return '探索精神';
      case AchievementCategory.creativity:
        return '创意料理';
      case AchievementCategory.memory:
        return '美食记忆';
      case AchievementCategory.challenge:
        return '挑战精神';
    }
  }

  /// 是否接近完成 (进度 >= 80%)
  bool get isNearComplete => progress >= 0.8;

  /// 复制成就并更新属性
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    AchievementCategory? category,
    AchievementLevel? level,
    int? points,
    List<AchievementCondition>? conditions,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
    bool? isSecret,
    String? tip,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      level: level ?? this.level,
      points: points ?? this.points,
      conditions: conditions ?? this.conditions,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      isSecret: isSecret ?? this.isSecret,
      tip: tip ?? this.tip,
    );
  }
}

/// 厨房恋人成长树数据
class AchievementData {
  /// 获取所有预定义成就
  static List<Achievement> getAllAchievements() {
    return [
      // 🍳 烹饪技能类
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
      ),

      Achievement(
        id: 'cooking_chef',
        title: '小厨神',
        description: '成功创建10个菜谱',
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
      ),

      Achievement(
        id: 'cooking_master',
        title: '料理大师',
        description: '成功创建50个菜谱',
        emoji: '🏆',
        category: AchievementCategory.cooking,
        level: AchievementLevel.gold,
        points: 200,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 50,
            description: '创建50个菜谱',
          ),
        ],
      ),

      // 💕 爱情指数类
      Achievement(
        id: 'love_first_challenge',
        title: '爱的初体验',
        description: '发送第一个料理挑战',
        emoji: '💕',
        category: AchievementCategory.love,
        level: AchievementLevel.bronze,
        points: 15,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 1,
            description: '发送1个挑战',
          ),
        ],
      ),

      Achievement(
        id: 'love_sweet_couple',
        title: '甜蜜情侣',
        description: '与恋人完成10次互动挑战',
        emoji: '💖',
        category: AchievementCategory.love,
        level: AchievementLevel.silver,
        points: 80,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 10,
            description: '完成10次挑战',
          ),
        ],
      ),

      Achievement(
        id: 'love_soulmate',
        title: '灵魂伴侣',
        description: '与恋人完成50次互动挑战',
        emoji: '👫',
        category: AchievementCategory.love,
        level: AchievementLevel.gold,
        points: 300,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 50,
            description: '完成50次挑战',
          ),
        ],
      ),

      // 🌟 探索精神类
      Achievement(
        id: 'explore_cuisines',
        title: '美食探险家',
        description: '尝试5种不同菜系',
        emoji: '🌟',
        category: AchievementCategory.exploration,
        level: AchievementLevel.bronze,
        points: 25,
        conditions: [
          AchievementCondition(
            type: 'variety',
            target: 5,
            description: '尝试5种菜系',
          ),
        ],
      ),

      Achievement(
        id: 'explore_master',
        title: '环球美食家',
        description: '尝试15种不同菜系',
        emoji: '🌍',
        category: AchievementCategory.exploration,
        level: AchievementLevel.gold,
        points: 150,
        conditions: [
          AchievementCondition(
            type: 'variety',
            target: 15,
            description: '尝试15种菜系',
          ),
        ],
      ),

      // 🎨 创意料理类
      Achievement(
        id: 'creative_fusion',
        title: '创意厨师',
        description: '创造一道融合菜',
        emoji: '🎨',
        category: AchievementCategory.creativity,
        level: AchievementLevel.silver,
        points: 60,
        conditions: [
          AchievementCondition(
            type: 'special',
            target: 'fusion_recipe',
            description: '创建融合菜谱',
          ),
        ],
        tip: '尝试将不同地区的烹饪方法结合',
      ),

      // 📸 美食记忆类
      Achievement(
        id: 'memory_keeper',
        title: '回忆收藏家',
        description: '记录10个美食时光',
        emoji: '📸',
        category: AchievementCategory.memory,
        level: AchievementLevel.silver,
        points: 70,
        conditions: [
          AchievementCondition(
            type: 'count',
            target: 10,
            description: '记录10个美食回忆',
          ),
        ],
      ),

      // 🏅 挑战精神类
      Achievement(
        id: 'challenge_winner',
        title: '挑战之王',
        description: '连续获得5次5星评价',
        emoji: '🏅',
        category: AchievementCategory.challenge,
        level: AchievementLevel.gold,
        points: 250,
        conditions: [
          AchievementCondition(
            type: 'streak',
            target: 5,
            description: '连续5次5星评价',
          ),
        ],
      ),

      // 🎭 隐藏成就类
      Achievement(
        id: 'secret_midnight_chef',
        title: '深夜料理人',
        description: '在午夜时分完成一道菜',
        emoji: '🌙',
        category: AchievementCategory.cooking,
        level: AchievementLevel.diamond,
        points: 100,
        conditions: [
          AchievementCondition(
            type: 'time',
            target: 'midnight',
            description: '在00:00-02:00完成料理',
          ),
        ],
        isSecret: true,
        tip: '有些美味只在夜深人静时诞生...',
      ),

      Achievement(
        id: 'secret_perfect_timing',
        title: '完美时机',
        description: '在恋人生日当天送出挑战',
        emoji: '🎂',
        category: AchievementCategory.love,
        level: AchievementLevel.legendary,
        points: 500,
        conditions: [
          AchievementCondition(
            type: 'special',
            target: 'birthday_challenge',
            description: '生日当天发送挑战',
          ),
        ],
        isSecret: true,
        tip: '爱在每一个特殊的日子里绽放',
      ),
    ];
  }

  /// 根据分类获取成就
  static List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return getAllAchievements().where((a) => a.category == category).toList();
  }

  /// 获取用户当前总积分
  static int getTotalPoints(List<Achievement> unlockedAchievements) {
    return unlockedAchievements.fold(0, (sum, achievement) => sum + achievement.points);
  }

  /// 根据积分计算用户等级
  static Map<String, dynamic> getUserLevel(int totalPoints) {
    if (totalPoints >= 2000) {
      return {'level': '传奇恋人', 'emoji': '👑', 'color': const Color(0xFFFF6B6B)};
    } else if (totalPoints >= 1000) {
      return {'level': '料理情侣', 'emoji': '💎', 'color': const Color(0xFFB9F2FF)};
    } else if (totalPoints >= 500) {
      return {'level': '甜蜜厨神', 'emoji': '🏆', 'color': const Color(0xFFFFD700)};
    } else if (totalPoints >= 200) {
      return {'level': '厨房新星', 'emoji': '⭐', 'color': const Color(0xFFC0C0C0)};
    } else {
      return {'level': '美食萌新', 'emoji': '🌱', 'color': const Color(0xFFCD7F32)};
    }
  }
}