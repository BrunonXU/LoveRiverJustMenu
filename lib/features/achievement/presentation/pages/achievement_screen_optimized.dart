import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/achievement.dart';
import '../../domain/providers/achievement_provider_optimized.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_tree_simple.dart';

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
                  _buildSimpleTreeView(achievements),
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
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.emotionGradient.colors.first.withValues(alpha: 0.1),
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

  /// 🌳 真正的成就树视图 - 使用树状可视化组件
  Widget _buildSimpleTreeView(List<Achievement> achievements) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // 成就树标题
            MinimalCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🌳',
                        style: const TextStyle(fontSize: 24),
                      ),
                      Space.w8,
                      Text(
                        '成就之树',
                        style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Space.h8,
                  Text(
                    '滑动查看成就，树会向上生长',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Space.h24,
            
            // 🚀 高性能成就树
            AchievementTreeSimple(
              achievements: achievements,
              onAchievementTap: (achievement) {
                HapticFeedback.lightImpact();
                _showAchievementDetail(achievement);
              },
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

  /// 显示成就详情
  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成就图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: achievement.isUnlocked 
                      ? AppColors.primaryGradient
                      : null,
                  color: achievement.isUnlocked 
                      ? null 
                      : AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: TextStyle(
                      fontSize: achievement.isUnlocked ? 36 : 28,
                    ),
                  ),
                ),
              ),
              
              Space.h16,
              
              // 成就标题
              Text(
                achievement.title,
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              Space.h8,
              
              // 成就描述
              Text(
                achievement.description,
                style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              Space.h16,
              
              // 进度或完成状态
              if (achievement.isUnlocked) ...[ 
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECB71).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4ECB71),
                        size: 16,
                      ),
                      Space.w8,
                      Text(
                        '已完成 · ${achievement.points}积分',
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: const Color(0xFF4ECB71),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // 进度条
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '进度',
                          style: AppTypography.captionStyle(isDark: false).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(achievement.progress * 100).round()}%',
                          style: AppTypography.captionStyle(isDark: false).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Space.h8,
                    LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ],
              
              Space.h24,
              
              // 关闭按钮
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '关闭',
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}