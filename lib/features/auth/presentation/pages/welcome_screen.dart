/// 👋 欢迎页面
/// 
/// 应用的首次启动页面，提供登录、注册和游客模式选项
/// 采用极简设计风格，遵循95%黑白灰 + 5%彩色焦点的设计原则
/// 
/// 主要功能：
/// - 应用介绍和品牌展示
/// - 登录/注册入口
/// - 游客模式体验
/// - 流畅的过渡动画
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';

/// 🎨 欢迎页面
/// 
/// 极简设计的欢迎界面，展示应用品牌和提供认证选项
/// 使用时间驱动的背景渐变和呼吸动画效果
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  /// 主动画控制器
  late AnimationController _mainController;
  
  /// 淡入动画
  late Animation<double> _fadeAnimation;
  
  /// 上滑动画
  late Animation<Offset> _slideAnimation;
  
  /// 缩放动画
  late Animation<double> _scaleAnimation;
  
  /// 按钮动画控制器
  late AnimationController _buttonController;
  
  /// 按钮弹性动画
  late Animation<double> _buttonBounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  /// 🎬 初始化动画
  void _initializeAnimations() {
    // 主动画控制器 - 2秒完成
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 淡入动画 - 前1秒
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // 上滑动画 - 1-2秒
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    // 缩放动画 - 1.5-2秒
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    // 按钮动画控制器 - 无限循环的呼吸效果
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _buttonBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  /// ▶️ 开始动画
  void _startAnimations() {
    // 延迟500ms后开始主动画
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _mainController.forward();
      }
    });

    // 2.5秒后开始按钮呼吸动画
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _buttonController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.getTimeBasedGradient(),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildContent(isDark),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🎨 构建页面内容
  Widget _buildContent(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 顶部留白
          const SizedBox(height: AppSpacing.xxl * 2),

          // 应用品牌区域
          _buildBrandSection(isDark),

          // 中间弹性空间
          const Spacer(),

          // 认证选项区域
          _buildAuthOptionsSection(isDark),

          // 底部留白
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// 🏷️ 构建品牌展示区域
  Widget _buildBrandSection(bool isDark) {
    return Column(
      children: [
        // 应用图标 - 呼吸动画
        BreathingWidget(
          duration: const Duration(seconds: 4),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // 应用名称
        BreathingWidget(
          duration: const Duration(seconds: 5),
          child: Text(
            '爱心食谱',
            style: AppTypography.displayLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.ultralight,
              letterSpacing: 2.0,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 应用标语
        Text(
          '为爱下厨，记录美食与情感',
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            fontWeight: AppTypography.light,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.sm),

        // 特色说明
        Text(
          '极简设计 · 情侣共享 · 云端同步',
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.8),
            fontWeight: AppTypography.light,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🔐 构建认证选项区域
  Widget _buildAuthOptionsSection(bool isDark) {
    return Column(
      children: [
        // 主要操作按钮 - 登录
        AnimatedBuilder(
          animation: _buttonBounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonBounceAnimation.value,
              child: _buildPrimaryButton(
                text: '开始使用',
                icon: Icons.arrow_forward,
                onTap: () => _handleLoginTap(),
                isDark: isDark,
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // 次要操作按钮组
        Row(
          children: [
            // 注册账号
            Expanded(
              child: _buildSecondaryButton(
                text: '注册账号',
                icon: Icons.person_add,
                onTap: () => _handleRegisterTap(),
                isDark: isDark,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // 游客体验
            Expanded(
              child: _buildSecondaryButton(
                text: '游客体验',
                icon: Icons.visibility,
                onTap: () => _handleGuestTap(),
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // 底部说明文本
        _buildFooterText(isDark),
      ],
    );
  }

  /// 🎯 构建主要按钮
  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: double.infinity,
          height: 56,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 构建次要按钮
  Widget _buildSecondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.getTextPrimaryColor(isDark),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                text,
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📝 构建底部说明文本
  Widget _buildFooterText(bool isDark) {
    return Column(
      children: [
        Text(
          '使用即表示同意',
          style: AppTypography.captionStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _handlePrivacyPolicyTap(),
              child: Text(
                '隐私政策',
                style: AppTypography.captionStyle(isDark: isDark).copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' 和 ',
              style: AppTypography.captionStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.7),
              ),
            ),
            GestureDetector(
              onTap: () => _handleTermsOfServiceTap(),
              child: Text(
                '服务条款',
                style: AppTypography.captionStyle(isDark: isDark).copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== 事件处理方法 ====================

  /// 🔑 处理登录按钮点击
  void _handleLoginTap() {
    debugPrint('👆 用户点击：开始使用（登录）');
    context.push('/auth/login');
  }

  /// 📝 处理注册按钮点击
  void _handleRegisterTap() {
    debugPrint('👆 用户点击：注册账号');
    context.push('/auth/register');
  }

  /// 👁️ 处理游客体验按钮点击
  void _handleGuestTap() {
    debugPrint('👆 用户点击：游客体验');
    // 直接进入主页面，使用游客模式
    context.go('/home');
    
    // 显示游客模式提示
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('正在以游客身份体验，数据不会云端同步'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '立即注册',
              textColor: Colors.white,
              onPressed: () {
                context.push('/auth/register');
              },
            ),
          ),
        );
      }
    });
  }

  /// 📋 处理隐私政策点击
  void _handlePrivacyPolicyTap() {
    debugPrint('👆 用户点击：隐私政策');
    // TODO: 跳转到隐私政策页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('隐私政策页面开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 📋 处理服务条款点击
  void _handleTermsOfServiceTap() {
    debugPrint('👆 用户点击：服务条款');
    // TODO: 跳转到服务条款页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('服务条款页面开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}