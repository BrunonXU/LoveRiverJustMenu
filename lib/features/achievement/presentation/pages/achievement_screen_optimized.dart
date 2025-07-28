import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/achievement.dart';
import '../../domain/providers/achievement_provider_optimized.dart';
import '../widgets/achievement_card.dart';

/// 🔧 性能优化版成就系统主页面
class AchievementScreenOptimized extends ConsumerStatefulWidget {
  const AchievementScreenOptimized({super.key});

  @override
  ConsumerState<AchievementScreenOptimized> createState() => _AchievementScreenOptimizedState();
}

class _AchievementScreenOptimizedState extends ConsumerState<AchievementScreenOptimized>
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
    // 🔧 性能优化：只使用一个Consumer，减少重建
    return Consumer(
      builder: (context, ref, child) {
        // 🔧 一次性获取所有数据，避免多次watch
        final achievements = ref.watch(achievementProviderOptimized);
        final statistics = ref.watch(achievementStatisticsProviderOptimized);
        final userLevel = ref.watch(userLevelProviderOptimized);
        
        // 🔧 预计算数据，避免在build中计算
        final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
        final nearCompleteAchievements = achievements.where((a) => a.progress >= 0.8 && !a.isUnlocked).toList();
        
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
              '成就树',
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  // 🔧 传递预计算的数据
                  _buildUserLevelHeader(userLevel, statistics),
                  
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
                  _buildSimpleTreeView(unlockedAchievements),
                  _buildSimpleCategoryView(achievements),
                  _buildSimpleStatsView(statistics, userLevel, unlockedAchievements),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserLevelHeader(Map<String, dynamic> userLevel, Map<String, dynamic> statistics) {
    return RepaintBoundary( // 🔧 隔离重绘
      child: Container(
        margin: AppSpacing.pagePadding,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.emotionGradient.colors.first.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          children: [
            // 等级图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userLevel['emoji'] ?? '🌱',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            
            Space.w16,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userLevel['level'] ?? '美食萌新',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Space.h4,
                  Text(
                    '${statistics['totalPoints']}积分 · ${statistics['unlockedCount']}个成就',
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          Tab(text: '成长树'),
          Tab(text: '分类'),
          Tab(text: '统计'),
        ],
      ),
    );
  }

  /// 🔧 简化的成长树视图 - 去除复杂3D动画
  Widget _buildSimpleTreeView(List<Achievement> unlockedAchievements) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // 简化的进度总览
            MinimalCard(
              child: Column(
                children: [
                  Text(
                    '成长进度',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  Space.h16,
                  
                  // 简化的环形进度
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: unlockedAchievements.length / 20, // 假设总共20个成就
                          strokeWidth: 8,
                          backgroundColor: AppColors.backgroundSecondary,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${unlockedAchievements.length}',
                              style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '个成就',
                              style: AppTypography.captionStyle(isDark: false).copyWith(
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
            ),
            
            Space.h24,
            
            // 成就列表 - 简化显示
            ...unlockedAchievements.take(5).map((achievement) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementCard(
                  achievement: achievement, // 🔧 修复：传递实际achievement
                  isCompact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 简化的分类视图
  Widget _buildSimpleCategoryView(List<Achievement> achievements) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // 简化的分类统计
            MinimalCard(
              child: Text(
                '成就分类',
                style: AppTypography.titleMediumStyle(isDark: false),
                textAlign: TextAlign.center,
              ),
            ),
            
            Space.h24,
            
            // 简化的成就列表
            ...achievements.take(3).map((achievement) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AchievementCard(
                  achievement: achievement, // 🔧 修复：传递实际achievement
                  isCompact: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 简化的统计视图
  Widget _buildSimpleStatsView(
    Map<String, dynamic> statistics,
    Map<String, dynamic> userLevel,
    List<Achievement> unlockedAchievements,
  ) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            MinimalCard(
              child: Column(
                children: [
                  Text(
                    '统计信息',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  Space.h16,
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('总积分', '${statistics['totalPoints'] ?? 0}', Icons.star),
                      _buildStatItem('已解锁', '${unlockedAchievements.length}', Icons.lock_open),
                      _buildStatItem('等级', userLevel['level'] ?? '萌新', Icons.trending_up),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        Space.h8,
        Text(
          value,
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
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
}