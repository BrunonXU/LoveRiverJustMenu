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
        // 像素风优雅背景 - 奶茶色系
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAF7F0), // 温暖白色
              Color(0xFFF0EBE3), // 奶茶色
              Color(0xFFE6D7C3), // 浅咖啡色
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 构建页面内容
  Widget _buildContent() {
    return Column(
      children: [
        const Spacer(flex: 2),
        
        // Logo区域 - 像素风
        const PixelLogo(
          size: 160,
        ),
        const SizedBox(height: 24),
        
        Text(
          'LRJ',
          style: GoogleFonts.pressStart2p(
            fontSize: 28,
            color: const Color(0xFF2D4A3E),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          'LOVE-RECIPE JOURNAL',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: const Color(0xFF4A6B3A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          '为爱下厨，记录美食与情感',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: const Color(0xFF6B4423),
            letterSpacing: 1.0,
            height: 1.5,
          ),
        ),
        
        const Spacer(flex: 3),
        
        Text(
          '开始你们的美食之旅',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: const Color(0xFF2D4A3E),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 48),
        
        // 像素风按钮区域
        Column(
          children: [
            SizedBox(
              width: 200,
              child: PixelButton(
                text: '登录',
                onPressed: () => _navigateToLogin(context),
                isPrimary: true,
                height: 44,
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: 200,
              child: PixelButton(
                text: '注册',
                onPressed: () => _navigateToRegister(context),
                isPrimary: false,
                height: 44,
              ),
            ),
          ],
        ),
        
        const Spacer(flex: 2),
        
        // 游客体验
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFF7F7F7)),
            ),
          ),
          child: GestureDetector(
            onTap: () => _navigateToGuest(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF6B4423),
                  width: 1,
                ),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👁', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '游客体验',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: const Color(0xFF6B4423),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // 版权信息
        Text(
          '使用即表示同意 用户协议 和 隐私政策',
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: const Color(0xFF9B8B7A),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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