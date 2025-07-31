/// 📝 注册页面
/// 
/// 用户账号注册界面，支持邮箱密码注册和Google快速注册
/// 采用极简设计风格，遵循95%黑白灰 + 5%彩色焦点的设计原则
/// 
/// 主要功能：
/// - 邮箱密码注册表单
/// - 密码确认验证
/// - Google快速注册
/// - 实时表单验证
/// - 错误状态显示
/// - 用户协议确认
/// - 跳转登录页面
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
import '../../../../shared/widgets/minimal_card.dart';

/// 📝 注册页面
/// 
/// 极简设计的注册界面，提供邮箱密码和Google注册选项
/// 包含完整的表单验证、密码确认和用户协议确认
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  /// 表单全局键
  final _formKey = GlobalKey<FormState>();
  
  /// 昵称输入控制器
  final _displayNameController = TextEditingController();
  
  /// 邮箱输入控制器
  final _emailController = TextEditingController();
  
  /// 密码输入控制器
  final _passwordController = TextEditingController();
  
  /// 确认密码输入控制器
  final _confirmPasswordController = TextEditingController();
  
  /// 昵称输入焦点节点
  final _displayNameFocusNode = FocusNode();
  
  /// 邮箱输入焦点节点
  final _emailFocusNode = FocusNode();
  
  /// 密码输入焦点节点
  final _passwordFocusNode = FocusNode();
  
  /// 确认密码输入焦点节点
  final _confirmPasswordFocusNode = FocusNode();
  
  /// 是否显示密码
  bool _obscurePassword = true;
  
  /// 是否显示确认密码
  bool _obscureConfirmPassword = true;
  
  /// 是否同意用户协议
  bool _agreedToTerms = false;
  
  /// 是否正在处理注册
  bool _isProcessing = false;
  
  /// 错误消息
  String? _errorMessage;
  
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
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
          // 注册成功，跳转到主页
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
          
          // 注册表单
          Expanded(
            child: SingleChildScrollView(
              child: _buildRegisterForm(isDark, authActions, authState),
            ),
          ),
          
          // 底部登录链接
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
            '创建账号',
            style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.ultralight,
              letterSpacing: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          '加入爱心食谱，开始您的美食之旅',
          style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
            fontWeight: AppTypography.light,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 📝 构建注册表单
  Widget _buildRegisterForm(
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
          
          // 昵称输入框
          _buildDisplayNameField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 邮箱输入框
          _buildEmailField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 密码输入框
          _buildPasswordField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 确认密码输入框
          _buildConfirmPasswordField(isDark, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 用户协议确认
          _buildTermsAgreement(isDark),
          
          const SizedBox(height: AppSpacing.xxl),
          
          // 注册按钮
          _buildRegisterButton(isDark, authActions, isLoading),
          
          const SizedBox(height: AppSpacing.lg),
          
          // 分割线
          _buildDivider(isDark),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Google 注册按钮
          _buildGoogleRegisterButton(isDark, authActions, isLoading),
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

  /// 👤 构建昵称输入框
  Widget _buildDisplayNameField(bool isDark, bool isLoading) {
    return BreathingWidget(
      child: TextFormField(
        controller: _displayNameController,
        focusNode: _displayNameFocusNode,
        textInputAction: TextInputAction.next,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: '昵称（可选）',
          prefixIcon: Icon(
            Icons.person_outline,
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
          labelStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        style: AppTypography.bodyMediumStyle(isDark: isDark),
        onFieldSubmitted: (_) {
          _emailFocusNode.requestFocus();
        },
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
        textInputAction: TextInputAction.next,
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
        onFieldSubmitted: (_) {
          _confirmPasswordFocusNode.requestFocus();
        },
      ),
    );
  }

  /// 🔐 构建确认密码输入框
  Widget _buildConfirmPasswordField(bool isDark, bool isLoading) {
    return BreathingWidget(
      child: TextFormField(
        controller: _confirmPasswordController,
        focusNode: _confirmPasswordFocusNode,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        enabled: !isLoading,
        decoration: InputDecoration(
          labelText: '确认密码',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.getTextSecondaryColor(isDark),
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
        validator: _validateConfirmPassword,
        onFieldSubmitted: (_) => _handleEmailRegister(),
      ),
    );
  }

  /// 📋 构建用户协议确认
  Widget _buildTermsAgreement(bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms 
                  ? AppColors.primary 
                  : AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _agreedToTerms 
                    ? AppColors.primary 
                    : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _agreedToTerms
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
        ),
        
        const SizedBox(width: AppSpacing.sm),
        
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              children: [
                const TextSpan(text: '我已阅读并同意'),
                TextSpan(
                  text: '用户协议',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '隐私政策',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🎯 构建注册按钮
  Widget _buildRegisterButton(
    bool isDark,
    AuthActionsNotifier authActions,
    bool isLoading,
  ) {
    final canRegister = _agreedToTerms && !isLoading;
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: canRegister ? () => _handleEmailRegister() : null,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: canRegister 
                ? AppColors.primaryGradient
                : LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: canRegister ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : [],
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
                  Icons.person_add,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                isLoading ? '注册中...' : '创建账号',
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

  /// 🌐 构建Google注册按钮
  Widget _buildGoogleRegisterButton(
    bool isDark,
    AuthActionsNotifier authActions,
    bool isLoading,
  ) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: isLoading ? null : () => _handleGoogleRegister(),
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
                '使用 Google 注册',
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
          '已有账号？',
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => _handleLoginTap(),
          child: Text(
            '立即登录',
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
    
    // 可以添加更复杂的密码强度验证
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    //   return '密码需包含大小写字母和数字';
    // }
    
    return null;
  }

  /// ✅ 确认密码验证
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    
    if (value != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    
    return null;
  }

  // ==================== 事件处理方法 ====================

  /// 📝 处理邮箱密码注册
  Future<void> _handleEmailRegister() async {
    // 收起键盘
    FocusScope.of(context).unfocus();
    
    // 检查用户协议确认
    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = '请先同意用户协议和隐私政策';
      });
      return;
    }
    
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
      final success = await authActions.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
      );
      
      if (!success && mounted) {
        // 获取错误信息
        final error = authActions.lastError;
        setState(() {
          _errorMessage = error?.message ?? '注册失败，请重试';
        });
      } else if (success && mounted) {
        // 注册成功，显示邮箱验证提示
        _showEmailVerificationDialog();
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

  /// 🌐 处理Google注册
  Future<void> _handleGoogleRegister() async {
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
          _errorMessage = error?.message ?? 'Google注册失败，请重试';
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google注册过程中发生错误，请重试';
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

  /// 📧 显示邮箱验证对话框
  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('验证邮箱'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '我们已向 ${_emailController.text} 发送了验证邮件',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '请检查邮箱并点击验证链接完成注册',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('稍后验证'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resendVerificationEmail();
            },
            child: const Text('重新发送'),
          ),
        ],
      ),
    );
  }

  /// 📤 重新发送验证邮件
  Future<void> _resendVerificationEmail() async {
    try {
      final authActions = ref.read(authActionsProvider.notifier);
      final success = await authActions.resendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? '验证邮件已重新发送'
                  : '发送失败，请稍后重试',
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
            content: Text('发送验证邮件时发生错误'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 🔑 处理登录页面跳转
  void _handleLoginTap() {
    debugPrint('👆 用户点击：立即登录');
    context.push('/auth/login');
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
                // 用户已经在注册页面，无需跳转
              },
            ),
          ),
        );
      }
    });
  }
}