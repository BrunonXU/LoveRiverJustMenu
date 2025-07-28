import 'package:flutter/material.dart';

/// 中国省份枚举
enum ChineseProvince {
  beijing,      // 北京
  shanghai,     // 上海
  guangdong,    // 广东
  sichuan,      // 四川
  jiangsu,      // 江苏
  zhejiang,     // 浙江
  fujian,       // 福建
  hunan,        // 湖南
  shandong,     // 山东
  anhui,        // 安徽
  henan,        // 河南
  hebei,        // 河北
  hubei,        // 湖北
  jiangxi,      // 江西
  shanxi,       // 山西
  shaanxi,      // 陕西
  liaoning,     // 辽宁
  jilin,        // 吉林
  heilongjiang, // 黑龙江
  yunnan,       // 云南
  guizhou,      // 贵州
  guangxi,      // 广西
  hainan,       // 海南
  gansu,        // 甘肃
  qinghai,      // 青海
  xinjiang,     // 新疆
  xizang,       // 西藏
  neimenggu,    // 内蒙古
  ningxia,      // 宁夏
  tianjin,      // 天津
  chongqing,    // 重庆
  hongkong,     // 香港
  macao,        // 澳门
  taiwan,       // 台湾
}

/// 省份美食数据模型
class ProvinceCuisine {
  final ChineseProvince province;
  final String provinceName;       // 省份名称
  final String cuisineStyle;       // 菜系名称
  final String description;        // 菜系描述
  final List<String> features;     // 特色元素
  final List<RegionalDish> dishes; // 代表菜品
  final Color themeColor;          // 主题色
  final String iconEmoji;          // 省份图标
  final bool isUnlocked;           // 是否已解锁
  final double unlockProgress;     // 解锁进度
  final int requiredDishes;        // 解锁所需菜品数
  final DateTime? unlockDate;      // 解锁日期
  final List<String> unlockTips;   // 解锁提示

  const ProvinceCuisine({
    required this.province,
    required this.provinceName,
    required this.cuisineStyle,
    required this.description,
    required this.features,
    required this.dishes,
    required this.themeColor,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockProgress = 0.0,
    this.requiredDishes = 3,
    this.unlockDate,
    this.unlockTips = const [],
  });

  /// 获取省份显示名称
  String get displayName => provinceName;

  /// 获取解锁进度百分比
  int get progressPercentage => (unlockProgress * 100).round();

  /// 是否即将解锁（进度>=80%）
  bool get isNearUnlock => unlockProgress >= 0.8 && !isUnlocked;

  /// 复制并更新属性
  ProvinceCuisine copyWith({
    ChineseProvince? province,
    String? provinceName,
    String? cuisineStyle,
    String? description,
    List<String>? features,
    List<RegionalDish>? dishes,
    Color? themeColor,
    String? iconEmoji,
    bool? isUnlocked,
    double? unlockProgress,
    int? requiredDishes,
    DateTime? unlockDate,
    List<String>? unlockTips,
  }) {
    return ProvinceCuisine(
      province: province ?? this.province,
      provinceName: provinceName ?? this.provinceName,
      cuisineStyle: cuisineStyle ?? this.cuisineStyle,
      description: description ?? this.description,
      features: features ?? this.features,
      dishes: dishes ?? this.dishes,
      themeColor: themeColor ?? this.themeColor,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockProgress: unlockProgress ?? this.unlockProgress,
      requiredDishes: requiredDishes ?? this.requiredDishes,
      unlockDate: unlockDate ?? this.unlockDate,
      unlockTips: unlockTips ?? this.unlockTips,
    );
  }
}

/// 地方特色菜品
class RegionalDish {
  final String id;
  final String name;        // 菜名
  final String description; // 描述
  final String emoji;       // 菜品图标
  final int difficulty;     // 难度（1-5）
  final int cookTime;       // 烹饪时间（分钟）
  final bool isSignature;   // 是否为招牌菜
  final bool isCompleted;   // 是否已完成
  final DateTime? completedAt; // 完成时间

  const RegionalDish({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.difficulty,
    required this.cookTime,
    this.isSignature = false,
    this.isCompleted = false,
    this.completedAt,
  });

  /// 获取难度文字
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return '入门';
      case 2:
        return '简单';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '大师';
      default:
        return '未知';
    }
  }
}

