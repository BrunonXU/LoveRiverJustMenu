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
      Memory(
        id: '1',
        date: DateTime(2024, 2, 14),
        title: '情人节烛光晚餐',
        emoji: '🕯️',
        special: true,
        mood: '浪漫',
        description: '为心爱的人亲手制作的烛光晚餐，温馨而浪漫',
        story: '今天是特别的日子，我决定为你做一顿烛光晚餐。从下午开始准备，精心挑选食材，布置餐桌。虽然过程有些忙乱，但看到你惊喜的表情时，一切都值得了。',
        oneLineComment: '超级浪漫！红酒牛排配烛光，简直完美💕',
        cookId: 'user1',
        commenterId: 'user2',
        commentedAt: DateTime(2024, 2, 14, 21, 30),
        difficulty: 4,
        cookingTime: 120,
      ),
      Memory(
        id: '2',
        date: DateTime(2024, 1, 1),
        title: '新年第一餐',
        emoji: '🎊',
        special: false,
        mood: '温馨',
        description: '新年第一顿饭，充满希望和期待',
        story: '新年的第一个早晨，我们一起做了简单的早餐。虽然只是煎蛋和吐司，但是一起做饭的感觉特别温暖。新的一年，希望我们能有更多这样的美好时光。',
        oneLineComment: '简单的幸福就是最好的开始🌅',
        cookId: 'user2',
        commenterId: 'user1',
        commentedAt: DateTime(2024, 1, 1, 9, 15),
        difficulty: 1,
        cookingTime: 20,
      ),
      Memory(
        id: '3',
        date: DateTime(2023, 12, 25),
        title: '圣诞大餐',
        emoji: '🎄',
        special: true,
        mood: '欢乐',
        description: '家人团聚的圣诞大餐，充满欢声笑语',
        story: '圣诞节我们邀请了双方父母来家里吃饭。准备了一整天，烤火鸡、做沙拉、准备甜品...虽然累得够呛，但看到大家开心的笑容，特别有成就感。',
        oneLineComment: '厨艺大进步！火鸡烤得金黄酥脆👨‍🍳',
        cookId: 'user1',
        commenterId: 'user2',
        commentedAt: DateTime(2023, 12, 25, 20, 45),
        difficulty: 5,
        cookingTime: 240,
      ),
      Memory(
        id: '4',
        date: DateTime(2023, 11, 15),
        title: '感恩节火鸡',
        emoji: '🦃',
        special: false,
        mood: '感恩',
        description: '感恩节的传统火鸡大餐，心怀感激',
        story: '第一次尝试做完整的感恩节大餐，从网上学了很多教程。火鸡有点干了，但配菜做得还不错。最重要的是我们在一起，心怀感恩。',
        difficulty: 3,
        cookingTime: 180,
        cookId: 'user2',
      ),
      Memory(
        id: '5',
        date: DateTime(2023, 10, 31),
        title: '万圣节南瓜汤',
        emoji: '🎃',
        special: true,
        mood: '神秘',
        description: '万圣节的特色南瓜汤，充满节日气氛',
        story: '万圣节我们买了好大一个南瓜，除了做南瓜灯，还剩下很多果肉。灵机一动做了南瓜汤，加了椰浆和香料，意外地好喝！',
        oneLineComment: '创意满分！橙色的汤配万圣节氛围绝了🎃',
        cookId: 'user1',
        commenterId: 'user2',
        commentedAt: DateTime(2023, 10, 31, 19, 20),
        difficulty: 2,
        cookingTime: 45,
      ),
    ];
  }
}