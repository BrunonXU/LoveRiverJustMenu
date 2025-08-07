/// 美食记忆数据模型
/// 记录用户的美食时光与情感瞬间
class Memory {
  /// 唯一标识
  final String id;
  
  /// 记忆日期
  final DateTime date;
  
  /// 记忆标题
  final String title;
  
  /// 表情符号
  final String emoji;
  
  /// 是否为特殊记忆（会有彩色焦点显示）
  final bool special;
  
  /// 心情描述
  final String mood;
  
  /// 关联的菜谱ID（可选）
  final String? recipeId;
  
  /// 记忆描述
  final String? description;
  
  /// 记忆图片URL（可选）
  final String? imageUrl;
  
  /// 菜谱故事（详细记录）
  final String? story;
  
  /// 一句话点评
  final String? oneLineComment;
  
  /// 制作者ID（情侣中的一方）
  final String? cookId;
  
  /// 点评者ID（情侣中的另一方）
  final String? commenterId;
  
  /// 点评时间
  final DateTime? commentedAt;
  
  /// 制作难度（1-5）
  final int? difficulty;
  
  /// 制作耗时（分钟）
  final int? cookingTime;
  
  const Memory({
    required this.id,
    required this.date,
    required this.title,
    required this.emoji,
    required this.special,
    required this.mood,
    this.recipeId,
    this.description,
    this.imageUrl,
    this.story,
    this.oneLineComment,
    this.cookId,
    this.commenterId,
    this.commentedAt,
    this.difficulty,
    this.cookingTime,
  });

  /// 从JSON创建Memory实例
  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      special: json['special'] as bool,
      mood: json['mood'] as String,
      recipeId: json['recipeId'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      story: json['story'] as String?,
      oneLineComment: json['oneLineComment'] as String?,
      cookId: json['cookId'] as String?,
      commenterId: json['commenterId'] as String?,
      commentedAt: json['commentedAt'] != null 
          ? DateTime.parse(json['commentedAt'] as String) 
          : null,
      difficulty: json['difficulty'] as int?,
      cookingTime: json['cookingTime'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'emoji': emoji,
      'special': special,
      'mood': mood,
      'recipeId': recipeId,
      'description': description,
      'imageUrl': imageUrl,
      'story': story,
      'oneLineComment': oneLineComment,
      'cookId': cookId,
      'commenterId': commenterId,
      'commentedAt': commentedAt?.toIso8601String(),
      'difficulty': difficulty,
      'cookingTime': cookingTime,
    };
  }

  /// 复制并修改
  Memory copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? emoji,
    bool? special,
    String? mood,
    String? recipeId,
    String? description,
    String? imageUrl,
    String? story,
    String? oneLineComment,
    String? cookId,
    String? commenterId,
    DateTime? commentedAt,
    int? difficulty,
    int? cookingTime,
  }) {
    return Memory(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      special: special ?? this.special,
      mood: mood ?? this.mood,
      recipeId: recipeId ?? this.recipeId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      story: story ?? this.story,
      oneLineComment: oneLineComment ?? this.oneLineComment,
      cookId: cookId ?? this.cookId,
      commenterId: commenterId ?? this.commenterId,
      commentedAt: commentedAt ?? this.commentedAt,
      difficulty: difficulty ?? this.difficulty,
      cookingTime: cookingTime ?? this.cookingTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Memory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Memory(id: $id, title: $title, date: $date, special: $special)';
  }
}