/// 美食地图数据
class FoodMapData {
  /// 获取所有省份美食数据
  static List<ProvinceCuisine> getAllProvinces() {
    return [
      // 八大菜系
      ProvinceCuisine(
        province: ChineseProvince.sichuan,
        provinceName: '四川',
        cuisineStyle: '川菜',
        description: '麻辣鲜香，口味醇厚，以"一菜一格，百菜百味"闻名',
        features: ['麻辣', '鲜香', '重油', '味厚'],
        dishes: [
          RegionalDish(
            id: 'sc_001',
            name: '麻婆豆腐',
            description: '麻辣鲜香，豆腐嫩滑，是川菜代表作',
            emoji: '🥘',
            difficulty: 3,
            cookTime: 30,
            isSignature: true,
          ),
          RegionalDish(
            id: 'sc_002',
            name: '宫保鸡丁',
            description: '甜辣适中，鸡肉嫩滑，花生酥脆',
            emoji: '🍗',
            difficulty: 3,
            cookTime: 25,
            isSignature: true,
          ),
          RegionalDish(
            id: 'sc_003',
            name: '水煮鱼',
            description: '鱼肉鲜嫩，麻辣浓郁，回味无穷',
            emoji: '🐟',
            difficulty: 4,
            cookTime: 40,
          ),
          RegionalDish(
            id: 'sc_004',
            name: '回锅肉',
            description: '肥而不腻，色泽红亮，口感丰富',
            emoji: '🥓',
            difficulty: 3,
            cookTime: 35,
          ),
        ],
        themeColor: const Color(0xFFE53935), // 辣椒红
        iconEmoji: '🌶️',
        requiredDishes: 3,
        unlockTips: ['尝试制作一道麻辣菜品', '使用花椒和辣椒调味', '掌握"回锅"技法'],
      ),

      ProvinceCuisine(
        province: ChineseProvince.guangdong,
        provinceName: '广东',
        cuisineStyle: '粤菜',
        description: '清淡鲜美，讲究原汁原味，"食在广州"享誉全球',
        features: ['清淡', '鲜美', '精细', '养生'],
        dishes: [
          RegionalDish(
            id: 'gd_001',
            name: '白切鸡',
            description: '皮爽肉嫩，原汁原味，配姜葱蘸料',
            emoji: '🍗',
            difficulty: 2,
            cookTime: 45,
            isSignature: true,
          ),
          RegionalDish(
            id: 'gd_002',
            name: '烧鹅',
            description: '皮脆肉嫩，色泽红亮，香味扑鼻',
            emoji: '🦆',
            difficulty: 5,
            cookTime: 120,
            isSignature: true,
          ),
          RegionalDish(
            id: 'gd_003',
            name: '虾饺',
            description: '皮薄馅大，晶莹剔透，鲜美爽口',
            emoji: '🥟',
            difficulty: 4,
            cookTime: 30,
          ),
        ],
        themeColor: const Color(0xFF4CAF50), // 清新绿
        iconEmoji: '🍤',
        requiredDishes: 3,
        unlockTips: ['注重食材新鲜度', '掌握"白切"技法', '学会制作精致点心'],
      ),

      ProvinceCuisine(
        province: ChineseProvince.shandong,
        provinceName: '山东',
        cuisineStyle: '鲁菜',
        description: '咸鲜为主，火候精准，是中国四大菜系之首',
        features: ['咸鲜', '醇厚', '原汁', '精工'],
        dishes: [
          RegionalDish(
            id: 'sd_001',
            name: '糖醋鲤鱼',
            description: '外酥里嫩，酸甜适口，造型美观',
            emoji: '🐟',
            difficulty: 4,
            cookTime: 50,
            isSignature: true,
          ),
          RegionalDish(
            id: 'sd_002',
            name: '葱烧海参',
            description: '葱香浓郁，海参软糯，营养丰富',
            emoji: '🦑',
            difficulty: 5,
            cookTime: 90,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFF2196F3), // 海洋蓝
        iconEmoji: '🐟',
        requiredDishes: 3,
      ),

      ProvinceCuisine(
        province: ChineseProvince.jiangsu,
        provinceName: '江苏',
        cuisineStyle: '苏菜',
        description: '清淡雅致，注重本味，刀工精细，火候讲究',
        features: ['清淡', '本味', '精细', '雅致'],
        dishes: [
          RegionalDish(
            id: 'js_001',
            name: '松鼠鳜鱼',
            description: '形如松鼠，酸甜适口，外酥里嫩',
            emoji: '🐿️',
            difficulty: 5,
            cookTime: 40,
            isSignature: true,
          ),
          RegionalDish(
            id: 'js_002',
            name: '狮子头',
            description: '肉质鲜嫩，汤汁浓郁，口感丰富',
            emoji: '🦁',
            difficulty: 3,
            cookTime: 60,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFF9C27B0), // 优雅紫
        iconEmoji: '🎋',
        requiredDishes: 3,
      ),

      ProvinceCuisine(
        province: ChineseProvince.zhejiang,
        provinceName: '浙江',
        cuisineStyle: '浙菜',
        description: '清鲜爽脆，精巧细腻，富有江南水乡特色',
        features: ['清鲜', '爽脆', '精巧', '本色'],
        dishes: [
          RegionalDish(
            id: 'zj_001',
            name: '西湖醋鱼',
            description: '鱼肉鲜嫩，酸甜适口，充满诗意',
            emoji: '🐠',
            difficulty: 4,
            cookTime: 35,
            isSignature: true,
          ),
          RegionalDish(
            id: 'zj_002',
            name: '东坡肉',
            description: '肥而不腻，酥烂香醇，色泽红亮',
            emoji: '🥩',
            difficulty: 3,
            cookTime: 120,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFF00BCD4), // 西湖蓝
        iconEmoji: '🌊',
        requiredDishes: 3,
      ),

      ProvinceCuisine(
        province: ChineseProvince.fujian,
        provinceName: '福建',
        cuisineStyle: '闽菜',
        description: '汤菜为主，清鲜和醇，善用海鲜，独具特色',
        features: ['汤菜', '海鲜', '清鲜', '养生'],
        dishes: [
          RegionalDish(
            id: 'fj_001',
            name: '佛跳墙',
            description: '山珍海味，汤汁醇厚，滋补养生',
            emoji: '🏺',
            difficulty: 5,
            cookTime: 180,
            isSignature: true,
          ),
          RegionalDish(
            id: 'fj_002',
            name: '沙茶面',
            description: '汤头浓郁，沙茶香醇，配料丰富',
            emoji: '🍜',
            difficulty: 3,
            cookTime: 30,
          ),
        ],
        themeColor: const Color(0xFF009688), // 海洋绿
        iconEmoji: '🦐',
        requiredDishes: 3,
      ),

      ProvinceCuisine(
        province: ChineseProvince.hunan,
        provinceName: '湖南',
        cuisineStyle: '湘菜',
        description: '香辣酸爽，口味浓重，腊味独特，乡土气息浓厚',
        features: ['香辣', '酸爽', '腊味', '浓郁'],
        dishes: [
          RegionalDish(
            id: 'hn_001',
            name: '剁椒鱼头',
            description: '鱼头鲜嫩，剁椒香辣，色泽红亮',
            emoji: '🐟',
            difficulty: 3,
            cookTime: 40,
            isSignature: true,
          ),
          RegionalDish(
            id: 'hn_002',
            name: '毛氏红烧肉',
            description: '肥而不腻，香甜可口，色泽红亮',
            emoji: '🥘',
            difficulty: 3,
            cookTime: 90,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFFFF5722), // 辣椒橙
        iconEmoji: '🌶️',
        requiredDishes: 3,
      ),

      ProvinceCuisine(
        province: ChineseProvince.anhui,
        provinceName: '安徽',
        cuisineStyle: '徽菜',
        description: '重油重色，讲究火功，善用山珍，独具特色',
        features: ['重油', '重色', '山珍', '火功'],
        dishes: [
          RegionalDish(
            id: 'ah_001',
            name: '臭鳜鱼',
            description: '闻着臭吃着香，肉质鲜嫩，风味独特',
            emoji: '🐟',
            difficulty: 4,
            cookTime: 45,
            isSignature: true,
          ),
          RegionalDish(
            id: 'ah_002',
            name: '毛豆腐',
            description: '外酥里嫩，毛茸茸，口感独特',
            emoji: '🧀',
            difficulty: 3,
            cookTime: 25,
          ),
        ],
        themeColor: const Color(0xFF795548), // 山林棕
        iconEmoji: '🏔️',
        requiredDishes: 3,
      ),

      // 其他地方特色
      ProvinceCuisine(
        province: ChineseProvince.beijing,
        provinceName: '北京',
        cuisineStyle: '京菜',
        description: '宫廷菜与民间菜结合，烤制技艺精湛',
        features: ['烤制', '宫廷', '精致', '传统'],
        dishes: [
          RegionalDish(
            id: 'bj_001',
            name: '北京烤鸭',
            description: '皮脆肉嫩，色泽红润，配葱丝甜面酱',
            emoji: '🦆',
            difficulty: 5,
            cookTime: 120,
            isSignature: true,
          ),
          RegionalDish(
            id: 'bj_002',
            name: '炸酱面',
            description: '面条劲道，炸酱香浓，配菜丰富',
            emoji: '🍜',
            difficulty: 2,
            cookTime: 30,
          ),
        ],
        themeColor: const Color(0xFFD32F2F), // 故宫红
        iconEmoji: '🏛️',
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.shanghai,
        provinceName: '上海',
        cuisineStyle: '本帮菜',
        description: '浓油赤酱，口味偏甜，海派风格',
        features: ['浓油赤酱', '偏甜', '精致', '海派'],
        dishes: [
          RegionalDish(
            id: 'sh_001',
            name: '红烧肉',
            description: '肥而不腻，甜而不齁，色泽红亮',
            emoji: '🥩',
            difficulty: 3,
            cookTime: 90,
            isSignature: true,
          ),
          RegionalDish(
            id: 'sh_002',
            name: '生煎包',
            description: '底部金黄酥脆，汤汁丰富，鲜美可口',
            emoji: '🥟',
            difficulty: 3,
            cookTime: 20,
          ),
        ],
        themeColor: const Color(0xFF3F51B5), // 海派蓝
        iconEmoji: '🌆',
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.xinjiang,
        provinceName: '新疆',
        cuisineStyle: '新疆菜',
        description: '烤制为主，香料丰富，民族特色浓郁',
        features: ['烤制', '香料', '牛羊肉', '民族风'],
        dishes: [
          RegionalDish(
            id: 'xj_001',
            name: '烤羊肉串',
            description: '肉质鲜嫩，孜然飘香，外焦里嫩',
            emoji: '🍢',
            difficulty: 2,
            cookTime: 20,
            isSignature: true,
          ),
          RegionalDish(
            id: 'xj_002',
            name: '大盘鸡',
            description: '鸡肉鲜嫩，土豆软糯，配宽面条',
            emoji: '🍗',
            difficulty: 3,
            cookTime: 60,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFFFF9800), // 沙漠橙
        iconEmoji: '🐪',
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.yunnan,
        provinceName: '云南',
        cuisineStyle: '滇菜',
        description: '酸辣为主，食材丰富，民族风味浓郁',
        features: ['酸辣', '野菌', '鲜花', '民族'],
        dishes: [
          RegionalDish(
            id: 'yn_001',
            name: '过桥米线',
            description: '汤鲜味美，配料丰富，云南特色',
            emoji: '🍜',
            difficulty: 3,
            cookTime: 30,
            isSignature: true,
          ),
          RegionalDish(
            id: 'yn_002',
            name: '菌子火锅',
            description: '野生菌菇，鲜美无比，养生滋补',
            emoji: '🍄',
            difficulty: 3,
            cookTime: 45,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFF4CAF50), // 森林绿
        iconEmoji: '🌺',
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.xizang,
        provinceName: '西藏',
        cuisineStyle: '藏菜',
        description: '高原特色，牦牛肉为主，口味纯朴',
        features: ['牦牛', '青稞', '酥油', '高原'],
        dishes: [
          RegionalDish(
            id: 'xz_001',
            name: '酥油茶',
            description: '浓郁醇厚，御寒暖身，藏族特色',
            emoji: '☕',
            difficulty: 2,
            cookTime: 20,
            isSignature: true,
          ),
          RegionalDish(
            id: 'xz_002',
            name: '牦牛肉',
            description: '肉质鲜嫩，营养丰富，高原特产',
            emoji: '🥩',
            difficulty: 3,
            cookTime: 90,
          ),
        ],
        themeColor: const Color(0xFF1976D2), // 高原蓝
        iconEmoji: '🏔️',
        requiredDishes: 2,
      ),
    ];
  }

  /// 根据省份获取美食数据
  static ProvinceCuisine? getProvinceData(ChineseProvince province) {
    return getAllProvinces().firstWhere(
      (p) => p.province == province,
      orElse: () => throw Exception('Province not found'),
    );
  }

  /// 获取已解锁的省份
  static List<ProvinceCuisine> getUnlockedProvinces() {
    return getAllProvinces().where((p) => p.isUnlocked).toList();
  }

  /// 获取即将解锁的省份
  static List<ProvinceCuisine> getNearUnlockProvinces() {
    return getAllProvinces().where((p) => p.isNearUnlock).toList();
  }

  /// 根据菜系分组
  static Map<String, List<ProvinceCuisine>> groupByCuisineStyle() {
    final Map<String, List<ProvinceCuisine>> grouped = {};
    
    for (final province in getAllProvinces()) {
      grouped.putIfAbsent(province.cuisineStyle, () => []).add(province);
    }
    
    return grouped;
  }
}