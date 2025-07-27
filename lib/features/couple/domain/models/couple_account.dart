/// 情侣账号模型
/// 支持双方账号关联和数据同步
class CoupleAccount {
  /// 情侣账号唯一ID
  final String coupleId;
  
  /// 账号创建者ID
  final String creatorId;
  
  /// 伴侣ID（可能为null表示未绑定）
  final String? partnerId;
  
  /// 情侣昵称
  final String coupleName;
  
  /// 关系开始日期
  final DateTime relationshipStartDate;
  
  /// 头像URL（情侣合照）
  final String? avatarUrl;
  
  /// 情侣状态
  final CoupleStatus status;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后更新时间
  final DateTime updatedAt;
  
  /// 绑定邀请码（用于伴侣加入）
  final String? inviteCode;
  
  /// 个人资料设置
  final CoupleProfile? myProfile;
  final CoupleProfile? partnerProfile;

  const CoupleAccount({
    required this.coupleId,
    required this.creatorId,
    this.partnerId,
    required this.coupleName,
    required this.relationshipStartDate,
    this.avatarUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.inviteCode,
    this.myProfile,
    this.partnerProfile,
  });

  /// 是否已完成绑定
  bool get isBound => partnerId != null && status == CoupleStatus.active;

  /// 是否是创建者
  bool isCreator(String userId) => userId == creatorId;

  /// 是否是伴侣
  bool isPartner(String userId) => userId == partnerId;

  /// 获取对方的资料
  CoupleProfile? getPartnerProfile(String currentUserId) {
    if (isCreator(currentUserId)) {
      return partnerProfile;
    } else if (isPartner(currentUserId)) {
      return myProfile;
    }
    return null;
  }

  /// 获取自己的资料
  CoupleProfile? getMyProfile(String currentUserId) {
    if (isCreator(currentUserId)) {
      return myProfile;
    } else if (isPartner(currentUserId)) {
      return partnerProfile;
    }
    return null;
  }

  /// 复制并修改
  CoupleAccount copyWith({
    String? coupleId,
    String? creatorId,
    String? partnerId,
    String? coupleName,
    DateTime? relationshipStartDate,
    String? avatarUrl,
    CoupleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? inviteCode,
    CoupleProfile? myProfile,
    CoupleProfile? partnerProfile,
  }) {
    return CoupleAccount(
      coupleId: coupleId ?? this.coupleId,
      creatorId: creatorId ?? this.creatorId,
      partnerId: partnerId ?? this.partnerId,
      coupleName: coupleName ?? this.coupleName,
      relationshipStartDate: relationshipStartDate ?? this.relationshipStartDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inviteCode: inviteCode ?? this.inviteCode,
      myProfile: myProfile ?? this.myProfile,
      partnerProfile: partnerProfile ?? this.partnerProfile,
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'creatorId': creatorId,
      'partnerId': partnerId,
      'coupleName': coupleName,
      'relationshipStartDate': relationshipStartDate.toIso8601String(),
      'avatarUrl': avatarUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'inviteCode': inviteCode,
      'myProfile': myProfile?.toJson(),
      'partnerProfile': partnerProfile?.toJson(),
    };
  }

  /// 从JSON创建
  factory CoupleAccount.fromJson(Map<String, dynamic> json) {
    return CoupleAccount(
      coupleId: json['coupleId'],
      creatorId: json['creatorId'],
      partnerId: json['partnerId'],
      coupleName: json['coupleName'],
      relationshipStartDate: DateTime.parse(json['relationshipStartDate']),
      avatarUrl: json['avatarUrl'],
      status: CoupleStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      inviteCode: json['inviteCode'],
      myProfile: json['myProfile'] != null 
        ? CoupleProfile.fromJson(json['myProfile']) 
        : null,
      partnerProfile: json['partnerProfile'] != null 
        ? CoupleProfile.fromJson(json['partnerProfile']) 
        : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoupleAccount && other.coupleId == coupleId;
  }

  @override
  int get hashCode => coupleId.hashCode;
}

/// 情侣状态枚举
enum CoupleStatus {
  /// 等待绑定
  pending,
  
