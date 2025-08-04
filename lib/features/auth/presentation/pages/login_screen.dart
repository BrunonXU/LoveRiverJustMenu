/// 🔐 登录页面
/// 
/// 用户认证登录界面，支持邮箱密码和Google登录
/// 采用极简设计风格，遵循95%黑白灰 + 5%彩色焦点的设计原则
/// 
/// 主要功能：
/// - 邮箱密码登录表单
/// - Google快速登录
/// - 实时表单验证
/// - 错误状态显示
/// - 忘记密码功能
/// - 跳转注册页面
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
import '../../../../core/auth/models/app_user.dart';
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/animated_background.dart';

/// 🔑 登录页面
/// 
/// 极简设计的登录界面，提供邮箱密码和Google登录选项
/// 包含完整的表单验证和用户反馈机制
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  /// 表单全局键
  final _formKey = GlobalKey<FormState>();
  
  /// 邮箱输入控制器
  final _emailController = TextEditingController();
  
  /// 密码输入控制器
  final _passwordController = TextEditingController();
  
  /// 邮箱输入焦点节点
  final _emailFocusNode = FocusNode();
  
  /// 密码输入焦点节点
  final _passwordFocusNode = FocusNode();
  
  /// 是否显示密码
  bool _obscurePassword = true;
  
  /// 是否正在处理登录
  bool _isProcessing = false;
  
  /// 错误消息
  String? _errorMessage;
  
  /// 是否可以登录（表单验证通过）
  bool get _canLogin => _emailController.text.trim().isNotEmpty && 
                       _passwordController.text.isNotEmpty &&
                       !_isProcessing;
  
  /// 主动画控制器
  late AnimationController _mainController;
  
  /// 淡入动画
  late Animation<double> _fadeAnimation;
  
  /// 上滑动画
  late Animation<Offset> _slideAnimation;

  /// 是否已经开始监听认证状态
  bool _hasStartedListening = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // 监听文本输入变化，更新按钮状态
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 安全地开始监听认证状态变化（只监听一次）
    if (!_hasStartedListening) {
      _hasStartedListening = true;
      _listenToAuthState();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 🎬 初始化动画
  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  /// ▶️ 开始动画
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _mainController.forward();
      }
    });
  }

  /// 🔄 更新按钮状态
  void _updateButtonState() {
    setState(() {
      // 触发重建以更新按钮状态
    });
  }

  /// 👂 监听认证状态变化
  void _listenToAuthState() {
    ref.listen<AsyncValue<AppUser?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          // 登录成功，跳转到主页
          context.go('/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authActions = ref.watch(authActionsProvider.notifier);
    final authState = ref.watch(authActionsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 动画背景
          const AnimatedBackground(),
          
          // 主要内容
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(authActions, authState),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🎨 构建页面内容
  Widget _buildContent(
    AuthActionsNotifier authActions,
    AuthActionState authState,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopNavigation(),
            
            const SizedBox(height: 32),
            
            // 页面标题
            _buildPageTitle(),
            
            const SizedBox(height: 48),
            
            // 登录表单
            Expanded(
              child: SingleChildScrollView(
                child: _buildLoginForm(authActions, authState),
              ),
            ),
            
            // 底部注册链接
            _buildBottomLinks(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 🔙 构建顶部导航栏
  Widget _buildTopNavigation() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
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
        
        // 游客体验
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

  /// 🏷️ 构建页面标题
  Widget _buildPageTitle() {
    return Column(
      children: [
        // 爱心图标
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B6FED).withOpacity(0.25),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '💕',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        
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

  /// 📝 构建登录表单
  Widget _buildLoginForm(
    AuthActionsNotifier authActions,
    AuthActionState authState,
  ) {
    return Column(
      children: [
        // 错误消息显示
        if (_errorMessage != null) _buildErrorMessage(),
        
        // 开始美食之旅标题
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            '开始你们的美食之旅',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        
        // 登录按钮（主要）
        GradientButton(
          text: '登录',
          onPressed: () => _showEmailLoginDialog(),
        ),
        
        const SizedBox(height: 16),
        
        // 注册按钮（次要）
        GestureDetector(
          onTap: () => _handleRegisterTap(),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '注册',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 64),
        
        // 选择注册方式标题
        const Text(
          '选择注册方式',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 手机号注册
        _buildMethodButton(
          icon: Icons.phone_outlined,
          text: '手机号注册',
          onTap: () => _handlePhoneSignUp(),
        ),
        
        const SizedBox(height: 16),
        
        // 邮箱注册
        _buildMethodButton(
          icon: Icons.email_outlined,
          text: '邮箱注册',
          onTap: () => _handleRegisterTap(),
        ),
        
        const SizedBox(height: 16),
        
        // 微信快速注册
        _buildMethodButton(
          icon: Icons.wechat,
          text: '微信快速注册',
          onTap: () => _handleWechatSignUp(),
        ),
      ],
    );
  }

  /// ❌ 构建错误消息显示
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


  /// 📝 构建底部链接
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
          onTap: () => _showEmailLoginDialog(),
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

  // ==================== 表单验证方法 ====================

  /// ✅ 邮箱格式验证
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入邮箱地址';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '请输入正确的邮箱格式';
    }
    
    return null;
  }

  /// ✅ 密码格式验证
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    
    return null;
  }

  // ==================== 事件处理方法 ====================

  /// 🔑 处理邮箱密码登录
  Future<void> _handleEmailLogin() async {
    // 收起键盘
    FocusScope.of(context).unfocus();
    
    // 验证表单
    if (!_formKey.currentState!.validate()) {
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
      
      if (!success && mounted) {
        // 获取错误信息
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

  /// 🌐 处理Google登录
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.signInWithGoogle();
      
      if (!success && mounted) {
        final error = authActions.lastError;
        setState(() {
          _errorMessage = error?.message ?? 'Google登录失败，请重试';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google登录过程中发生错误，请重试';
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

  /// 🔄 处理忘记密码
  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      // 提示用户输入邮箱
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先输入邮箱地址'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _emailFocusNode.requestFocus();
      return;
    }
    
    // 显示重置密码对话框
    _showResetPasswordDialog(email);
  }

  /// 📧 显示重置密码对话框
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

  /// 📤 发送重置密码邮件
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

  /// 📝 处理注册页面跳转
  void _handleRegisterTap() {
    debugPrint('👆 用户点击：立即注册');
    context.push('/auth/register');
  }
  
  /// 📧 显示邮箱登录对话框
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
              // 标题
              const Text(
                '邮箱登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 邮箱输入框
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
              
              // 密码输入框
              CustomTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                hintText: '请输入密码',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF999999),
                ),
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF999999),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleEmailLoginFromDialog(),
              ),
              
              const SizedBox(height: 16),
              
              // 忘记密码链接
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
              
              // 登录按钮
              GradientButton(
                text: _isProcessing ? '登录中...' : '登录',
                onPressed: _canLogin ? () => _handleEmailLoginFromDialog() : () {},
                isLoading: _isProcessing,
                isEnabled: _canLogin,
              ),
              
              const SizedBox(height: 16),
              
              // 取消按钮
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
  
  /// 🔑 从对话框处理邮箱密码登录
  Future<void> _handleEmailLoginFromDialog() async {
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
    
    await _handleEmailLogin();
    
    // 登录成功后关闭对话框
    if (mounted && _errorMessage == null) {
      Navigator.of(context).pop();
    }
  }
  
  /// 📱 处理手机号注册
  void _handlePhoneSignUp() {
    debugPrint('👆 用户点击：手机号注册');
    // TODO: 实现手机号注册逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('手机号注册功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
      ),
    );
  }
  
  /// 💬 处理微信注册
  void _handleWechatSignUp() {
    debugPrint('👆 用户点击：微信快速注册');
    // TODO: 实现微信注册逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('微信注册功能即将上线'),
        backgroundColor: Color(0xFF5B6FED),
      ),
    );
  }
  
  /// 🔧 构建方法选择按钮
  Widget _buildMethodButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              icon,
              color: const Color(0xFF666666),
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF999999),
              size: 16,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  /// 👁️ 处理游客模式
  void _handleGuestMode() {
    debugPrint('👆 用户点击：游客体验');
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
}