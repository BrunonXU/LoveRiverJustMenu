import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/province_cuisine.dart';
import '../../domain/providers/food_map_provider_optimized.dart';
import '../widgets/province_card.dart';

/// 🔧 性能优化版美食地图主页面
class FoodMapScreenOptimized extends ConsumerStatefulWidget {
  const FoodMapScreenOptimized({super.key});

  @override
  ConsumerState<FoodMapScreenOptimized> createState() => _FoodMapScreenOptimizedState();
}

class _FoodMapScreenOptimizedState extends ConsumerState<FoodMapScreenOptimized>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    
    // 🔧 性能优化：减少动画时长
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 性能优化：只使用一个Consumer
    return Consumer(
      builder: (context, ref, child) {
        // 🔧 一次性获取所有数据
        final provinces = ref.watch(foodMapProviderOptimized);
        final statistics = ref.watch(foodMapStatisticsProviderOptimized);
        
        // 🔧 预计算数据，避免在build中重复计算
        final unlockedProvinces = provinces.where((p) => p.isUnlocked).toList();
        final nearUnlockProvinces = provinces.where((p) => p.isNearUnlock).toList();
        final lockedProvinces = provinces.where((p) => !p.isUnlocked && !p.isNearUnlock).toList();
        
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '美食地图',
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(150),
              child: Column(
                children: [
                  // 🔧 传递预计算的数据
                  _buildStatisticsHeader(statistics),
                  
                  Space.h16,
                  
                  _buildTabBar(),
                  
                  Space.h16,
                ],
              ),
            ),
          ),
          body: RepaintBoundary( // 🔧 隔离重绘区域
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSimpleMapView(provinces),
                  _buildSimpleListView(unlockedProvinces, nearUnlockProvinces, lockedProvinces),
                  _buildSimpleProgressView(statistics, provinces),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsHeader(Map<String, dynamic> statistics) {
    return RepaintBoundary( // 🔧 隔离重绘
      child: Container(
        margin: AppSpacing.pagePadding,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.emotionGradient.colors.first.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: '🗺️',
                  value: '${statistics['unlockedProvinces']}/${statistics['totalProvinces']}',
                  label: '已解锁',
                  color: AppColors.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                _buildStatItem(
                  icon: '🍜',
                  value: '${statistics['completedDishes']}',
                  label: '已完成',
                  color: AppColors.emotionGradient.colors.first,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                _buildStatItem(
                  icon: '📈',
                  value: '${(statistics['provinceProgress'] * 100).round()}%',
                  label: '探索度',
                  color: const Color(0xFF4ECB71),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        Space.h4,
        Text(
          value,
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.bodyMediumStyle(isDark: false).copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTypography.bodyMediumStyle(isDark: false),
        tabs: const [
          Tab(text: '地图'),
          Tab(text: '列表'),
          Tab(text: '进度'),
        ],
      ),
    );
  }

  /// 🔧 简化的地图视图 - 去除复杂地图组件
  Widget _buildSimpleMapView(List<ProvinceCuisine> provinces) {
    final unlockedProvinces = provinces.where((p) => p.isUnlocked).toList();
    
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // 简化的地图概览
            MinimalCard(
              child: Column(
                children: [
                  Text(
                    '美食地图概览',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  Space.h16,
                  
                  // 简化的进度展示
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 60,
                            color: AppColors.primary,
                          ),
                          Space.h12,
                          Text(
                            '已解锁 ${unlockedProvinces.length} 个省份',
                            style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Space.h24,
            
            // 推荐省份
            Text(
              '推荐探索',
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h12,
            
            // 显示前3个推荐省份
            ...provinces.take(3).map((province) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProvinceCard(
                  province: province,
                  isCompact: true,
                  onTap: () => _showProvinceDetail(province.province),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 简化的列表视图
  Widget _buildSimpleListView(
    List<ProvinceCuisine> unlockedProvinces,
    List<ProvinceCuisine> nearUnlockProvinces,
    List<ProvinceCuisine> lockedProvinces,
  ) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 已解锁省份
            if (unlockedProvinces.isNotEmpty) ...[
              _buildSectionHeader('已解锁', unlockedProvinces.length, const Color(0xFF4ECB71)),
              Space.h12,
              ...unlockedProvinces.take(3).map((province) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProvinceCard(
                  province: province,
                  onTap: () => _showProvinceDetail(province.province),
                ),
              )),
              Space.h24,
            ],
            
            // 即将解锁省份
            if (nearUnlockProvinces.isNotEmpty) ...[
              _buildSectionHeader('即将解锁', nearUnlockProvinces.length, AppColors.emotionGradient.colors.first),
              Space.h12,
              ...nearUnlockProvinces.take(2).map((province) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProvinceCard(
                  province: province,
                  onTap: () => _showProvinceDetail(province.province),
                ),
              )),
              Space.h24,
            ],
            
            // 未解锁省份 - 只显示部分
            if (lockedProvinces.isNotEmpty) ...[
              _buildSectionHeader('待探索', lockedProvinces.length, AppColors.textSecondary),
              Space.h12,
              ...lockedProvinces.take(2).map((province) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProvinceCard(
                  province: province,
                  onTap: () => _showProvinceDetail(province.province),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔧 简化的进度视图
  Widget _buildSimpleProgressView(Map<String, dynamic> statistics, List<ProvinceCuisine> provinces) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // 总体进度卡片
            MinimalCard(
              child: Column(
                children: [
                  Text(
                    '美食探索进度',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  Space.h24,
                  
                  // 简化的环形进度图
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: statistics['provinceProgress'],
                          strokeWidth: 12,
                          backgroundColor: AppColors.backgroundSecondary,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(statistics['provinceProgress'] * 100).round()}%',
                              style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '总进度',
                              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Space.h24,
                  
                  // 详细统计
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressStatItem(
                        '省份',
                        '${statistics['unlockedProvinces']}/${statistics['totalProvinces']}',
                        Icons.map,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      _buildProgressStatItem(
                        '菜品',
                        '${statistics['completedDishes']}/${statistics['totalDishes']}',
                        Icons.restaurant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Icon(
          title == '已解锁' ? Icons.lock_open : 
          title == '即将解锁' ? Icons.hourglass_empty : Icons.lock,
          color: color,
          size: 20,
        ),
        Space.w8,
        Text(
          title,
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Space.w8,
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            '$count',
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
        Space.h4,
        Text(
          value,
          style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showProvinceDetail(ChineseProvince province) {
    HapticFeedback.lightImpact();
    // 简化导航，避免复杂页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${province.toString()} 详情功能开发中'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}