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
import '../../../../core/auth/providers/auth_providers.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';

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
  
  /// 主动画控制器
  late AnimationController _mainController;
  
  /// 淡入动画
  late Animation<double> _fadeAnimation;
  
  /// 上滑动画
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // 监听认证状态变化
    _listenToAuthState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authActions = ref.watch(authActionsProvider.notifier);
    final authState = ref.watch(authActionsProvider);

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
                  child: _buildContent(isDark, authActions, authState),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🎨 构建页面内容
  Widget _buildContent(
    bool isDark,
    AuthActionsNotifier authActions,
    AuthActionState authState,
  ) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          // 顶部导航栏
          _buildTopNavigation(isDark),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 页面标题
          _buildPageTitle(isDark),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 登录表单
          Expanded(
            child: SingleChildScrollView(
              child: _buildLoginForm(isDark, authActions, authState),
            ),
          ),
          
          // 底部注册链接
          _buildBottomLinks(isDark),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 🔙 构建顶部导航栏
  Widget _buildTopNavigation(bool isDark) {
    return Row(
      children: [
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.getTextPrimaryColor(isDark),
                size: 20,
              ),
            ),
          ),
        ),
        
        const Spacer(),
        
        // 游客模式按钮
        BreathingWidget(
          child: GestureDetector(
            onTap: () => _handleGuestMode(),
            child: Text(
              '游客体验',
              style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🏷️ 构建页面标题
  Widget _buildPageTitle(bool isDark) {
    return Column(
      children: [
        BreathingWidget(
          duration: const Duration(seconds: 4),
          child: Text(
            '欢迎回来',
            style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.ultralight,
              letterSpacing: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          '登录以同步您的美食记录',
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            fontWeight: AppTypography.light,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 📝 构建登录表单
  Widget _buildLoginForm(
    bool isDark,
    AuthActionsNotifier authActions,
    AuthActionState authState,
  ) {
    final isLoading = authState == AuthActionState.loading || _isProcessing;
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 错误消息显示
          if (_errorMessage != null) _buildErrorMessage(isDark),
          
          // 邮箱输入框
          _buildEmailField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 密码输入框
          _buildPasswordField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.sm),
          
          // 忘记密码链接
          _buildForgotPasswordLink(isDark),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 登录按钮
          _buildLoginButton(isDark, authActions, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 分割线
          _buildDivider(isDark),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Google 登录按钮
          _buildGoogleLoginButton(isDark, authActions, isLoading),
        ],
      ),
    );
  }

  /// ❌ 构建错误消息显示
  Widget _buildErrorMessage(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: Colors.red,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📧 构建邮箱输入框
  Widget _buildEmailField(bool isDark, bool isLoading) {
    return BreathingWidget(
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: '邮箱地址',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.getTextSecondaryColor(isDark),
          ),
          filled: true,
          fillColor: AppColors.getBackgroundSecondaryColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          labelStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        validator: _validateEmail,
        onFieldSubmitted: (_) {
          _passwordFocusNode.requestFocus();
        },
      ),
    );
  }

  /// 🔒 构建密码输入框
  Widget _buildPasswordField(bool isDark, bool isLoading) {
    return BreathingWidget(
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: '密码',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.getTextSecondaryColor(isDark),
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
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
          filled: true,
          fillColor: AppColors.getBackgroundSecondaryColor(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          labelStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        validator: _validatePassword,
        onFieldSubmitted: (_) => _handleEmailLogin(),
      ),
    );
  }

  /// 🔄 构建忘记密码链接
  Widget _buildForgotPasswordLink(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _handleForgotPassword(),
        child: Text(
          '忘记密码？',
          style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
            color: AppColors.primary,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
    );
  }

  /// 🎯 构建登录按钮
  Widget _buildLoginButton(
    bool isDark,
    AuthActionsNotifier authActions,
    bool isLoading,
  ) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: isLoading ? null : () => _handleEmailLogin(),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isLoading 
                ? LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: isLoading ? [] : [
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
              if (isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else ...[
                Icon(
                  Icons.login,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                isLoading ? '登录中...' : '登录',
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

  /// ➖ 构建分割线
  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '或',
            style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
              color: AppColors.getTextSecondaryColor(isDark),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  /// 🌐 构建Google登录按钮
  Widget _buildGoogleLoginButton(
    bool isDark,
    AuthActionsNotifier authActions,
    bool isLoading,
  ) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: isLoading ? null : () => _handleGoogleLogin(),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google 图标
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '使用 Google 登录',
                style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📝 构建底部链接
  Widget _buildBottomLinks(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => _handleRegisterTap(),
          child: Text(
            '立即注册',
            style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
              color: AppColors.primary,
              fontWeight: AppTypography.medium,
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