/// 预设的示例记忆数据
class MemoryData {
  static List<Memory> getSampleMemories() {
    final now = DateTime.now();
    
    return [
      // === 2024年2月1-15日 (10个记忆) ===
      Memory(
        id: '1', date: DateTime(2024, 2, 14), title: '情人节烛光晚餐', emoji: '🕯️', special: true, mood: '浪漫',
        description: '为心爱的人亲手制作的烛光晚餐', cookId: 'user1', difficulty: 4, cookingTime: 120,
      ),
      Memory(id: '2', date: DateTime(2024, 2, 13), title: '意式千层面', emoji: '🍝', special: false, mood: '满足', cookId: 'user2'),
      Memory(id: '3', date: DateTime(2024, 2, 12), title: '海鲜火锅', emoji: '🍲', special: false, mood: '温暖', cookId: 'user1'),
      Memory(id: '4', date: DateTime(2024, 2, 11), title: '手工饺子', emoji: '🥟', special: true, mood: '团圆', cookId: 'user1'),
      Memory(id: '5', date: DateTime(2024, 2, 10), title: '奶昔布丁', emoji: '🍮', special: false, mood: '甜蜜', cookId: 'user2'),
      Memory(id: '6', date: DateTime(2024, 2, 9), title: '韩式拌饭', emoji: '🍛', special: false, mood: '健康', cookId: 'user2'),
      Memory(id: '7', date: DateTime(2024, 2, 8), title: '法式土司', emoji: '🍞', special: false, mood: '悠闲', cookId: 'user1'),
      Memory(id: '8', date: DateTime(2024, 2, 7), title: '蒸蛋羹', emoji: '🥚', special: false, mood: '温柔', cookId: 'user2'),
      Memory(id: '9', date: DateTime(2024, 2, 6), title: '巧克力蛋糕', emoji: '🍰', special: true, mood: '惊喜', cookId: 'user1'),
      Memory(id: '10', date: DateTime(2024, 2, 5), title: '鲜虾粥', emoji: '🍜', special: false, mood: '养胃', cookId: 'user2'),

      // === 2024年1月15-31日 (5个记忆) ===
      Memory(id: '11', date: DateTime(2024, 1, 30), title: '年夜饭', emoji: '🧧', special: true, mood: '团圆', cookId: 'user1'),
      Memory(id: '12', date: DateTime(2024, 1, 25), title: '红烧肉', emoji: '🍖', special: false, mood: '满足', cookId: 'user2'),
      Memory(id: '13', date: DateTime(2024, 1, 20), title: '蒸蛋糕', emoji: '🧁', special: false, mood: '甜蜜', cookId: 'user1'),
      Memory(id: '14', date: DateTime(2024, 1, 18), title: '火锅', emoji: '🔥', special: false, mood: '热辣', cookId: 'user2'),
      Memory(id: '15', date: DateTime(2024, 1, 16), title: '小笼包', emoji: '🥟', special: false, mood: '精致', cookId: 'user1'),

      // === 2024年1月1-15日 (7个记忆) ===
      Memory(id: '16', date: DateTime(2024, 1, 14), title: '情侣下午茶', emoji: '🫖', special: true, mood: '浪漫', cookId: 'user1'),
      Memory(id: '17', date: DateTime(2024, 1, 12), title: '意大利面', emoji: '🍝', special: false, mood: '经典', cookId: 'user2'),
      Memory(id: '18', date: DateTime(2024, 1, 10), title: '寿司拼盘', emoji: '🍣', special: false, mood: '精致', cookId: 'user1'),
      Memory(id: '19', date: DateTime(2024, 1, 8), title: '烤鸡翅', emoji: '🍗', special: false, mood: '香辣', cookId: 'user2'),
      Memory(id: '20', date: DateTime(2024, 1, 6), title: '提拉米苏', emoji: '🍮', special: true, mood: '甜蜜', cookId: 'user1'),
      Memory(id: '21', date: DateTime(2024, 1, 3), title: '粥配小菜', emoji: '🥣', special: false, mood: '清淡', cookId: 'user2'),
      Memory(
        id: '22', date: DateTime(2024, 1, 1), title: '新年第一餐', emoji: '🎊', special: true, mood: '温馨',
        description: '新年第一顿饭，充满希望和期待', oneLineComment: '简单的幸福就是最好的开始🌅',
        cookId: 'user2', commenterId: 'user1', commentedAt: DateTime(2024, 1, 1, 9, 15), difficulty: 1, cookingTime: 20,
      ),

      // === 2023年12月15-31日 (3个记忆) ===
      Memory(
        id: '23', date: DateTime(2023, 12, 25), title: '圣诞大餐', emoji: '🎄', special: true, mood: '欢乐',
        description: '家人团聚的圣诞大餐，充满欢声笑语', oneLineComment: '厨艺大进步！火鸡烤得金黄酥脆👨‍🍳',
        cookId: 'user1', commenterId: 'user2', commentedAt: DateTime(2023, 12, 25, 20, 45), difficulty: 5, cookingTime: 240,
      ),
      Memory(id: '24', date: DateTime(2023, 12, 20), title: '冬至汤圆', emoji: '🍡', special: false, mood: '温暖', cookId: 'user2'),
      Memory(id: '25', date: DateTime(2023, 12, 18), title: '热可可', emoji: '☕', special: false, mood: '温暖', cookId: 'user1'),
    ];
  }
}