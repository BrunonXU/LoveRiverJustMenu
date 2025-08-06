/// 🔄 菜谱更新信息模型
/// 
/// 用于跟踪菜谱的本地版本和云端版本差异
/// 支持智能更新标记和用户选择更新
/// 
/// 作者: Claude Code
/// 创建时间: 2025-08-06

import 'package:hive/hive.dart';

part 'recipe_update_info.g.dart';

/// 📊 菜谱更新信息
/// 
/// 记录菜谱的版本信息和更新状态
@HiveType(typeId: 20)
class RecipeUpdateInfo extends HiveObject {
  /// 菜谱ID
  @HiveField(0)
  final String recipeId;
  
  /// 本地版本时间戳
  @HiveField(1)
  final DateTime localVersion;
  
  /// 云端版本时间戳
  @HiveField(2)
  final DateTime cloudVersion;
  
  /// 变更的字段列表
  @HiveField(3)
  final List<String> changedFields;
  
  /// 更新检查时间
  @HiveField(4)
  final DateTime checkedAt;
  
  /// 用户是否忽略了这个更新
  @HiveField(5)
  final bool isIgnored;
  
  /// 更新重要性等级
  @HiveField(6)
  final UpdateImportance importance;
  
  /// 构造函数
  RecipeUpdateInfo({
    required this.recipeId,
    required this.localVersion,
    required this.cloudVersion,
    required this.changedFields,
    required this.checkedAt,
    this.isIgnored = false,
    this.importance = UpdateImportance.normal,
  });
  
  /// 是否有更新
  bool get hasUpdate => cloudVersion.isAfter(localVersion) && !isIgnored;
  
  /// 是否是重要更新
  bool get isImportantUpdate => importance == UpdateImportance.important;
  
  /// 是否是紧急更新
  bool get isCriticalUpdate => importance == UpdateImportance.critical;
  
  /// 更新时长（小时）
  int get updateAgeHours => DateTime.now().difference(cloudVersion).inHours;
  
  /// 是否是新更新（24小时内）
  bool get isRecentUpdate => updateAgeHours <= 24;
  
  /// 更新标记显示文本
  String get updateLabel {
    if (isCriticalUpdate) return '紧急更新';
    if (isImportantUpdate) return '重要更新';
    if (isRecentUpdate) return '新更新';
    return '有更新';
  }
  
  /// 更新标记颜色
  UpdateBadgeColor get badgeColor {
    if (isCriticalUpdate) return UpdateBadgeColor.red;
    if (isImportantUpdate) return UpdateBadgeColor.orange;
    if (isRecentUpdate) return UpdateBadgeColor.blue;
    return UpdateBadgeColor.green;
  }
  
  /// 创建更新的拷贝
  RecipeUpdateInfo copyWith({
    String? recipeId,
    DateTime? localVersion,
    DateTime? cloudVersion,
    List<String>? changedFields,
    DateTime? checkedAt,
    bool? isIgnored,
    UpdateImportance? importance,
  }) {
    return RecipeUpdateInfo(
      recipeId: recipeId ?? this.recipeId,
      localVersion: localVersion ?? this.localVersion,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      changedFields: changedFields ?? this.changedFields,
      checkedAt: checkedAt ?? this.checkedAt,
      isIgnored: isIgnored ?? this.isIgnored,
      importance: importance ?? this.importance,
    );
  }
  
  /// 标记为已忽略
  RecipeUpdateInfo markAsIgnored() {
    return copyWith(isIgnored: true);
  }
  
  /// 从Map创建实例
  factory RecipeUpdateInfo.fromMap(Map<String, dynamic> map) {
    return RecipeUpdateInfo(
      recipeId: map['recipeId'] as String,
      localVersion: DateTime.parse(map['localVersion'] as String),
      cloudVersion: DateTime.parse(map['cloudVersion'] as String),
      changedFields: List<String>.from(map['changedFields'] as List),
      checkedAt: DateTime.parse(map['checkedAt'] as String),
      isIgnored: map['isIgnored'] as bool? ?? false,
      importance: UpdateImportance.values.firstWhere(
        (e) => e.name == map['importance'],
        orElse: () => UpdateImportance.normal,
      ),
    );
  }
  
  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'localVersion': localVersion.toIso8601String(),
      'cloudVersion': cloudVersion.toIso8601String(),
      'changedFields': changedFields,
      'checkedAt': checkedAt.toIso8601String(),
      'isIgnored': isIgnored,
      'importance': importance.name,
    };
  }
  
  @override
  String toString() {
    return 'RecipeUpdateInfo(recipeId: $recipeId, hasUpdate: $hasUpdate, importance: $importance)';
  }
}

/// 🎯 更新重要性等级
@HiveType(typeId: 21)
enum UpdateImportance {
  @HiveField(0)
  normal('普通'),
  
  @HiveField(1)
  important('重要'),
  
  @HiveField(2)
  critical('紧急');
  
  const UpdateImportance(this.label);
  
  /// 显示标签
  final String label;
}

/// 🎨 更新标记颜色
enum UpdateBadgeColor {
  green,   // 普通更新
  blue,    // 新更新
  orange,  // 重要更新
  red,     // 紧急更新
}

/// 📱 更新操作类型
enum UpdateAction {
  update,   // 立即更新
  ignore,   // 忽略此更新
  later,    // 稍后提醒
  preview,  // 预览差异
}