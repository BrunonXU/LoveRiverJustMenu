import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/models/achievement.dart';
import '../../domain/providers/achievement_provider.dart';
import '../widgets/achievement_card.dart';
import '../widgets/achievement_tree_widget.dart';
import '../widgets/user_level_header.dart';

/// 厨房恋人成长树 - 成就系统主页面
class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({super.key});

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
          '厨房恋人成长树',
          style: AppTypography.titleMediumStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 用户等级头部
              const UserLevelHeader(),
              
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
            _buildAchievementTree(),    // 成长树视图
            _buildCategoryView(),       // 分类视图
            _buildStatisticsView(),     // 统计视图
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

  /// 成长树视图 - 3D可视化展示
  Widget _buildAchievementTree() {
    return Consumer(
      builder: (context, ref, child) {
        final achievements = ref.watch(achievementProvider);
        
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 3D成长树组件
              BreathingWidget(
                child: Container(
                  height: 400,
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
                  child: AchievementTreeWidget(achievements: achievements),
                ),
              ),
              
              Space.h24,
              
              // 接近完成的成就
              _buildNearCompleteSection(),
              
              Space.h24,
              
              // 最新解锁的成就
              _buildRecentUnlockedSection(),
            ],
          ),
        );
      },
    );
  }

  /// 分类视图 - 按成就类型分组展示
  Widget _buildCategoryView() {
    return Consumer(
      builder: (context, ref, child) {
        final achievements = ref.watch(achievementProvider);
        final groupedAchievements = <AchievementCategory, List<Achievement>>{};
        
        // 按分类分组
        for (final achievement in achievements) {
          groupedAchievements.putIfAbsent(achievement.category, () => []).add(achievement);
        }
        
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...groupedAchievements.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryHeader(entry.key, entry.value),
                    Space.h16,
                    ...entry.value.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AchievementCard(achievement: achievement),
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

  /// 统计视图 - 成就完成情况统计
  Widget _buildStatisticsView() {
    return Consumer(
      builder: (context, ref, child) {
        final statistics = ref.watch(achievementStatisticsProvider);
        final userLevel = ref.watch(userLevelProvider);
        
        return SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              // 总体统计卡片
              _buildStatisticsCard(statistics, userLevel, ref.watch(unlockedAchievementsProvider)),
              
              Space.h24,
              
              // 分类统计图表
              _buildCategoryStatistics(),
              
              Space.h24,
              
              // 成就时间线
              _buildAchievementTimeline(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNearCompleteSection() {
    return Consumer(
      builder: (context, ref, child) {
        final nearComplete = ref.watch(nearCompleteAchievementsProvider);
        
        if (nearComplete.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
                Space.w8,
                Text(
                  '即将完成',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            Space.h12,
            
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nearComplete.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 250,
                    margin: EdgeInsets.only(right: AppSpacing.md),
                    child: AchievementCard(
                      achievement: nearComplete[index],
                      isCompact: true,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentUnlockedSection() {
    return Consumer(
      builder: (context, ref, child) {
        final unlocked = ref.watch(unlockedAchievementsProvider);
        final recent = unlocked
            .where((a) => a.unlockedAt != null)
            .toList()
          ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
        
        if (recent.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: AppColors.emotionGradient.colors.first,
                  size: 20,
                ),
                Space.w8,
                Text(
                  '最新解锁',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.emotionGradient.colors.first,
                  ),
                ),
              ],
            ),
            
            Space.h12,
            
            ...recent.take(3).map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AchievementCard(
                achievement: achievement,
                showUnlockAnimation: true,
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(AchievementCategory category, List<Achievement> categoryAchievements) {
    String emoji;
    switch (category) {
      case AchievementCategory.cooking:
        emoji = '🍳';
        break;
      case AchievementCategory.love:
        emoji = '💕';
        break;
      case AchievementCategory.exploration:
        emoji = '🌟';
        break;
      case AchievementCategory.creativity:
        emoji = '🎨';
        break;
      case AchievementCategory.memory:
        emoji = '📸';
        break;
      case AchievementCategory.challenge:
        emoji = '🏅';
        break;
    }
    
    final unlockedCount = categoryAchievements.where((a) => a.isUnlocked).length;
    final totalCount = categoryAchievements.length;
    
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        Space.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryAchievements.first.categoryName,
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$unlockedCount/$totalCount 已解锁',
                style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          child: Text(
            '${((unlockedCount / totalCount) * 100).round()}%',
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> statistics, Map<String, dynamic> userLevel, List<Achievement> unlockedAchievements) {
    return MinimalCard(
      child: Column(
        children: [
          // 用户等级显示
          Row(
            children: [
              Text(
                userLevel['emoji'],
                style: const TextStyle(fontSize: 40),
              ),
              Space.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userLevel['level'],
                      style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                        fontWeight: FontWeight.w300,
                        color: userLevel['color'],
                      ),
                    ),
                    Text(
                      '总积分: ${unlockedAchievements.fold(0, (sum, achievement) => sum + achievement.points)}',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Space.h24,
          
          // 统计数据
          Row(
            children: [
              _buildStatisticItem('总成就', statistics['total'].toString(), Icons.emoji_events),
              _buildStatisticItem('已解锁', statistics['unlocked'].toString(), Icons.check_circle),
              _buildStatisticItem('进行中', statistics['inProgress'].toString(), Icons.hourglass_empty),
            ],
          ),
          
          Space.h16,
          
          // 完成度进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '完成度',
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(statistics['completionRate'] * 100).round()}%',
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Space.h8,
              LinearProgressIndicator(
                value: statistics['completionRate'],
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
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
            title,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatistics() {
    // TODO: 实现分类统计图表
    return MinimalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '分类统计',
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Space.h16,
          Text(
            '各类成就完成情况图表',
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          // TODO: 添加饼图或柱状图
        ],
      ),
    );
  }

  Widget _buildAchievementTimeline() {
    return Consumer(
      builder: (context, ref, child) {
        final unlocked = ref.watch(unlockedAchievementsProvider);
        final sorted = unlocked
            .where((a) => a.unlockedAt != null)
            .toList()
          ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
        
        if (sorted.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return MinimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '成就时间线',
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Space.h16,
              ...sorted.take(5).map((achievement) => _buildTimelineItem(achievement)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            achievement.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          Space.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(achievement.unlockedAt!),
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: achievement.levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Text(
              '+${achievement.points}',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: achievement.levelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return '今天';
    if (difference.inDays == 1) return '昨天';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    return '${date.month}月${date.day}日';
  }
}