import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/province_cuisine.dart';

/// 🔧 性能优化版美食地图状态管理
class FoodMapNotifierOptimized extends StateNotifier<List<ProvinceCuisine>> {
  FoodMapNotifierOptimized() : super(_getSimpleProvinces()) {
    _loadSimpleProgress();
  }

  /// 🔧 简化的省份数据 - 只保留核心省份
  static List<ProvinceCuisine> _getSimpleProvinces() {
    return [
      // 🔧 只保留6个主要省份，减少数据量
      ProvinceCuisine(
        province: ChineseProvince.sichuan,
        provinceName: '四川',
        cuisineStyle: '川菜',
        description: '麻辣鲜香，口味醇厚',
        features: ['麻辣', '鲜香'],
        dishes: [
          RegionalDish(
            id: 'sc_001',
            name: '麻婆豆腐',
            description: '麻辣鲜香，豆腐嫩滑',
            emoji: '🥘',
            difficulty: 3,
            cookTime: 30,
            isSignature: true,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          RegionalDish(
            id: 'sc_002',
            name: '宫保鸡丁',
            description: '甜辣适中，鸡肉嫩滑',
            emoji: '🍗',
            difficulty: 3,
            cookTime: 25,
            isSignature: true,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        themeColor: const Color(0xFFE53935),
        iconEmoji: '🌶️',
        isUnlocked: true,
        unlockProgress: 1.0,
        requiredDishes: 2,
        unlockDate: DateTime.now().subtract(const Duration(days: 10)),
      ),

      ProvinceCuisine(
        province: ChineseProvince.guangdong,
        provinceName: '广东',
        cuisineStyle: '粤菜',
        description: '清淡鲜美，讲究原汁原味',
        features: ['清淡', '鲜美'],
        dishes: [
          RegionalDish(
            id: 'gd_001',
            name: '白切鸡',
            description: '皮爽肉嫩，原汁原味',
            emoji: '🍗',
            difficulty: 2,
            cookTime: 45,
            isSignature: true,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          RegionalDish(
            id: 'gd_002',
            name: '虾饺',
            description: '皮薄馅大，晶莹剔透',
            emoji: '🥟',
            difficulty: 4,
            cookTime: 30,
          ),
        ],
        themeColor: const Color(0xFF4CAF50),
        iconEmoji: '🍤',
        unlockProgress: 0.5, // 1/2 完成
        requiredDishes: 2,
        unlockTips: ['注重食材新鲜度', '掌握\"白切\"技法'],
      ),

      ProvinceCuisine(
        province: ChineseProvince.beijing,
        provinceName: '北京',
        cuisineStyle: '京菜',
        description: '宫廷菜与民间菜结合',
        features: ['烤制', '宫廷'],
        dishes: [
          RegionalDish(
            id: 'bj_001',
            name: '北京烤鸭',
            description: '皮脆肉嫩，色泽红润',
            emoji: '🦆',
            difficulty: 5,
            cookTime: 120,
            isSignature: true,
          ),
          RegionalDish(
            id: 'bj_002',
            name: '炸酱面',
            description: '面条劲道，炸酱香浓',
            emoji: '🍜',
            difficulty: 2,
            cookTime: 30,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        themeColor: const Color(0xFFD32F2F),
        iconEmoji: '🏛️',
        unlockProgress: 0.5, // 1/2 完成
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.shanghai,
        provinceName: '上海',
        cuisineStyle: '本帮菜',
        description: '浓油赤酱，口味偏甜',
        features: ['浓油赤酱', '偏甜'],
        dishes: [
          RegionalDish(
            id: 'sh_001',
            name: '红烧肉',
            description: '肥而不腻，甜而不齁',
            emoji: '🥩',
            difficulty: 3,
            cookTime: 90,
            isSignature: true,
          ),
          RegionalDish(
            id: 'sh_002',
            name: '生煎包',
            description: '底部金黄酥脆，汤汁丰富',
            emoji: '🥟',
            difficulty: 3,
            cookTime: 20,
          ),
        ],
        themeColor: const Color(0xFF3F51B5),
        iconEmoji: '🌆',
        isUnlocked: true,
        unlockProgress: 1.0,
        requiredDishes: 2,
        unlockDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),

      ProvinceCuisine(
        province: ChineseProvince.jiangsu,
        provinceName: '江苏',
        cuisineStyle: '苏菜',
        description: '清淡雅致，注重本味',
        features: ['清淡', '本味'],
        dishes: [
          RegionalDish(
            id: 'js_001',
            name: '松鼠鳜鱼',
            description: '形如松鼠，酸甜适口',
            emoji: '🐿️',
            difficulty: 5,
            cookTime: 40,
            isSignature: true,
          ),
          RegionalDish(
            id: 'js_002',
            name: '狮子头',
            description: '肉质鲜嫩，汤汁浓郁',
            emoji: '🦁',
            difficulty: 3,
            cookTime: 60,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFF9C27B0),
        iconEmoji: '🎋',
        unlockProgress: 0.2,
        requiredDishes: 2,
      ),

      ProvinceCuisine(
        province: ChineseProvince.xinjiang,
        provinceName: '新疆',
        cuisineStyle: '新疆菜',
        description: '烤制为主，香料丰富',
        features: ['烤制', '香料'],
        dishes: [
          RegionalDish(
            id: 'xj_001',
            name: '烤羊肉串',
            description: '肉质鲜嫩，孜然飘香',
            emoji: '🍢',
            difficulty: 2,
            cookTime: 20,
            isSignature: true,
          ),
          RegionalDish(
            id: 'xj_002',
            name: '大盘鸡',
            description: '鸡肉鲜嫩，土豆软糯',
            emoji: '🍗',
            difficulty: 3,
            cookTime: 60,
            isSignature: true,
          ),
        ],
        themeColor: const Color(0xFFFF9800),
        iconEmoji: '🐪',
        unlockProgress: 0.0,
        requiredDishes: 2,
      ),
    ];
  }

  /// 🔧 简化的进度加载
  void _loadSimpleProgress() {
    // 使用预设数据，避免复杂计算
  }

  /// 完成一道菜品
  void completeDish(ChineseProvince province, String dishId) {
    final updatedProvinces = state.map((p) {
      if (p.province == province) {
        final updatedDishes = p.dishes.map((dish) {
          if (dish.id == dishId && !dish.isCompleted) {
            return RegionalDish(
              id: dish.id,
              name: dish.name,
              description: dish.description,
              emoji: dish.emoji,
              difficulty: dish.difficulty,
              cookTime: dish.cookTime,
              isSignature: dish.isSignature,
              isCompleted: true,
              completedAt: DateTime.now(),
            );
          }
          return dish;
        }).toList();
        
        // 🔧 简化的进度计算
        final completedCount = updatedDishes.where((d) => d.isCompleted).length;
        final newProgress = completedCount / p.requiredDishes;
        
        // 检查是否解锁
        if (newProgress >= 1.0 && !p.isUnlocked) {
          HapticFeedback.heavyImpact();
          
          return p.copyWith(
            dishes: updatedDishes,
            unlockProgress: 1.0,
            isUnlocked: true,
            unlockDate: DateTime.now(),
          );
        }
        
        return p.copyWith(
          dishes: updatedDishes,
          unlockProgress: newProgress.clamp(0.0, 1.0),
        );
      }
      return p;
    }).toList();
    
    state = updatedProvinces;
  }
}

/// 🔧 性能优化的Provider定义
final foodMapProviderOptimized = StateNotifierProvider<FoodMapNotifierOptimized, List<ProvinceCuisine>>((ref) {
  return FoodMapNotifierOptimized();
});

/// 🔧 简化的已解锁省份Provider
final unlockedProvincesProviderOptimized = Provider<List<ProvinceCuisine>>((ref) {
  final provinces = ref.watch(foodMapProviderOptimized);
  return provinces.where((p) => p.isUnlocked).toList();
});

/// 🔧 简化的即将解锁省份Provider
final nearUnlockProvincesProviderOptimized = Provider<List<ProvinceCuisine>>((ref) {
  final provinces = ref.watch(foodMapProviderOptimized);
  return provinces.where((p) => p.isNearUnlock).toList();
});

/// 🔧 简化的美食地图统计Provider
final foodMapStatisticsProviderOptimized = Provider<Map<String, dynamic>>((ref) {
  final provinces = ref.watch(foodMapProviderOptimized);
  final unlockedCount = provinces.where((p) => p.isUnlocked).length;
  final totalCount = provinces.length;
  
  int completedDishes = 0;
  int totalDishes = 0;
  
  for (final province in provinces) {
    completedDishes += province.dishes.where((d) => d.isCompleted).length;
    totalDishes += province.dishes.length;
  }
  
  return {
    'unlockedProvinces': unlockedCount,
    'totalProvinces': totalCount,
    'provinceProgress': totalCount > 0 ? unlockedCount / totalCount : 0.0,
    'completedDishes': completedDishes,
    'totalDishes': totalDishes,
    'dishProgress': totalDishes > 0 ? completedDishes / totalDishes : 0.0,
  };
});

/// 🔧 简化的推荐菜品Provider
final recommendedDishProviderOptimized = Provider<RegionalDish?>((ref) {
  final provinces = ref.watch(foodMapProviderOptimized);
  
  // 简化推荐逻辑
  for (final province in provinces) {
    final uncompletedDish = province.dishes.firstWhere(
      (d) => !d.isCompleted,
      orElse: () => const RegionalDish(
        id: '',
        name: '',
        description: '',
        emoji: '',
        difficulty: 0,
        cookTime: 0,
      ),
    );
    if (uncompletedDish.id.isNotEmpty) {
      return uncompletedDish;
    }
  }
  
  return null;
});