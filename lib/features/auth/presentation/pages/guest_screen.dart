/// 👁️ 游客体验页面
/// 
/// 完全按照参考图片设计的游客体验介绍界面
/// 展示游客模式的功能特色和限制说明
/// 移植3.dart的精美UI组件和动画效果
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-31

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/breathing_logo.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/animated_background.dart';
import 'register_methods_screen.dart';

class GuestScreen extends ConsumerStatefulWidget {
  const GuestScreen({super.key});

  @override
  ConsumerState<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends ConsumerState<GuestScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
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

  void _startAnimations() {
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // 顶部导航栏
        _buildTopNavigation(),
        
        // 主要内容区域
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // 游客体验Logo和标题
                _buildHeaderSection(),
                
                const SizedBox(height: 48),
                
                // 功能介绍区域
                _buildFeaturesSection(),
                
                const SizedBox(height: 32),
                
                // 限制说明区域
                _buildLimitationsSection(),
                
                const SizedBox(height: 48),
                
                // 开始体验按钮
                _buildActionSection(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigation() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
          ),
        ),
        
        const Spacer(),
        
        const Text(
          '游客体验',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        
        const Spacer(),
        
        const SizedBox(width: 40), // 占位保持居中
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // 使用橙色渐变的眼睛Logo
        BreathingLogo(
          size: 120,
          emoji: '👁️',
          gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        ),
        const SizedBox(height: 24),
        
        const Text(
          '免注册体验',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        const Text(
          '无需注册即可体验核心功能\n开始探索美食的世界吧',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF666666),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🎨', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '游客模式可以体验：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildFeatureItem('✅', '浏览精选菜谱'),
          const SizedBox(height: 12),
          _buildFeatureItem('✅', 'AI智能推荐'),
          const SizedBox(height: 12),
          _buildFeatureItem('✅', '烹饪模式体验'),
          const SizedBox(height: 12),
          _buildFeatureItem('✅', '手势操作学习'),
        ],
      ),
    );
  }

  Widget _buildLimitationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFE66D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '游客模式限制：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildLimitationItem('❌', '无法保存个人数据'),
          const SizedBox(height: 12),
          _buildLimitationItem('❌', '无法创建菜谱'),
          const SizedBox(height: 12),
          _buildLimitationItem('❌', '无法同步多设备'),
          const SizedBox(height: 12),
          _buildLimitationItem('❌', '无法使用协同功能'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitationItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        // 开始游客体验按钮
        GradientButton(
          text: '开始游客体验',
          onPressed: () => _handleStartGuestMode(),
          isPrimary: true,
        ),
        
        const SizedBox(height: 16),
        
        // 底部提示
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '随时可以 ',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            GestureDetector(
              onTap: () => _handleRegisterTap(),
              child: const Text(
                '注册账号',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5B6FED),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' 解锁完整功能',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== 事件处理方法 ====================

  void _handleStartGuestMode() {
    debugPrint('👆 用户点击：开始游客体验');
    HapticFeedback.lightImpact();
    
    // 跳转到主页面
    context.go('/home');
    
    // 显示游客模式提示
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('正在以游客身份体验，数据不会云端同步'),
            backgroundColor: const Color(0xFF5B6FED),
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

  void _handleRegisterTap() {
    debugPrint('👆 用户点击：注册账号');
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
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
}