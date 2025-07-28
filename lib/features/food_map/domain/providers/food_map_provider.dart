import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/province_cuisine.dart';

/// 美食地图状态管理
class FoodMapNotifier extends StateNotifier<List<ProvinceCuisine>> {
  FoodMapNotifier() : super(FoodMapData.getAllProvinces()) {
    _loadProgress();
  }

  /// 从本地存储加载进度
  void _loadProgress() {
    // TODO: 从Hive数据库加载实际的进度数据
    // 目前使用模拟数据进行演示
    _simulateProgress();
  }

  /// 模拟进度数据 - 演示用
  void _simulateProgress() {
    final updatedProvinces = state.map((province) {
      switch (province.province) {
        case ChineseProvince.sichuan:
          // 四川已解锁
          return province.copyWith(
            isUnlocked: true,
            unlockProgress: 1.0,
            unlockDate: DateTime.now().subtract(const Duration(days: 10)),
            dishes: province.dishes.map((dish) {
              if (dish.id == 'sc_001' || dish.id == 'sc_002') {
                // 前两道菜已完成
                return RegionalDish(
                  id: dish.id,
                  name: dish.name,
                  description: dish.description,
                  emoji: dish.emoji,
                  difficulty: dish.difficulty,
                  cookTime: dish.cookTime,
                  isSignature: dish.isSignature,
                  isCompleted: true,
                  completedAt: DateTime.now().subtract(const Duration(days: 5)),
                );
              }
              return dish;
            }).toList(),
          );
          
        case ChineseProvince.guangdong:
          // 广东接近解锁
          return province.copyWith(
            unlockProgress: 0.67, // 2/3 进度
            dishes: province.dishes.map((dish) {
              if (dish.id == 'gd_001' || dish.id == 'gd_003') {
                return RegionalDish(
                  id: dish.id,
                  name: dish.name,
                  description: dish.description,
                  emoji: dish.emoji,
                  difficulty: dish.difficulty,
                  cookTime: dish.cookTime,
                  isSignature: dish.isSignature,
                  isCompleted: true,
                  completedAt: DateTime.now().subtract(const Duration(days: 2)),
                );
              }
              return dish;
            }).toList(),
          );
          
        case ChineseProvince.beijing:
          // 北京有一些进度
          return province.copyWith(
            unlockProgress: 0.5, // 1/2 进度
            dishes: province.dishes.map((dish) {
              if (dish.id == 'bj_002') {
                return RegionalDish(
                  id: dish.id,
                  name: dish.name,
                  description: dish.description,
                  emoji: dish.emoji,
                  difficulty: dish.difficulty,
                  cookTime: dish.cookTime,
                  isSignature: dish.isSignature,
                  isCompleted: true,
                  completedAt: DateTime.now().subtract(const Duration(days: 1)),
                );
              }
              return dish;
            }).toList(),
          );
          
        case ChineseProvince.shanghai:
          // 上海刚解锁
          return province.copyWith(
            isUnlocked: true,
            unlockProgress: 1.0,
            unlockDate: DateTime.now().subtract(const Duration(hours: 2)),
          );
          
        default:
          return province;
      }
    }).toList();

    state = updatedProvinces;
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
        
        // 计算新的进度
        final completedCount = updatedDishes.where((d) => d.isCompleted).length;
        final newProgress = completedCount / p.requiredDishes;
        
        // 检查是否解锁
        if (newProgress >= 1.0 && !p.isUnlocked) {
          HapticFeedback.heavyImpact();
          _showUnlockAnimation(p);
          
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
    
    // TODO: 保存进度到本地存储
  }

  /// 显示解锁动画
  void _showUnlockAnimation(ProvinceCuisine province) {
    // TODO: 显示省份解锁的庆祝动画
    print('🎉 恭喜解锁${province.provinceName}美食！');
  }

  /// 获取已解锁的省份数量
  int get unlockedCount {
    return state.where((p) => p.isUnlocked).length;
  }

  /// 获取总省份数量
  int get totalCount {
    return state.length;
  }

  /// 获取解锁进度
  double get totalProgress {
    return unlockedCount / totalCount;
  }

  /// 获取已完成的菜品总数
  int get completedDishesCount {
    return state.fold(0, (sum, province) {
      return sum + province.dishes.where((d) => d.isCompleted).length;
    });
  }

  /// 获取所有菜品总数
  int get totalDishesCount {
    return state.fold(0, (sum, province) => sum + province.dishes.length);
  }

  /// 获取即将解锁的省份
  List<ProvinceCuisine> get nearUnlockProvinces {
    return state.where((p) => p.isNearUnlock).toList();
  }

  /// 获取已解锁的省份
  List<ProvinceCuisine> get unlockedProvinces {
    return state.where((p) => p.isUnlocked).toList();
  }

  /// 获取特定菜系的省份
  List<ProvinceCuisine> getProvincesByCuisineStyle(String cuisineStyle) {
    return state.where((p) => p.cuisineStyle == cuisineStyle).toList();
  }

  /// 搜索菜品
  List<RegionalDish> searchDishes(String query) {
    final results = <RegionalDish>[];
    final lowerQuery = query.toLowerCase();
    
    for (final province in state) {
      for (final dish in province.dishes) {
        if (dish.name.toLowerCase().contains(lowerQuery) ||
            dish.description.toLowerCase().contains(lowerQuery)) {
          results.add(dish);
        }
      }
    }
    
    return results;
  }

  /// 获取推荐的下一道菜
  RegionalDish? getRecommendedDish() {
    // 优先推荐即将解锁省份的未完成菜品
    for (final province in nearUnlockProvinces) {
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
    
    // 其次推荐已解锁省份的未完成菜品
    for (final province in unlockedProvinces) {
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
  }
}

/// 美食地图Provider
final foodMapProvider = StateNotifierProvider<FoodMapNotifier, List<ProvinceCuisine>>((ref) {
  return FoodMapNotifier();
});

/// 已解锁省份Provider
final unlockedProvincesProvider = Provider<List<ProvinceCuisine>>((ref) {
  final provinces = ref.watch(foodMapProvider);
  return provinces.where((p) => p.isUnlocked).toList();
});

/// 即将解锁省份Provider
final nearUnlockProvincesProvider = Provider<List<ProvinceCuisine>>((ref) {
  final provinces = ref.watch(foodMapProvider);
  return provinces.where((p) => p.isNearUnlock).toList();
});

/// 美食地图统计Provider
final foodMapStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final provinces = ref.watch(foodMapProvider);
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
    'provinceProgress': unlockedCount / totalCount,
    'completedDishes': completedDishes,
    'totalDishes': totalDishes,
    'dishProgress': totalDishes > 0 ? completedDishes / totalDishes : 0.0,
  };
});

/// 推荐菜品Provider
final recommendedDishProvider = Provider<RegionalDish?>((ref) {
  final notifier = ref.watch(foodMapProvider.notifier);
  return notifier.getRecommendedDish();
});