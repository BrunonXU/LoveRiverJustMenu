import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/province_cuisine.dart';
import '../../domain/providers/food_map_provider.dart';
import '../widgets/china_map_widget.dart';
import '../widgets/province_card.dart';
import '../widgets/dish_progress_card.dart';
import 'province_detail_screen.dart';

/// 美食地图主页面
class FoodMapScreen extends ConsumerStatefulWidget {
  const FoodMapScreen({super.key});

  @override
  ConsumerState<FoodMapScreen> createState() => _FoodMapScreenState();
}

class _FoodMapScreenState extends ConsumerState<FoodMapScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // 当前选中的省份
  ChineseProvince? _selectedProvince;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    final statistics = ref.watch(foodMapStatisticsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
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
              // 统计信息头部
              _buildStatisticsHeader(statistics),
              
              Space.h16,
              
              // 标签页切换
              _buildTabBar(),
              
              Space.h16,
            ],
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMapView(),      // 地图视图
            _buildListView(),     // 列表视图
            _buildProgressView(), // 进度视图
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(Map<String, dynamic> statistics) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: BreathingWidget(
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

  /// 地图视图
  Widget _buildMapView() {
    return Consumer(
      builder: (context, ref, child) {
        final provinces = ref.watch(foodMapProvider);
        
        return Column(
          children: [
            // 中国地图
            Expanded(
              flex: 3,
              child: Container(
                margin: AppSpacing.pagePadding,
                child: BreathingWidget(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ChinaMapWidget(
                      provinces: provinces,
                      selectedProvince: _selectedProvince,
                      onProvinceSelected: (province) {
                        setState(() {
                          _selectedProvince = province;
                        });
                        _showProvinceDetail(province);
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // 推荐区域
            Expanded(
              flex: 2,
              child: _buildRecommendations(),
            ),
          ],
        );
      },
    );
  }

  /// 列表视图
  Widget _buildListView() {
    return Consumer(
      builder: (context, ref, child) {
        final provinces = ref.watch(foodMapProvider);
        final groupedProvinces = <String, List<ProvinceCuisine>>{};
        
        // 按状态分组
        groupedProvinces['已解锁'] = provinces.where((p) => p.isUnlocked).toList();
        groupedProvinces['即将解锁'] = provinces.where((p) => p.isNearUnlock).toList();
        groupedProvinces['未解锁'] = provinces.where((p) => !p.isUnlocked && !p.isNearUnlock).toList();
        
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...groupedProvinces.entries.where((e) => e.value.isNotEmpty).map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(entry.key, entry.value.length),
                    Space.h12,
                    ...entry.value.map((province) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProvinceCard(
                        province: province,
                        onTap: () => _showProvinceDetail(province.province),
                      ),
                    )),
                    Space.h24,
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// 进度视图
  Widget _buildProgressView() {
    return Consumer(
      builder: (context, ref, child) {
        final provinces = ref.watch(foodMapProvider);
        final statistics = ref.watch(foodMapStatisticsProvider);
        final recommendedDish = ref.watch(recommendedDishProvider);
        
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 总体进度卡片
              _buildOverallProgressCard(statistics),
              
              Space.h24,
              
              // 推荐菜品
              if (recommendedDish != null) ...[
                _buildRecommendedDishCard(recommendedDish),
                Space.h24,
              ],
              
              // 各省进度
              _buildProvincesProgressList(provinces),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendations() {
    return Consumer(
      builder: (context, ref, child) {
        final nearUnlock = ref.watch(nearUnlockProvincesProvider);
        final recommendedDish = ref.watch(recommendedDishProvider);
        
        return Container(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.emotionGradient.colors.first,
                    size: 20,
                  ),
                  Space.w8,
                  Text(
                    '推荐探索',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.emotionGradient.colors.first,
                    ),
                  ),
                ],
              ),
              
              Space.h12,
              
              if (nearUnlock.isNotEmpty) ...[
                Text(
                  '即将解锁',
                  style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Space.h8,
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: nearUnlock.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: AppSpacing.md),
                        child: ProvinceCard(
                          province: nearUnlock[index],
                          isCompact: true,
                          onTap: () => _showProvinceDetail(nearUnlock[index].province),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              if (recommendedDish != null) ...[
                Space.h12,
                Text(
                  '推荐菜品',
                  style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Space.h8,
                DishProgressCard(
                  dish: recommendedDish,
                  showProgress: false,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    Color color;
    IconData icon;
    
    switch (title) {
      case '已解锁':
        color = const Color(0xFF4ECB71);
        icon = Icons.lock_open;
        break;
      case '即将解锁':
        color = AppColors.emotionGradient.colors.first;
        icon = Icons.hourglass_empty;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.lock;
    }
    
    return Row(
      children: [
        Icon(
          icon,
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

  Widget _buildOverallProgressCard(Map<String, dynamic> statistics) {
    return MinimalCard(
      child: Column(
        children: [
          Text(
            '美食探索进度',
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          Space.h24,
          
          // 环形进度图
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

  Widget _buildRecommendedDishCard(RegionalDish dish) {
    return MinimalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: AppColors.emotionGradient.colors.first,
                size: 20,
              ),
              Space.w8,
              Text(
                '推荐尝试',
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.emotionGradient.colors.first,
                ),
              ),
            ],
          ),
          
          Space.h16,
          
          DishProgressCard(
            dish: dish,
            showProgress: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProvincesProgressList(List<ProvinceCuisine> provinces) {
    // 按进度排序
    final sortedProvinces = List<ProvinceCuisine>.from(provinces)
      ..sort((a, b) => b.unlockProgress.compareTo(a.unlockProgress));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '各省进度',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h16,
        
        ...sortedProvinces.take(10).map((province) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildProvinceProgressItem(province),
        )),
      ],
    );
  }

  Widget _buildProvinceProgressItem(ProvinceCuisine province) {
    return GestureDetector(
      onTap: () => _showProvinceDetail(province.province),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: province.isUnlocked 
                ? province.themeColor.withOpacity(0.3)
                : AppColors.textSecondary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              province.iconEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            Space.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        province.provinceName,
                        style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Space.w8,
                      if (province.isUnlocked)
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF4ECB71),
                          size: 16,
                        ),
                    ],
                  ),
                  Space.h4,
                  LinearProgressIndicator(
                    value: province.unlockProgress,
                    backgroundColor: AppColors.backgroundSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      province.isUnlocked 
                          ? const Color(0xFF4ECB71)
                          : province.isNearUnlock 
                              ? AppColors.emotionGradient.colors.first
                              : AppColors.primary,
                    ),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
            Space.w12,
            Text(
              '${province.progressPercentage}%',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: province.isUnlocked 
                    ? const Color(0xFF4ECB71)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProvinceDetail(ChineseProvince province) {
    HapticFeedback.lightImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProvinceDetailScreen(province: province),
      ),
    );
  }
}