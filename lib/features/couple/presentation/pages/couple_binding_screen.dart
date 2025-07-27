import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/animations/christmas_snow_effect.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../domain/providers/couple_providers.dart';
import '../../domain/models/couple_account.dart';

/// 情侣绑定页面
/// 支持创建情侣账号和加入现有账号
class CoupleBindingScreen extends ConsumerStatefulWidget {
  const CoupleBindingScreen({super.key});

  @override
  ConsumerState<CoupleBindingScreen> createState() => _CoupleBindingScreenState();
}

class _CoupleBindingScreenState extends ConsumerState<CoupleBindingScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  
  bool _isCreateMode = true; // true: 创建模式, false: 加入模式
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    _cardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 监听状态变化
    ref.listen(coupleAccountProvider, (previous, next) {
      if (next is CoupleAccountSuccess) {
        // 绑定成功，返回主页
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('情侣账号${_isCreateMode ? "创建" : "绑定"}成功！'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } else if (next is CoupleAccountError) {
        // 显示错误信息
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    return Scaffold(
      body: ChristmasSnowEffect(
        enableClickEffect: true,
        snowflakeCount: 3, // 减少雪花保证性能
        clickEffectColor: const Color(0xFF00BFFF),
        child: SafeArea(
          child: Column(
            children: [
              // 头部导航
              _buildHeader(isDark),
              
              // 主要内容区域
              Expanded(
                child: _buildMainContent(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          // 返回按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(isDark).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextSecondaryColor(isDark),
                  size: 18,
                ),
              ),
            ),
          ),
          
          Space.w16,
          
          // 标题
          Text(
            '情侣绑定',
            style: AppTypography.titleLargeStyle(isDark: isDark),
          ),
          
          const Spacer(),
          
          // 模式切换
          _buildModeSwitch(isDark),
        ],
      ),
    );
  }

  /// 构建模式切换
  Widget _buildModeSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadowColor(isDark).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSwitchButton('创建', _isCreateMode, isDark, () {
            setState(() => _isCreateMode = true);
            _cardController.forward(from: 0);
          }),
          _buildSwitchButton('加入', !_isCreateMode, isDark, () {
            setState(() => _isCreateMode = false);
            _cardController.forward(from: 0);
          }),
        ],
      ),
    );
  }

  /// 构建切换按钮
  Widget _buildSwitchButton(
    String text,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          text,
          style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
            color: isSelected 
                ? AppColors.primary
                : AppColors.getTextSecondaryColor(isDark),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(bool isDark) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: _isCreateMode 
                  ? _buildCreateMode(isDark)
                  : _buildJoinMode(isDark),
            ),
          ),
        );
      },
    );
  }

  /// 构建创建模式
  Widget _buildCreateMode(bool isDark) {
    return Column(
      children: [
        // 说明文字
        Text(
          '创建你们的专属美食空间',
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextPrimaryColor(isDark),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        
        Space.h8,
        
        Text(
          '设置情侣昵称和在一起的日期，生成邀请码分享给TA',
          style: AppTypography.bodySmallStyle(isDark: isDark),
          textAlign: TextAlign.center,
        ),
        
        Space.h48,
        
        // 创建表单卡片
        Expanded(
          child: BreathingWidget(
            child: MinimalCard(
              child: _CreateCoupleForm(isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建加入模式
  Widget _buildJoinMode(bool isDark) {
    return Column(
      children: [
        // 说明文字
        Text(
          '加入TA的美食空间',
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            color: AppColors.getTextPrimaryColor(isDark),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        
        Space.h8,
        
        Text(
          '输入TA分享的6位邀请码，完善个人资料',
          style: AppTypography.bodySmallStyle(isDark: isDark),
          textAlign: TextAlign.center,
        ),
        
        Space.h48,
        
        // 加入表单卡片
        Expanded(
          child: BreathingWidget(
            child: MinimalCard(
              child: _JoinCoupleForm(isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }
}

/// 创建情侣账号表单
class _CreateCoupleForm extends ConsumerStatefulWidget {
  final bool isDark;
  
  const _CreateCoupleForm({required this.isDark});

  @override
  ConsumerState<_CreateCoupleForm> createState() => _CreateCoupleFormState();
}

class _CreateCoupleFormState extends ConsumerState<_CreateCoupleForm> {
  final _formKey = GlobalKey<FormState>();
  final _coupleNameController = TextEditingController();
  DateTime? _relationshipStartDate;
  
  @override
  void dispose() {
    _coupleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coupleAccountProvider);
    final isLoading = state is CoupleAccountLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 情侣昵称输入
          _buildTextField(
            controller: _coupleNameController,
            label: '情侣昵称',
            hint: '例如：小明&小红的美食日记',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入情侣昵称';
              }
              if (value.length > 20) {
                return '昵称不能超过20个字符';
              }
              return null;
            },
          ),
          
          Space.h24,
          
          // 恋爱开始日期
          _buildDatePicker(),
          
          const Spacer(),
          
          // 创建按钮
          _buildCreateButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            color: AppColors.getTextPrimaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h8,
        
        TextFormField(
          controller: controller,
          validator: validator,
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
              color: AppColors.getTextSecondaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: AppColors.getBackgroundSecondaryColor(widget.isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '在一起的日期',
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            color: AppColors.getTextPrimaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h8,
        
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _relationshipStartDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            
            if (date != null) {
              setState(() => _relationshipStartDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSecondaryColor(widget.isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.getTextSecondaryColor(widget.isDark),
                  size: 20,
                ),
                
                Space.w12,
                
                Text(
                  _relationshipStartDate != null
                      ? '${_relationshipStartDate!.year}年${_relationshipStartDate!.month}月${_relationshipStartDate!.day}日'
                      : '选择日期',
                  style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
                    color: _relationshipStartDate != null
                        ? AppColors.getTextPrimaryColor(widget.isDark)
                        : AppColors.getTextSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(bool isLoading) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: isLoading ? null : _handleCreate,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isLoading 
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.5),
                      AppColors.primaryLight.withOpacity(0.5),
                    ],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '创建情侣账号',
                    style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_relationshipStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择在一起的日期'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentUserId = ref.read(currentUserIdProvider);
    
    ref.read(coupleAccountProvider.notifier).createCoupleAccount(
      creatorId: currentUserId,
      coupleName: _coupleNameController.text.trim(),
      relationshipStartDate: _relationshipStartDate!,
    );
  }
}

/// 加入情侣账号表单
class _JoinCoupleForm extends ConsumerStatefulWidget {
  final bool isDark;
  
  const _JoinCoupleForm({required this.isDark});

  @override
  ConsumerState<_JoinCoupleForm> createState() => _JoinCoupleFormState();
}

class _JoinCoupleFormState extends ConsumerState<_JoinCoupleForm> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _nicknameController = TextEditingController();
  DateTime? _birthday;
  Gender? _selectedGender;
  
  @override
  void dispose() {
    _inviteCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coupleAccountProvider);
    final isLoading = state is CoupleAccountLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 邀请码输入
          _buildTextField(
            controller: _inviteCodeController,
            label: '邀请码',
            hint: '输入6位邀请码',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入邀请码';
              }
              if (value.length != 6) {
                return '邀请码必须是6位';
              }
              return null;
            },
          ),
          
          Space.h24,
          
          // 昵称输入
          _buildTextField(
            controller: _nicknameController,
            label: '我的昵称',
            hint: '输入你的昵称',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入昵称';
              }
              return null;
            },
          ),
          
          Space.h24,
          
          // 生日选择
          _buildDatePicker(),
          
          Space.h24,
          
          // 性别选择
          _buildGenderSelector(),
          
          const Spacer(),
          
          // 加入按钮
          _buildJoinButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            color: AppColors.getTextPrimaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h8,
        
        TextFormField(
          controller: controller,
          validator: validator,
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
              color: AppColors.getTextSecondaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: AppColors.getBackgroundSecondaryColor(widget.isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '生日（可选）',
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            color: AppColors.getTextPrimaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h8,
        
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _birthday ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            
            if (date != null) {
              setState(() => _birthday = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSecondaryColor(widget.isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake,
                  color: AppColors.getTextSecondaryColor(widget.isDark),
                  size: 20,
                ),
                
                Space.w12,
                
                Text(
                  _birthday != null
                      ? '${_birthday!.year}年${_birthday!.month}月${_birthday!.day}日'
                      : '选择生日',
                  style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
                    color: _birthday != null
                        ? AppColors.getTextPrimaryColor(widget.isDark)
                        : AppColors.getTextSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别（可选）',
          style: AppTypography.bodyMediumStyle(isDark: widget.isDark).copyWith(
            color: AppColors.getTextPrimaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        
        Space.h8,
        
        Row(
          children: [
            _buildGenderOption(Gender.male, '男', Icons.male),
            Space.w12,
            _buildGenderOption(Gender.female, '女', Icons.female),
            Space.w12,
            _buildGenderOption(Gender.other, '其他', Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(Gender gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedGender = gender);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.getBackgroundSecondaryColor(widget.isDark),
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.getTextSecondaryColor(widget.isDark),
                size: 24,
              ),
              Space.h4,
              Text(
                label,
                style: AppTypography.captionStyle(isDark: widget.isDark).copyWith(
                  color: isSelected 
                      ? AppColors.primary
                      : AppColors.getTextSecondaryColor(widget.isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(bool isLoading) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: isLoading ? null : _handleJoin,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isLoading 
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.5),
                      AppColors.primaryLight.withOpacity(0.5),
                    ],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    '加入情侣账号',
                    style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleJoin() {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = ref.read(currentUserIdProvider);
    
    final profile = CoupleProfile(
      userId: currentUserId,
      nickname: _nicknameController.text.trim(),
      birthday: _birthday,
      gender: _selectedGender,
    );
    
    ref.read(coupleAccountProvider.notifier).joinCoupleAccount(
      inviteCode: _inviteCodeController.text.trim().toUpperCase(),
      partnerId: currentUserId,
      partnerProfile: profile,
    );
  }
}