/// 🔐 登录方式选择页面
/// 
/// 完全按照参考图片设计的登录方式选择界面
/// 支持手机号、邮箱、微信、Google四种登录方式
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
import 'register_methods_screen.dart';
import 'guest_screen.dart';

class LoginMethodsScreen extends ConsumerStatefulWidget {
  const LoginMethodsScreen({super.key});

  @override
  ConsumerState<LoginMethodsScreen> createState() => _LoginMethodsScreenState();
}

class _LoginMethodsScreenState extends ConsumerState<LoginMethodsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // 邮箱登录表单控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isProcessing = false;
  String? _errorMessage;
  
  // 管理员登录相关状态
  bool _adminIsProcessing = false;
  String? _adminErrorMessage;

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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
          // 管理员模式入口
          _buildAdminEntry(),
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
        
        // 登录方式选择
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
          '选择登录方式',
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
        // 手机号登录
        MethodButton(
          icon: Icons.phone,
          text: '手机号登录',
          onPressed: () => _handlePhoneLogin(),
        ),
        const SizedBox(height: 16),
        
        // 邮箱登录
        MethodButton(
          icon: Icons.email,
          text: '邮箱登录',
          onPressed: () => _showEmailLoginDialog(),
        ),
        const SizedBox(height: 16),
        
        // 微信登录
        MethodButton(
          icon: Icons.wechat,
          text: '微信登录',
          onPressed: () => _handleWechatLogin(),
        ),
        const SizedBox(height: 16),
        
        // Google登录
        MethodButton(
          icon: Icons.g_mobiledata,
          text: 'Google登录',
          onPressed: () => _handleGoogleLogin(),
        ),
      ],
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '没有账号？',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _handleRegisterTap(),
          child: const Text(
            '立即注册',
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

  void _handlePhoneLogin() {
    debugPrint('👆 用户点击：手机号登录');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('手机号登录功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmailLoginDialog() {
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
                '邮箱登录',
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
                hintText: '请输入密码',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF999999),
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF999999),
                      size: 20,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleEmailLogin(),
              ),
              
              const SizedBox(height: 16),
              
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _handleForgotPassword(),
                  child: const Text(
                    '忘记密码？',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B6FED),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              GradientButton(
                text: _isProcessing ? '登录中...' : '登录',
                onPressed: () => _handleEmailLogin(),
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
        crossAxisAlignment: CrossAxisAlignment.start,  // 🔧 修复: 添加crossAxisAlignment
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

  Future<void> _handleEmailLogin() async {
    // 验证输入
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入邮箱地址';
      });
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '请输入密码';
      });
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pop(); // 关闭对话框
        context.go('/home'); // 跳转到主页
      } else if (mounted) {
        final error = authActions.lastError;
        setState(() {
          _errorMessage = error?.message ?? '登录失败，请重试';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '登录过程中发生错误，请重试';
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

  void _handleWechatLogin() {
    debugPrint('👆 用户点击：微信登录');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('微信登录功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    debugPrint('👆 用户点击：Google登录');
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.signInWithGoogle();
      
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        final error = authActions.lastError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error?.message ?? 'Google登录失败，请重试'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google登录过程中发生错误，请重试'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先输入邮箱地址'),
          backgroundColor: Color(0xFF5B6FED),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _emailFocusNode.requestFocus();
      return;
    }
    
    _showResetPasswordDialog(email);
  }

  void _showResetPasswordDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置密码'),
        content: Text('确定要向 $email 发送密码重置邮件吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _sendResetPasswordEmail(email);
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetPasswordEmail(String email) async {
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.resetPassword(email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? '重置密码邮件已发送，请检查您的邮箱'
                  : '发送失败，请检查邮箱地址后重试',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('发送重置邮件时发生错误'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleRegisterTap() {
    debugPrint('👆 用户点击：立即注册');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const RegisterMethodsScreen(),
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

  // ==================== 管理员模式相关方法 ====================

  /// 构建管理员模式入口
  Widget _buildAdminEntry() {
    return Positioned(
      bottom: 32,
      right: 32,
      child: GestureDetector(
        onTap: () => _showAdminLoginDialog(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: Color(0xFF666666),
            size: 20,
          ),
        ),
      ),
    );
  }

  /// 显示管理员登录对话框
  void _showAdminLoginDialog() {
    // 预填入管理员账号密码
    final adminEmailController = TextEditingController(text: '2352016835@qq.com');
    final adminPasswordController = TextEditingController(text: '24212691147Xza');
    bool adminObscurePassword = true;
    
    // 重置状态
    _adminIsProcessing = false;
    _adminErrorMessage = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 管理员标题
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF5B6FED),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '管理员登录',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                if (_adminErrorMessage != null) _buildAdminErrorMessage(_adminErrorMessage!),
                
                // 管理员邮箱输入
                CustomTextField(
                  controller: adminEmailController,
                  hintText: '管理员邮箱',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF999999),
                  ),
                  enabled: false, // 禁用编辑，固定管理员邮箱
                ),
                
                const SizedBox(height: 24),
                
                // 管理员密码输入
                CustomTextField(
                  controller: adminPasswordController,
                  hintText: '管理员密码',
                  obscureText: adminObscurePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF999999),
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setDialogState(() {
                        adminObscurePassword = !adminObscurePassword;
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Icon(
                        adminObscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF999999),
                        size: 20,
                      ),
                    ),
                  ),
                  enabled: false, // 禁用编辑，固定管理员密码
                ),
                
                const SizedBox(height: 32),
                
                // 管理员登录按钮
                GradientButton(
                  text: _adminIsProcessing ? '登录中...' : '管理员登录',
                  onPressed: () => _handleAdminLogin(
                    adminEmailController.text,
                    adminPasswordController.text,
                    setDialogState,
                  ),
                  isLoading: _adminIsProcessing,
                  isEnabled: !_adminIsProcessing,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建管理员错误消息
  Widget _buildAdminErrorMessage(String message) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
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

  /// 处理管理员登录
  Future<void> _handleAdminLogin(
    String email,
    String password,
    StateSetter setDialogState,
  ) async {
    setDialogState(() {
      _adminIsProcessing = true;
      _adminErrorMessage = null;
    });
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.signInWithEmailPassword(email, password);
      
      if (success && mounted) {
        Navigator.of(context).pop(); // 关闭对话框
        context.go('/home'); // 跳转到主页
        
        // 显示管理员登录成功提示
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔐 管理员登录成功'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      } else if (mounted) {
        final error = authActions.lastError;
        setDialogState(() {
          _adminErrorMessage = error?.message ?? '管理员登录失败，请重试';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setDialogState(() {
          _adminErrorMessage = '管理员登录过程中发生错误，请重试';
        });
      }
    } finally {
      if (mounted) {
        setDialogState(() {
          _adminIsProcessing = false;
        });
      }
    }
  }
}