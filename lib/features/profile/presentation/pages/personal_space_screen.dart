import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';

/// 🎨 个人空间页面 - 极简设计
/// 展示用户信息、数据统计、味道圈、成就等
class PersonalSpaceScreen extends ConsumerStatefulWidget {
  const PersonalSpaceScreen({super.key});

  @override
  ConsumerState<PersonalSpaceScreen> createState() => _PersonalSpaceScreenState();
}

class _PersonalSpaceScreenState extends ConsumerState<PersonalSpaceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // 淡入动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    // 滑入动画
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 启动动画
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 顶部导航栏
                SliverToBoxAdapter(
                  child: _buildHeader(context, isDark),
                ),

                // 用户信息区域
                SliverToBoxAdapter(
                  child: _buildUserInfo(user, isDark),
                ),

                // 数据统计
                SliverToBoxAdapter(
                  child: _buildDataStats(isDark),
                ),

                // 我的味道圈
                SliverToBoxAdapter(
                  child: _buildTasteCircles(isDark),
                ),

                // 最近成就
                SliverToBoxAdapter(
                  child: _buildRecentAchievements(isDark),
                ),

                // 底部留白
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextPrimaryColor(isDark),
                  size: 18,
                ),
              ),
            ),
          ),

          // 标题
          Text(
            '个人空间',
            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.light,
            ),
          ),

          // 设置按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(AppRouter.settings);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.getTextPrimaryColor(isDark),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfo(user, bool isDark) {
    final joinDate = DateTime.now().subtract(const Duration(days: 90)); // 示例数据
    final joinDateStr = '加入时间：${DateFormat('yyyy年MM月').format(joinDate)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // 用户头像
          BreathingWidget(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🍳',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 用户昵称
          Text(
            user?.displayName ?? '美食爱好者',
            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // 加入时间
          Text(
            joinDateStr,
            style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建数据统计
  Widget _buildDataStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 我的数据',
            style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('128', '做过的', isDark),
              _buildStatCard('45', '收藏的', isDark),
              _buildStatCard('89', '分享的', isDark),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建单个统计卡片
  Widget _buildStatCard(String value, String label, bool isDark) {
    return BreathingWidget(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundSecondaryColor(isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.medium,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.captionStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建味道圈列表
  Widget _buildTasteCircles(bool isDark) {
    // 示例数据
    final circles = [
      _TasteCircle(
        name: '我们的小厨房',
        type: CircleType.couple,
        memberCount: 2,
        icon: '💑',
      ),
      _TasteCircle(
        name: '温馨一家人',
        type: CircleType.family,
        memberCount: 5,
        icon: '👨‍👩‍👧',
      ),
      _TasteCircle(
        name: '吃货小分队',
        type: CircleType.friends,
        memberCount: 8,
        icon: '👫',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 我的味道圈',
            style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          ...circles.map((circle) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildCircleCard(circle, isDark),
          )),

          // 创建或加入按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(AppRouter.createOrJoinCircle);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: AppColors.getTextSecondaryColor(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '创建或加入味道圈',
                      style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建味道圈卡片
  Widget _buildCircleCard(_TasteCircle circle, bool isDark) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/taste-circles/${Uri.encodeComponent(circle.name)}');
        },
        child: MinimalCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // 图标
              Text(
                circle.icon,
                style: const TextStyle(fontSize: 32),
              ),

              const SizedBox(width: AppSpacing.lg),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circle.name,
                      style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${circle.memberCount}个成员 · ${circle.typeLabel}',
                      style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              // 箭头
              Icon(
                Icons.chevron_right,
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建最近成就
  Widget _buildRecentAchievements(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 最近成就',
            style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          MinimalCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildAchievementItem('🥘 川菜达人', '3天前解锁', isDark),
                const SizedBox(height: AppSpacing.md),
                _buildAchievementItem('🔥 连续打卡30天', '持续保持中', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建成就项
  Widget _buildAchievementItem(String title, String subtitle, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.captionStyle(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondaryColor(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 味道圈数据模型
class _TasteCircle {
  final String name;
  final CircleType type;
  final int memberCount;
  final String icon;

  _TasteCircle({
    required this.name,
    required this.type,
    required this.memberCount,
    required this.icon,
  });

  String get typeLabel {
    switch (type) {
      case CircleType.couple:
        return '情侣';
      case CircleType.family:
        return '家人';
      case CircleType.friends:
        return '朋友';
    }
  }
}

/// 圈子类型枚举
enum CircleType {
  couple,
  family,
  friends,
}