/// 食谱筛选模型
/// 支持多维度筛选：分类、难度、时长、标签等
class RecipeFilter {
  /// 分类筛选
  final List<RecipeCategory> categories;
  
  /// 难度筛选
  final List<RecipeDifficulty> difficulties;
  
  /// 时长筛选（分钟）
  final TimeRange? timeRange;
  
  /// 标签筛选
  final List<String> tags;
  
  /// 搜索关键词
  final String? searchQuery;
  
  const RecipeFilter({
    this.categories = const [],
    this.difficulties = const [],
    this.timeRange,
    this.tags = const [],
    this.searchQuery,
  });

  /// 创建空筛选器
  factory RecipeFilter.empty() {
    return const RecipeFilter();
  }

  /// 复制并修改
  RecipeFilter copyWith({
    List<RecipeCategory>? categories,
    List<RecipeDifficulty>? difficulties,
    TimeRange? timeRange,
    List<String>? tags,
    String? searchQuery,
  }) {
    return RecipeFilter(
      categories: categories ?? this.categories,
      difficulties: difficulties ?? this.difficulties,
      timeRange: timeRange ?? this.timeRange,
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// 是否为空筛选器
  bool get isEmpty {
    return categories.isEmpty &&
           difficulties.isEmpty &&
           timeRange == null &&
           tags.isEmpty &&
           (searchQuery == null || searchQuery!.trim().isEmpty);
  }

  /// 筛选器数量
  int get filterCount {
    int count = 0;
    if (categories.isNotEmpty) count++;
    if (difficulties.isNotEmpty) count++;
    if (timeRange != null) count++;
    if (tags.isNotEmpty) count++;
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeFilter &&
           other.categories == categories &&
           other.difficulties == difficulties &&
           other.timeRange == timeRange &&
           other.tags == tags &&
           other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return categories.hashCode ^
           difficulties.hashCode ^
           timeRange.hashCode ^
           tags.hashCode ^
           searchQuery.hashCode;
  }
}

/// 食谱分类
enum RecipeCategory {
  chinese('中式', '🥢'),
  western('西式', '🍽️'),
  japanese('日式', '🍱'),
  korean('韩式', '🍲'),
  dessert('甜品', '🍰'),
  soup('汤品', '🍲'),
  salad('沙拉', '🥗'),
  beverage('饮品', '🥤');

  const RecipeCategory(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

/// 食谱难度
enum RecipeDifficulty {
  easy('简单', '⭐'),
  medium('中等', '⭐⭐'),
  hard('困难', '⭐⭐⭐');

  const RecipeDifficulty(this.displayName, this.icon);
  
  final String displayName;
  final String icon;
}

/// 时间范围
class TimeRange {
  final int minMinutes;
  final int maxMinutes;
  final String displayName;

  const TimeRange({
    required this.minMinutes,
    required this.maxMinutes,
    required this.displayName,
  });

  /// 预设时间范围
  static const List<TimeRange> presets = [
    TimeRange(minMinutes: 0, maxMinutes: 15, displayName: '15分钟以内'),
    TimeRange(minMinutes: 15, maxMinutes: 30, displayName: '15-30分钟'),
    TimeRange(minMinutes: 30, maxMinutes: 60, displayName: '30-60分钟'),
    TimeRange(minMinutes: 60, maxMinutes: 999, displayName: '1小时以上'),
  ];

  /// 检查时间是否在范围内
  bool contains(int minutes) {
    return minutes >= minMinutes && minutes <= maxMinutes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeRange &&
           other.minMinutes == minMinutes &&
           other.maxMinutes == maxMinutes;
  }

  @override
  int get hashCode => minMinutes.hashCode ^ maxMinutes.hashCode;

  @override
  String toString() => displayName;
}

/// 热门搜索标签
class PopularTags {
  static const List<String> tags = [
    '快手菜',
    '下饭菜', 
    '减脂餐',
    '宵夜',
    '素食',
    '开胃菜',
    '补汤',
    '养生',
    '儿童餐',
    '情侣餐',
    '聚餐',
    '节日特色',
  ];
}