import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/intimacy_level.dart';
import '../../domain/providers/intimacy_provider.dart';
import '../widgets/intimacy_level_card.dart';
import '../widgets/interaction_grid.dart';

/// 🥰 亲密度系统主页面
class IntimacyScreen extends ConsumerStatefulWidget {
  const IntimacyScreen({super.key});

  @override
  ConsumerState<IntimacyScreen> createState() => _IntimacyScreenState();
}

class _IntimacyScreenState extends ConsumerState<IntimacyScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 渐入动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 心跳脉动动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    
    // 启动动画
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                // 等级状态卡片
                _buildLevelStatusCard(),
                
                Space.h24,
                
                // 今日互动网格
                _buildTodayInteractionSection(),
                
                Space.h24,
                
                // 本周统计
                _buildWeeklyStatsSection(),
                
                Space.h24,
                
                // 最近互动记录
                _buildRecentInteractionsSection(),
                
                Space.h48, // 底部留白
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        '亲密度',
        style: AppTypography.titleMediumStyle(isDark: false).copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
      centerTitle: true,
      actions: [
        // 心跳图标
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseAnimation.value * 0.1),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const Text(
                    '💕',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelStatusCard() {
    return Consumer(
      builder: (context, ref, child) {
        final intimacyState = ref.watch(intimacyProvider);
        final progress = ref.watch(intimacyProgressProvider);
        final pointsToNext = ref.watch(pointsToNextLevelProvider);
        
        return BreathingWidget(
          child: IntimacyLevelCard(
            currentLevel: intimacyState.currentLevel,
            totalPoints: intimacyState.totalPoints,
            progress: progress,
            pointsToNext: pointsToNext,
            onTap: () => _showLevelDetail(intimacyState.currentLevel),
          ),
        );
      },
    );
  }

  Widget _buildTodayInteractionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和今日剩余点数
        Consumer(
          builder: (context, ref, child) {
            final remainingPoints = ref.watch(todayRemainingPointsProvider);
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日互动',
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.emotionGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    '可获得 $remainingPoints 积分',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        Space.h16,
        
        // 互动网格
        Consumer(
          builder: (context, ref, child) {
            final availableInteractions = ref.watch(availableInteractionsProvider);
            final intimacyNotifier = ref.watch(intimacyProvider.notifier);
            
            return InteractionGrid(
              interactions: availableInteractions,
              onInteractionTap: (type) => _handleInteraction(type, intimacyNotifier),
              getRemainingCount: (type) => intimacyNotifier.getRemainingCount(type),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyStatsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final weeklyStats = ref.watch(weeklyStatsProvider);
        final consecutiveDays = ref.watch(consecutiveCheckInDaysProvider);
        
        return MinimalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 20)),
                  Space.w8,
                  Text(
                    '本周统计',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              Space.h16,
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '总互动',
                    '${weeklyStats['totalInteractions'] ?? 0}',
                    '次',
                    Icons.favorite,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                  _buildStatItem(
                    '获得积分',
                    '${weeklyStats['pointsEarned'] ?? 0}',
                    '分',
                    Icons.stars,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                  _buildStatItem(
                    '连续签到',
                    '$consecutiveDays',
                    '天',
                    Icons.calendar_today,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        Space.h4,
        RichText(
          text: TextSpan(
            style: AppTypography.titleMediumStyle(isDark: false),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: unit,
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

  Widget _buildRecentInteractionsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final intimacyState = ref.watch(intimacyProvider);
        final recentInteractions = intimacyState.recentInteractions.take(5).toList();
        
        if (recentInteractions.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近互动',
              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h16,
            
            ...recentInteractions.map((record) => _buildInteractionRecord(record)),
          ],
        );
      },
    );
  }

  Widget _buildInteractionRecord(InteractionRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MinimalCard(
        child: Row(
          children: [
            // 互动类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  record.getEmoji(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            
            Space.w12,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.getDisplayText(),
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Space.h2,
                  Text(
                    _formatTimestamp(record.timestamp),
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // 积分
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                '+${record.pointsEarned}',
                style: AppTypography.captionStyle(isDark: false).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  Future<void> _onRefresh() async {
    // 模拟刷新延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 这里可以重新加载数据
    HapticFeedback.lightImpact();
  }

  void _handleInteraction(InteractionType type, IntimacyNotifier notifier) async {
    HapticFeedback.lightImpact();
    
    // 显示交互反馈
    _showInteractionFeedback(type);
    
    // 记录互动
    final success = await notifier.recordInteraction(
      type,
      metadata: {'timestamp': DateTime.now().toIso8601String()},
    );
    
    if (!success) {
      _showMessage('今日该互动已达上限');
    }
  }

  void _showInteractionFeedback(InteractionType type) {
    final behavior = InteractionBehavior.getBehavior(type);
    if (behavior == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(behavior.emoji, style: const TextStyle(fontSize: 16)),
            Space.w8,
            Text('${behavior.title} +${behavior.basePoints}积分'),
          ],
        ),
        backgroundColor: behavior.iconColor.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showLevelDetail(IntimacyLevel level) {
    HapticFeedback.lightImpact();
    
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
              // 等级图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [level.themeColor, level.themeColor.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    level.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              
              Space.h16,
              
              Text(
                level.title,
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              Space.h8,
              
              Text(
                level.description,
                style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              Space.h16,
              
              // 解锁功能
              Text(
                '解锁功能',
                style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              Space.h8,
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: level.unlockFeatures.map((feature) => 
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: level.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Text(
                      feature,
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: level.themeColor,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              
              Space.h24,
              
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