/// 👋 欢迎页面
/// 
/// 应用的首次启动页面，提供登录、注册和游客模式选项
/// 采用极简设计风格，遵循95%黑白灰 + 5%彩色焦点的设计原则
/// 完全按照参考图片设计，移植3.dart的精美UI组件
/// 
/// 主要功能：
/// - 应用介绍和品牌展示
/// - 登录/注册入口
/// - 游客模式体验
/// - 流畅的过渡动画
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-30
/// 更新时间: 2025-01-31 - 迁移3.dart设计

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/pixel_logo.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/pixel_button.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/themes/auth_theme.dart';
import 'login_methods_screen.dart';
import 'register_methods_screen.dart';
import 'guest_screen.dart';

/// 🎨 欢迎页面
/// 
/// 极简设计的欢迎界面，完全按照参考图片设计
/// 使用3.dart的精美UI组件和动画效果
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  /// 主动画控制器
  late AnimationController _fadeController;
  
  /// 淡入动画
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// 🎬 初始化动画
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
  }

  /// ▶️ 开始动画
  void _startAnimations() {
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 强制占满全屏
        width: double.infinity,
        height: double.infinity,
        // 使用统一的像素风背景装饰
        decoration: AuthStyles.pageBackground,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              // 使用响应式页面边距
              padding: AuthLayout.getResponsivePagePadding(context),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 构建页面内容
  Widget _buildContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        // 使用响应式最小高度计算，但不能太小
        minHeight: AuthLayout.getContentMinHeight(context),
        // 确保有最小宽度，但允许响应式
        minWidth: 300, // 最小300px确保内容可读
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // 内容居中对齐
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: AuthLayout.spacing_lg),
          
          // Logo区域 - 响应式像素风
          PixelLogo(
            size: AuthLayout.getResponsiveLogoSize(context),
          ),
          SizedBox(height: AuthLayout.spacing_md),
          
          Text(
            'LRJ',
            style: AuthTypography.logoLarge,
          ),
          SizedBox(height: AuthLayout.spacing_xs),
          
          Text(
            'LOVE-RECIPE JOURNAL',
            style: AuthTypography.logoSubtitle,
          ),
          SizedBox(height: AuthLayout.spacing_xs),
          
          Text(
            '为爱下厨，记录美食与情感',
            style: AuthTypography.description,
          ),
          
          SizedBox(height: AuthLayout.spacing_xl),
          
          Text(
            '开始你们的美食之旅',
            style: AuthTypography.pageTitle,
          ),
          SizedBox(height: AuthLayout.spacing_lg),
          
          // 响应式像素风按钮区域
          Column(
            children: [
              PixelButton(
                text: '登录',
                onPressed: () => _navigateToLogin(context),
                isPrimary: true,
                width: AuthLayout.getResponsiveButtonWidth(context),  // 直接传递宽度给按钮
                height: AuthLayout.buttonHeight,
              ),
              SizedBox(height: AuthLayout.spacing_sm),
              
              PixelButton(
                text: '注册',
                onPressed: () => _navigateToRegister(context),
                isPrimary: false,
                width: AuthLayout.getResponsiveButtonWidth(context),  // 直接传递宽度给按钮
                height: AuthLayout.buttonHeight,
              ),
            ],
          ),
          
          SizedBox(height: AuthLayout.spacing_lg),
          
          // 游客体验
          Container(
            padding: EdgeInsets.symmetric(vertical: AuthLayout.spacing_md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AuthColors.pixelDivider),
              ),
            ),
            child: GestureDetector(
              onTap: () => _navigateToGuest(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AuthLayout.spacing_md,
                  vertical: 12,
                ),
                decoration: AuthStyles.guestButton,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👁', style: TextStyle(fontSize: 16)),
                    SizedBox(width: AuthLayout.spacing_xs),
                    Text(
                      '游客体验',
                      style: AuthTypography.buttonTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: AuthLayout.spacing_sm),
          
          // 版权信息
          Text(
            '使用即表示同意 用户协议 和 隐私政策',
            style: AuthTypography.copyright,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AuthLayout.spacing_md),
        ],
      ),
    );
  }


  // ==================== 事件处理方法 ====================

  void _navigateToLogin(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const LoginMethodsScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const RegisterMethodsScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToGuest(BuildContext context) {
    HapticFeedback.lightImpact();
    // 跳转到游客体验说明页面，让用户了解游客模式功能和限制
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const GuestScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );
  }
}