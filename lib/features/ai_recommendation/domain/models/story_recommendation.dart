import 'package:flutter/material.dart';

/// 故事化推荐数据模型
/// 基于用户生活情境生成的智能推荐
class StoryRecommendation {
  /// 情境标签（天气/时间/事件）
  final String context;
  
  /// 故事化描述文案
  final String narrative;
  
  /// 推荐的菜谱名称
  final String recipe;
  
  /// 推荐理由
  final String reason;
  
  /// 菜谱图标emoji
  final String icon;
  
  /// 推荐类型（5%彩色焦点时使用）
  final RecommendationType type;
  
  /// 营养提示
  final String? nutritionTip;
  
  /// 关联的菜谱ID
  final String? recipeId;
  
  /// 预计烹饪时间（分钟）
  final int? cookingTime;
  
  /// 难度等级（1-5）
  final int? difficulty;

  const StoryRecommendation({
    required this.context,
    required this.narrative,
    required this.recipe,
    required this.reason,
    required this.icon,
    required this.type,
    this.nutritionTip,
    this.recipeId,
    this.cookingTime,
    this.difficulty,
  });

  /// 获取推荐类型对应的渐变色（5%彩色焦点）
  LinearGradient get gradient {
    switch (type) {
      case RecommendationType.weather:
        return const LinearGradient(
          colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RecommendationType.nutrition:
        return const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RecommendationType.special:
        return const LinearGradient(
          colors: [Color(0xFFEE9CA7), Color(0xFFFFDDE1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case RecommendationType.mood:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// 从JSON创建实例
  factory StoryRecommendation.fromJson(Map<String, dynamic> json) {
    return StoryRecommendation(
      context: json['context'] as String,
      narrative: json['narrative'] as String,
      recipe: json['recipe'] as String,
      reason: json['reason'] as String,
      icon: json['icon'] as String,
      type: RecommendationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecommendationType.mood,
      ),
      nutritionTip: json['nutritionTip'] as String?,
      recipeId: json['recipeId'] as String?,
      cookingTime: json['cookingTime'] as int?,
      difficulty: json['difficulty'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'context': context,
      'narrative': narrative,
      'recipe': recipe,
      'reason': reason,
      'icon': icon,
      'type': type.name,
      'nutritionTip': nutritionTip,
      'recipeId': recipeId,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryRecommendation && 
           other.recipe == recipe && 
           other.context == context;
  }

  @override
  int get hashCode => recipe.hashCode ^ context.hashCode;
}

/// 推荐类型枚举
enum RecommendationType {
  /// 基于天气推荐
  weather,
  
  /// 基于营养均衡推荐
  nutrition,
  
  /// 基于特殊日子推荐
  special,
  
  /// 基于心情推荐
  mood,
}

/// 推荐数据预设
class RecommendationData {
  static List<StoryRecommendation> getSampleRecommendations() {
    return [
      StoryRecommendation(
        context: '降温预警',
        narrative: '今晚降到15度，一碗热汤最暖心',
        recipe: '奶油蘑菇汤',
        reason: '基于天气变化推荐',
        icon: '🍄',
        type: RecommendationType.weather,
        nutritionTip: '蘑菇富含维生素D，有助于增强免疫力',
        cookingTime: 30,
        difficulty: 2,
      ),
      StoryRecommendation(
        context: '营养提醒',
        narrative: '已经3天没吃绿叶菜了哦',
        recipe: '蒜蓉西兰花',
        reason: '基于营养均衡推荐',
        icon: '🥦',
        type: RecommendationType.nutrition,
        nutritionTip: '西兰花富含维生素C，比橙子还高',
        cookingTime: 15,
        difficulty: 1,
      ),
      StoryRecommendation(
        context: '特殊日子',
        narrative: '还有2天就是你们的纪念日',
        recipe: '红丝绒蛋糕',
        reason: '基于日历事件推荐',
        icon: '🎂',
        type: RecommendationType.special,
        nutritionTip: '甜蜜时光，适量享用哦',
        cookingTime: 120,
        difficulty: 4,
      ),
      StoryRecommendation(
        context: '心情感知',
        narrative: '最近压力有点大，来点治愈系美食',
        recipe: '日式茶碗蒸',
        reason: '基于情绪分析推荐',
        icon: '🥚',
        type: RecommendationType.mood,
        nutritionTip: '温润的茶碗蒸有助于舒缓情绪',
        cookingTime: 25,
        difficulty: 2,
      ),
    ];
  }
}