/// 挑战数据模型
/// 情侣间的菜谱挑战系统核心模型
class Challenge {
  /// 挑战ID
  final String id;
  
  /// 发起者ID
  final String senderId;
  
  /// 接收者ID  
  final String receiverId;
  
  /// 挑战菜谱ID
  final String recipeId;
  
  /// 挑战菜谱名称
  final String recipeName;
  
  /// 挑战菜谱图标
  final String recipeIcon;
  
  /// 挑战状态
  final ChallengeStatus status;
  
  /// 发起时间
  final DateTime createdAt;
  
  /// 接受时间（可选）
  final DateTime? acceptedAt;
  
  /// 完成时间（可选）
  final DateTime? completedAt;
  
  /// 挑战消息
  final String message;
  
  /// 预估完成时间（分钟）
  final int estimatedTime;
  
  /// 难度等级（1-5）
  final int difficulty;
  
  /// 完成照片URL（可选）
  final String? completionPhotoUrl;
  
  /// 完成备注（可选）
  final String? completionNote;
  
  /// 评分（1-5星，可选）
  final double? rating;
  
  /// 评分备注（可选）
  final String? ratingNote;

  const Challenge({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.recipeId,
    required this.recipeName,
    required this.recipeIcon,
    required this.status,
    required this.createdAt,
    required this.message,
    required this.estimatedTime,
    required this.difficulty,
    this.acceptedAt,
    this.completedAt,
    this.completionPhotoUrl,
    this.completionNote,
    this.rating,
    this.ratingNote,
  });

  /// 从JSON创建Challenge实例
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      recipeIcon: json['recipeIcon'] as String,
      status: ChallengeStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      message: json['message'] as String,
      estimatedTime: json['estimatedTime'] as int,
      difficulty: json['difficulty'] as int,
      acceptedAt: json['acceptedAt'] != null 
          ? DateTime.parse(json['acceptedAt'] as String) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      completionPhotoUrl: json['completionPhotoUrl'] as String?,
      completionNote: json['completionNote'] as String?,
      rating: json['rating']?.toDouble(),
      ratingNote: json['ratingNote'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeIcon': recipeIcon,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'message': message,
      'estimatedTime': estimatedTime,
      'difficulty': difficulty,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionPhotoUrl': completionPhotoUrl,
      'completionNote': completionNote,
      'rating': rating,
      'ratingNote': ratingNote,
    };
  }

  /// 复制并修改
  Challenge copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? recipeId,
    String? recipeName,
    String? recipeIcon,
    ChallengeStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? message,
    int? estimatedTime,
    int? difficulty,
    String? completionPhotoUrl,
    String? completionNote,
    double? rating,
    String? ratingNote,
  }) {
    return Challenge(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeIcon: recipeIcon ?? this.recipeIcon,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      message: message ?? this.message,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      difficulty: difficulty ?? this.difficulty,
      completionPhotoUrl: completionPhotoUrl ?? this.completionPhotoUrl,
      completionNote: completionNote ?? this.completionNote,
      rating: rating ?? this.rating,
      ratingNote: ratingNote ?? this.ratingNote,
    );
  }

  /// 计算挑战持续时间
  Duration? get duration {
    if (acceptedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(acceptedAt!);
  }

  /// 是否超时
  bool get isOverdue {
    if (acceptedAt == null || status == ChallengeStatus.completed) return false;
    final deadline = acceptedAt!.add(Duration(minutes: estimatedTime * 2)); // 允许2倍预估时间
    return DateTime.now().isAfter(deadline);
  }

  /// 获取状态显示文本
  String get statusText {
    switch (status) {
      case ChallengeStatus.pending:
        return '等待接受';
      case ChallengeStatus.accepted:
        return '进行中';
      case ChallengeStatus.completed:
        return '已完成';
      case ChallengeStatus.rejected:
        return '已拒绝';
      case ChallengeStatus.expired:
        return '已过期';
    }
  }

  /// 获取难度显示文本
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '容易';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '专业';
      default:
        return '未知';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Challenge(id: $id, recipeName: $recipeName, status: $status)';
  }
}

/// 挑战状态枚举
enum ChallengeStatus {
  /// 等待接受
  pending,
  
  /// 已接受
  accepted,
  
  /// 已完成
  completed,
  
  /// 已拒绝
  rejected,
  
  /// 已过期
  expired;

  /// 从字符串创建枚举
  static ChallengeStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ChallengeStatus.pending;
      case 'accepted':
        return ChallengeStatus.accepted;
      case 'completed':
        return ChallengeStatus.completed;
      case 'rejected':
        return ChallengeStatus.rejected;
      case 'expired':
        return ChallengeStatus.expired;
      default:
        throw ArgumentError('Unknown challenge status: $value');
    }
  }

  @override
  String toString() {
    return name;
  }
}

/// 预设的示例挑战数据
class ChallengeData {
  static List<Challenge> getSampleChallenges() {
    final now = DateTime.now();
    
    return [
      Challenge(
        id: '1',
        senderId: 'user1',
        receiverId: 'user2',
        recipeId: 'recipe_001',
        recipeName: '爱心蛋炒饭',
        recipeIcon: '🍳',
        status: ChallengeStatus.pending,
        createdAt: now.subtract(Duration(hours: 2)),
        message: '今晚做个爱心蛋炒饭吧～想念你的手艺了！',
        estimatedTime: 15,
        difficulty: 2,
      ),
      
      Challenge(
        id: '2',
        senderId: 'user2',
        receiverId: 'user1',
        recipeId: 'recipe_002',
        recipeName: '红烧肉',
        recipeIcon: '🥩',
        status: ChallengeStatus.accepted,
        createdAt: now.subtract(Duration(days: 1)),
        acceptedAt: now.subtract(Duration(hours: 23)),
        message: '挑战一下红烧肉！看看谁做得更好吃～',
        estimatedTime: 45,
        difficulty: 3,
      ),
      
      Challenge(
        id: '3',
        senderId: 'user1',
        receiverId: 'user2',
        recipeId: 'recipe_003',
        recipeName: '提拉米苏',
        recipeIcon: '🧁',
        status: ChallengeStatus.completed,
        createdAt: now.subtract(Duration(days: 3)),
        acceptedAt: now.subtract(Duration(days: 3, hours: 1)),
        completedAt: now.subtract(Duration(days: 2)),
        message: '情人节特别挑战！一起做甜蜜的提拉米苏💕',
        estimatedTime: 60,
        difficulty: 4,
        rating: 4.5,
        ratingNote: '卖相不错，但奶油有点甜～',
        completionNote: '第一次做，有点紧张但很开心！',
      ),
      
      Challenge(
        id: '4',
        senderId: 'user2',
        receiverId: 'user1',
        recipeId: 'recipe_004',
        recipeName: '麻婆豆腐',
        recipeIcon: '🌶️',
        status: ChallengeStatus.rejected,
        createdAt: now.subtract(Duration(days: 5)),
        message: '挑战麻婆豆腐！看看能不能做出正宗川味～',
        estimatedTime: 20,
        difficulty: 3,
      ),
      
      Challenge(
        id: '5',
        senderId: 'user1',
        receiverId: 'user2',
        recipeId: 'recipe_005',
        recipeName: '法式焗蜗牛',
        recipeIcon: '🐌',
        status: ChallengeStatus.expired,
        createdAt: now.subtract(Duration(days: 7)),
        message: '超级挑战！法式焗蜗牛，敢不敢试试？',
        estimatedTime: 90,
        difficulty: 5,
      ),
    ];
  }
}