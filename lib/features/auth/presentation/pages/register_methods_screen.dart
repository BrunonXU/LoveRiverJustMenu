/// 📝 注册方式选择页面
/// 
/// 完全按照参考图片设计的注册方式选择界面
/// 支持手机号、邮箱、微信、Google四种注册方式
/// 移植3.dart的精美UI组件和动画效果
/// 
/// 作者: Claude Code
/// 创建时间: 2025-01-31

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/breathing_logo.dart';
import '../../../../shared/widgets/method_button.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import 'login_methods_screen.dart';
import 'guest_screen.dart';

class RegisterMethodsScreen extends ConsumerStatefulWidget {
  const RegisterMethodsScreen({super.key});

  @override
  ConsumerState<RegisterMethodsScreen> createState() => _RegisterMethodsScreenState();
}

class _RegisterMethodsScreenState extends ConsumerState<RegisterMethodsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // 邮箱注册表单控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
        
        const SizedBox(height: 32),
        
        // Logo和标题区域
        _buildHeaderSection(),
        
        const SizedBox(height: 48),
        
        // 注册方式选择
        Expanded(
          child: SingleChildScrollView(
            child: _buildMethodsSection(),
          ),
        ),
        
        // 底部链接
        _buildBottomLinks(),
        
        const SizedBox(height: 16),
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
          '选择注册方式',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        
        const Spacer(),
        
        GestureDetector(
          onTap: () => _handleGuestMode(),
          child: const Text(
            '游客体验',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const BreathingLogo(size: 80),
        const SizedBox(height: 24),
        
        const Text(
          '爱心食谱',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        const Text(
          '为爱下厨，记录美食与情感',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMethodsSection() {
    return Column(
      children: [
        // 手机号注册
        MethodButton(
          icon: Icons.phone,
          text: '手机号注册',
          onPressed: () => _handlePhoneRegister(),
        ),
        const SizedBox(height: 16),
        
        // 邮箱注册
        MethodButton(
          icon: Icons.email,
          text: '邮箱注册',
          onPressed: () => _showEmailRegisterDialog(),
        ),
        const SizedBox(height: 16),
        
        // 微信快速注册
        MethodButton(
          icon: Icons.wechat,
          text: '微信快速注册',
          onPressed: () => _handleWechatRegister(),
        ),
        const SizedBox(height: 16),
        
        // Google注册
        MethodButton(
          icon: Icons.g_mobiledata,
          text: 'Google注册',
          onPressed: () => _handleGoogleRegister(),
        ),
      ],
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '已有账号？',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _handleLoginTap(),
          child: const Text(
            '立即登录',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5B6FED),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 事件处理方法 ====================

  void _handlePhoneRegister() {
    debugPrint('👆 用户点击：手机号注册');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('手机号注册功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmailRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '邮箱注册',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 32),
              
              if (_errorMessage != null) _buildErrorMessage(),
              
              CustomTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                hintText: '请输入邮箱地址',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF999999),
                ),
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                hintText: '请输入密码（至少6位）',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF999999),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF999999),
                  ),
                ),
                onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
              ),
              
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                hintText: '请确认密码',
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF999999),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  child: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF999999),
                  ),
                ),
                onSubmitted: (_) => _handleEmailRegister(),
              ),
              
              const SizedBox(height: 32),
              
              GradientButton(
                text: _isProcessing ? '注册中...' : '注册',
                onPressed: () => _handleEmailRegister(),
                isLoading: _isProcessing,
                isEnabled: !_isProcessing,
              ),
              
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '注册即表示同意用户协议和隐私政策',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailRegister() async {
    // 验证输入
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入邮箱地址';
      });
      return;
    }
    
    // 验证邮箱格式
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() {
        _errorMessage = '请输入正确的邮箱格式';
      });
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入密码';
      });
      return;
    }
    
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = '密码至少需要6个字符';
      });
      return;
    }
    
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
      });
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop(); // 关闭对话框
        
        // 🎉 显示注册成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！已自动登录'),
            backgroundColor: Color(0xFF5B6FED),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 🔄 注册成功后自动登录，直接跳转到主页
        context.go('/home');
      } else if (mounted) {
        final error = authActions.lastError;
        setState(() {
          _errorMessage = error?.message ?? '注册失败，请重试';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '注册过程中发生错误，请重试';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handleWechatRegister() {
    debugPrint('👆 用户点击：微信快速注册');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('微信注册功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleGoogleRegister() async {
    debugPrint('👆 用户点击：Google注册');
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.signInWithGoogle(); // Google登录同时也是注册
      
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        final error = authActions.lastError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error?.message ?? 'Google注册失败，请重试'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google注册过程中发生错误，请重试'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleLoginTap() {
    debugPrint('👆 用户点击：立即登录');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const LoginMethodsScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _handleGuestMode() {
    debugPrint('👆 用户点击：游客体验');
    
    // 🎯 直接跳转到主页（游客模式）
    context.go('/home');
    
    // 显示游客模式提示
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎮 正在以游客身份体验，数据不会云端同步'),
            backgroundColor: Color(0xFF5B6FED),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }
}