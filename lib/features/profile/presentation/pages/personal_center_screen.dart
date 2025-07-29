import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// 个人中心页面 - 模块化设计
/// 六个功能模块：我的菜谱、我的收藏、学习历程、成就系统、设置中心、数据分析
class PersonalCenterScreen extends ConsumerStatefulWidget {
  const PersonalCenterScreen({super.key});

  @override
  ConsumerState<PersonalCenterScreen> createState() => _PersonalCenterScreenState();
}

class _PersonalCenterScreenState extends ConsumerState<PersonalCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // 顶部用户信息区域
                _buildUserHeader(isDark),

                const SizedBox(height: AppSpacing.xl),

                // 六个功能模块网格
                Expanded(
                  child: _buildModuleGrid(isDark),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 用户头像和基本信息
  Widget _buildUserHeader(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: BreathingWidget(
        child: Row(
          children: [
            // 返回按钮
            GestureDetector(
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

            const Spacer(),

            // 页面标题
            Text(
              '我的',
              style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                fontWeight: AppTypography.light,
              ),
            ),

            const Spacer(),

            // 用户头像
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '❤️',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 六个功能模块网格布局
  Widget _buildModuleGrid(bool isDark) {
    final modules = [
      _ModuleItem(
        icon: '📋',
        title: '我的菜谱',
        description: '查看已创建的菜谱',
        color: const Color(0xFF5B6FED),
        onTap: () => context.push('/personal-center/my-recipes'),
      ),
      _ModuleItem(
        icon: '❤️',
        title: '我的收藏',
        description: '收藏的美食菜谱',
        color: const Color(0xFFFF6B6B),
        onTap: () => context.push('/personal-center/favorites'),
      ),
      _ModuleItem(
        icon: '📈',
        title: '学习历程',
        description: '厨艺成长轨迹',
        color: const Color(0xFF4ECDC4),
        onTap: () => context.push('/personal-center/learning-progress'),
      ),
      _ModuleItem(
        icon: '🏆',
        title: '成就系统',
        description: '解锁厨房成就',
        color: const Color(0xFFFFE66D),
        onTap: () => context.push('/personal-center/achievements'),
      ),
      _ModuleItem(
        icon: '⚙️',
        title: '设置中心',
        description: '个性化设置',
        color: const Color(0xFF95A5A6),
        onTap: () => context.push('/settings'),
      ),
      _ModuleItem(
        icon: '📊',
        title: '数据分析',
        description: '烹饪数据洞察',
        color: const Color(0xFF9B59B6),
        onTap: () => context.push('/personal-center/analytics'),
      ),
    ];

    return Padding(
      padding: AppSpacing.pagePadding,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          return _buildModuleCard(modules[index], isDark, index);
        },
      ),
    );
  }

  /// 单个模块卡片
  Widget _buildModuleCard(_ModuleItem module, bool isDark, int index) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          module.onTap();
        },
        child: MinimalCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 模块图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: module.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    module.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 模块标题
              Text(
                module.title,
                style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                  color: AppColors.getTextPrimaryColor(isDark),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.xs),

              // 模块描述
              Text(
                module.description,
                style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondaryColor(isDark),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 模块数据类
class _ModuleItem {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModuleItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}