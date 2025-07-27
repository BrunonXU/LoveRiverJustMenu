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
    return [
      Memory(
        id: '1',
        date: DateTime(2024, 2, 14),
        title: '情人节烛光晚餐',
        emoji: '🕯️',
        special: true,
        mood: '浪漫',
        description: '为心爱的人亲手制作的烛光晚餐，温馨而浪漫',
      ),
      Memory(
        id: '2',
        date: DateTime(2024, 1, 1),
        title: '新年第一餐',
        emoji: '🎊',
        special: false,
        mood: '温馨',
        description: '新年第一顿饭，充满希望和期待',
      ),
      Memory(
        id: '3',
        date: DateTime(2023, 12, 25),
        title: '圣诞大餐',
        emoji: '🎄',
        special: true,
        mood: '欢乐',
        description: '家人团聚的圣诞大餐，充满欢声笑语',
      ),
      Memory(
        id: '4',
        date: DateTime(2023, 11, 15),
        title: '感恩节火鸡',
        emoji: '🦃',
        special: false,
        mood: '感恩',
        description: '感恩节的传统火鸡大餐，心怀感激',
      ),
      Memory(
        id: '5',
        date: DateTime(2023, 10, 31),
        title: '万圣节南瓜汤',
        emoji: '🎃',
        special: true,
        mood: '神秘',
        description: '万圣节的特色南瓜汤，充满节日气氛',
      ),
    ];
  }
}