  /// 活跃状态
  active,
  
  /// 暂停状态
  paused,
  
  /// 已解绑
  unbound,
}

/// 情侣个人资料
class CoupleProfile {
  /// 用户ID
  final String userId;
  
  /// 昵称
  final String nickname;
  
  /// 头像URL
  final String? avatarUrl;
  
  /// 生日
  final DateTime? birthday;
  
  /// 性别
  final Gender? gender;
  
  /// 个人简介
  final String? bio;
  
  /// 最喜欢的菜系
  final List<String> favoriteCuisines;
  
  /// 饮食偏好
  final List<String> dietaryPreferences;
  
  /// 烹饪技能等级 (1-5)
  final int cookingLevel;

  const CoupleProfile({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.birthday,
    this.gender,
    this.bio,
    this.favoriteCuisines = const [],
    this.dietaryPreferences = const [],
    this.cookingLevel = 1,
  });

  /// 年龄
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || 
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  /// 烹饪技能描述
  String get cookingLevelDescription {
    switch (cookingLevel) {
      case 1:
        return '新手厨师';
      case 2:
        return '入门厨师';
      case 3:
        return '中级厨师';
      case 4:
        return '高级厨师';
      case 5:
        return '大师级厨师';
      default:
        return '未知等级';
    }
  }

  /// 复制并修改
  CoupleProfile copyWith({
    String? userId,
    String? nickname,
    String? avatarUrl,
    DateTime? birthday,
    Gender? gender,
    String? bio,
    List<String>? favoriteCuisines,
    List<String>? dietaryPreferences,
    int? cookingLevel,
  }) {
    return CoupleProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      cookingLevel: cookingLevel ?? this.cookingLevel,
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'birthday': birthday?.toIso8601String(),
      'gender': gender?.name,
      'bio': bio,
      'favoriteCuisines': favoriteCuisines,
      'dietaryPreferences': dietaryPreferences,
      'cookingLevel': cookingLevel,
    };
  }

  /// 从JSON创建
  factory CoupleProfile.fromJson(Map<String, dynamic> json) {
    return CoupleProfile(
      userId: json['userId'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      birthday: json['birthday'] != null 
        ? DateTime.parse(json['birthday']) 
        : null,
      gender: json['gender'] != null 
        ? Gender.values.firstWhere((e) => e.name == json['gender'])
        : null,
      bio: json['bio'],
      favoriteCuisines: List<String>.from(json['favoriteCuisines'] ?? []),
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      cookingLevel: json['cookingLevel'] ?? 1,
    );
  }
}

/// 性别枚举
enum Gender {
  male,
  female,
  other,
}

/// 绑定邀请
class CoupleInvitation {
  /// 邀请ID
  final String invitationId;
  
  /// 情侣账号ID
  final String coupleId;
  
  /// 邀请码
  final String inviteCode;
  
  /// 邀请者ID
  final String inviterId;
  
  /// 邀请者昵称
  final String inviterNickname;
  
  /// 被邀请者ID（可能为null）
  final String? inviteeId;
  
  /// 邀请状态
  final InvitationStatus status;
  
  /// 邀请消息
  final String? message;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 过期时间
  final DateTime expiresAt;

  const CoupleInvitation({
    required this.invitationId,
    required this.coupleId,
    required this.inviteCode,
    required this.inviterId,
    required this.inviterNickname,
    this.inviteeId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.expiresAt,
  });

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 是否有效
  bool get isValid => status == InvitationStatus.pending && !isExpired;
}

/// 邀请状态枚举
enum InvitationStatus {
  /// 待处理
  pending,
  
  /// 已接受
  accepted,
  
  /// 已拒绝
  rejected,
  
  /// 已过期
  expired,
  
  /// 已取消
  cancelled,
}