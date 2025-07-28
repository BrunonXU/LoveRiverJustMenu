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
import '../widgets/dish_progress_card.dart';

/// 省份详情页面
class ProvinceDetailScreen extends ConsumerStatefulWidget {
  final ChineseProvince province;

  const ProvinceDetailScreen({
    super.key,
    required this.province,
  });

  @override
  ConsumerState<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends ConsumerState<ProvinceDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    );
    
    _fadeController.forward();
    _headerController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provinces = ref.watch(foodMapProvider);
    final provinceData = provinces.firstWhere((p) => p.province == widget.province);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // 自定义AppBar
            _buildSliverAppBar(provinceData),
            
            // 内容区域
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(provinceData),
                  _buildDishesTab(provinceData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ProvinceCuisine provinceData) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: provinceData.themeColor.withOpacity(0.9),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                provinceData.themeColor,
                provinceData.themeColor.withOpacity(0.8),
              ],
            ),
          ),
          child: ScaleTransition(
            scale: _headerAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 省份图标
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      provinceData.iconEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                
                Space.h16,
                
                // 省份名称
                Text(
                  provinceData.provinceName,
                  style: AppTypography.titleLargeStyle(isDark: true).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                Space.h8,
                
                // 菜系标签
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    provinceData.cuisineStyle,
                    style: AppTypography.bodyMediumStyle(isDark: true).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                Space.h12,
                
                // 解锁状态
                if (provinceData.isUnlocked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      Space.w8,
                      Text(
                        '已解锁',
                        style: AppTypography.bodySmallStyle(isDark: true).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        '解锁进度 ${provinceData.progressPercentage}%',
                        style: AppTypography.bodySmallStyle(isDark: true).copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Space.h8,
                      Container(
                        width: 200,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: provinceData.unlockProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: provinceData.themeColor.withOpacity(0.9),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: AppTypography.bodyMediumStyle(isDark: true).copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: AppTypography.bodyMediumStyle(isDark: true),
            tabs: const [
              Tab(text: '概览'),
              Tab(text: '菜品'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ProvinceCuisine provinceData) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space.h24,
          
          // 菜系介绍
          BreathingWidget(
            child: MinimalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: provinceData.themeColor,
                        size: 24,
                      ),
                      Space.w12,
                      Text(
                        '菜系特色',
                        style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w500,
                          color: provinceData.themeColor,
                        ),
                      ),
                    ],
                  ),
                  
                  Space.h16,
                  
                  Text(
                    provinceData.description,
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Space.h24,
          
          // 特色元素
          MinimalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: provinceData.themeColor,
                      size: 24,
                    ),
                    Space.w12,
                    Text(
                      '特色元素',
                      style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                        fontWeight: FontWeight.w500,
                        color: provinceData.themeColor,
                      ),
                    ),
                  ],
                ),
                
                Space.h16,
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provinceData.features.map((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: provinceData.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        border: Border.all(
                          color: provinceData.themeColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        feature,
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: provinceData.themeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          Space.h24,
          
          // 解锁提示
          if (!provinceData.isUnlocked && provinceData.unlockTips.isNotEmpty)
            MinimalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.emotionGradient.colors.first,
                        size: 24,
                      ),
                      Space.w12,
                      Text(
                        '解锁提示',
                        style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.emotionGradient.colors.first,
                        ),
                      ),
                    ],
                  ),
                  
                  Space.h16,
                  
                  ...provinceData.unlockTips.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tip = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < provinceData.unlockTips.length - 1 ? 8 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emotionGradient.colors.first.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.emotionGradient.colors.first.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTypography.captionStyle(isDark: false).copyWith(
                                  color: AppColors.emotionGradient.colors.first,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          Space.w12,
                          Expanded(
                            child: Text(
                              tip,
                              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          
          Space.h48,
        ],
      ),
    );
  }

  Widget _buildDishesTab(ProvinceCuisine provinceData) {
    final completedDishes = provinceData.dishes.where((d) => d.isCompleted).toList();
    final uncompletedDishes = provinceData.dishes.where((d) => !d.isCompleted).toList();
    
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space.h24,
          
          // 菜品统计
          MinimalCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDishStatItem(
                  '总计',
                  '${provinceData.dishes.length}',
                  Icons.restaurant,
                  AppColors.textPrimary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                _buildDishStatItem(
                  '已完成',
                  '${completedDishes.length}',
                  Icons.check_circle,
                  const Color(0xFF4ECB71),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
                _buildDishStatItem(
                  '待制作',
                  '${uncompletedDishes.length}',
                  Icons.schedule,
                  AppColors.emotionGradient.colors.first,
                ),
              ],
            ),
          ),
          
          Space.h24,
          
          // 已完成菜品
          if (completedDishes.isNotEmpty) ...[
            _buildSectionHeader('已完成', completedDishes.length, const Color(0xFF4ECB71)),
            Space.h12,
            ...completedDishes.map((dish) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DishProgressCard(
                dish: dish,
                onTap: () => _showDishDetail(dish, provinceData),
              ),
            )),
            Space.h24,
          ],
          
          // 待制作菜品
          if (uncompletedDishes.isNotEmpty) ...[
            _buildSectionHeader('待制作', uncompletedDishes.length, AppColors.emotionGradient.colors.first),
            Space.h12,
            ...uncompletedDishes.map((dish) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DishProgressCard(
                dish: dish,
                onTap: () => _showDishDetail(dish, provinceData),
              ),
            )),
          ],
          
          Space.h48,
        ],
      ),
    );
  }

  Widget _buildDishStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        Space.h8,
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

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Icon(
          title == '已完成' ? Icons.check_circle : Icons.schedule,
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

  void _showDishDetail(RegionalDish dish, ProvinceCuisine provinceData) {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDishDetailSheet(dish, provinceData),
    );
  }

  Widget _buildDishDetailSheet(RegionalDish dish, ProvinceCuisine provinceData) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 菜品标题
                  Row(
                    children: [
                      Text(
                        dish.emoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      Space.w16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dish.name,
                              style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Space.h4,
                            Row(
                              children: [
                                if (dish.isSignature) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.emotionGradient,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                    ),
                                    child: Text(
                                      '招牌菜',
                                      style: AppTypography.captionStyle(isDark: false).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Space.w8,
                                ],
                                Text(
                                  '${dish.difficultyText} · ${dish.cookTime}分钟',
                                  style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  Space.h24,
                  
                  // 菜品描述
                  Text(
                    dish.description,
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  Space.h32,
                  
                  // 操作按钮
                  if (!dish.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: 跳转到菜谱详情页开始制作
                          Navigator.of(context).pop();
                          _markDishAsCompleted(dish, provinceData);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            '开始制作',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLargeStyle(isDark: true).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markDishAsCompleted(RegionalDish dish, ProvinceCuisine provinceData) {
    // 模拟完成菜品
    ref.read(foodMapProvider.notifier).completeDish(provinceData.province, dish.id);
    
    // 显示完成提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('恭喜完成《${dish.name}》！'),
        backgroundColor: const Color(0xFF4ECB71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}