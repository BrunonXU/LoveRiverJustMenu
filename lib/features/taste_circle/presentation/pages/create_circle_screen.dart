import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../../../shared/widgets/minimal_card.dart';
import '../../../../core/router/app_router.dart';

/// 🎨 创建味道圈页面 - 极简设计
class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  
  CircleType _selectedType = CircleType.couple;
  DateTime? _anniversaryDate;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 生成的邀请码
  String? _generatedCode;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  /// 生成6位邀请码
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// 创建味道圈
  void _createCircle() {
    if (_nameController.text.trim().isEmpty) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // 模拟创建过程
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _generatedCode = _generateInviteCode();
          _isCreating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _generatedCode != null
              ? _buildInviteCodeView(isDark)
              : _buildCreateForm(isDark),
        ),
      ),
    );
  }

  /// 构建创建表单
  Widget _buildCreateForm(bool isDark) {
    return Column(
      children: [
        // 顶部导航
        _buildHeader(context, isDark, '创建味道圈'),

        // 表单内容
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 圈子名称
                Text(
                  '为你的圈子取个名字',
                  style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildNameInput(isDark),

                const SizedBox(height: AppSpacing.xl),

                // 圈子类型
                Text(
                  '选择圈子类型',
                  style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTypeSelector(isDark),

                const SizedBox(height: AppSpacing.xl),

                // 纪念日（可选）
                Text(
                  '设置纪念日（可选）',
                  style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDatePicker(isDark),

                const SizedBox(height: AppSpacing.xxl),

                // 创建按钮
                _buildCreateButton(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建邀请码展示视图
  Widget _buildInviteCodeView(bool isDark) {
    return Column(
      children: [
        // 顶部导航
        _buildHeader(context, isDark, ''),

        // 邀请码内容
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '邀请码已生成 ✨',
                    style: AppTypography.titleLargeStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.light,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 邀请码卡片
                  BreathingWidget(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getBackgroundSecondaryColor(isDark),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        _generatedCode!.split('').join(' '),
                        style: AppTypography.displayLargeStyle(isDark: isDark).copyWith(
                          fontWeight: AppTypography.medium,
                          fontSize: 32,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 圈子信息
                  Text(
                    '「${_nameController.text}」',
                    style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '类型：${_getTypeIcon(_selectedType)} ${_getTypeLabel(_selectedType)}',
                        style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    '邀请好友输入此邀请码加入',
                    style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '有效期至：明天 ${DateTime.now().add(const Duration(days: 1)).hour}:${DateTime.now().add(const Duration(days: 1)).minute.toString().padLeft(2, '0')}',
                    style: AppTypography.captionStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          '复制邀请码',
                          Icons.copy,
                          () {
                            HapticFeedback.mediumImpact();
                            Clipboard.setData(ClipboardData(text: _generatedCode!));
                            // TODO: 显示复制成功提示
                          },
                          isDark,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildActionButton(
                          '微信分享',
                          Icons.share,
                          () {
                            HapticFeedback.lightImpact();
                            // TODO: 实现分享功能
                          },
                          isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 完成按钮
                  BreathingWidget(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go(AppRouter.personalSpace);
                      },
                      child: Text(
                        '完成',
                        style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建顶部导航栏
  Widget _buildHeader(BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // 返回按钮
          BreathingWidget(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (_generatedCode != null) {
                  // 如果已生成邀请码，返回到个人空间
                  context.go(AppRouter.personalSpace);
                } else {
                  context.pop();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.getBackgroundSecondaryColor(isDark),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextPrimaryColor(isDark),
                  size: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // 标题
          Text(
            title,
            style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
              fontWeight: AppTypography.light,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建名称输入框
  Widget _buildNameInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundSecondaryColor(isDark),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: _nameFocusNode.hasFocus
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        style: AppTypography.bodyLargeStyle(isDark: isDark),
        decoration: InputDecoration(
          hintText: '如：我们的小厨房',
          hintStyle: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
            color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.5),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
          border: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: CircleType.values.map((type) {
        final isSelected = _selectedType == type;
        return BreathingWidget(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedType = type;
              });
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTypeIcon(type),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _getTypeLabel(type),
                    style: AppTypography.captionStyle(isDark: isDark).copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.getTextSecondaryColor(isDark),
                      fontWeight: isSelected ? AppTypography.medium : AppTypography.light,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建日期选择器
  Widget _buildDatePicker(bool isDark) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.getBackgroundColor(isDark),
                  ),
                ),
                child: child!,
              );
            },
          );
          
          if (date != null) {
            setState(() {
              _anniversaryDate = date;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.getTextSecondaryColor(isDark),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                _anniversaryDate != null
                    ? '${_anniversaryDate!.year}-${_anniversaryDate!.month.toString().padLeft(2, '0')}-${_anniversaryDate!.day.toString().padLeft(2, '0')}'
                    : '选择纪念日',
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  color: _anniversaryDate != null
                      ? AppColors.getTextPrimaryColor(isDark)
                      : AppColors.getTextSecondaryColor(isDark).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建创建按钮
  Widget _buildCreateButton(bool isDark) {
    final isValid = _nameController.text.trim().isNotEmpty;
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: isValid && !_isCreating ? _createCircle : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: isValid ? AppColors.primaryGradient : null,
            color: isValid ? null : AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: isValid
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _isCreating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isValid ? Colors.white : AppColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  )
                : Text(
                    '创建味道圈',
                    style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                      fontWeight: AppTypography.medium,
                      color: isValid ? Colors.white : AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isPrimary = false,
  }) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary ? AppColors.primaryGradient : null,
            color: isPrimary ? null : AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: isPrimary
                ? null
                : Border.all(
                    color: AppColors.getTextSecondaryColor(isDark).withOpacity(0.2),
                    width: 1,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.getTextPrimaryColor(isDark),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                  color: isPrimary ? Colors.white : AppColors.getTextPrimaryColor(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeIcon(CircleType type) {
    switch (type) {
      case CircleType.couple:
        return '💑';
      case CircleType.family:
        return '👨‍👩‍👧';
      case CircleType.friends:
        return '👫';
    }
  }

  String _getTypeLabel(CircleType type) {
    switch (type) {
      case CircleType.couple:
        return '情侣';
      case CircleType.family:
        return '家人';
      case CircleType.friends:
        return '朋友';
    }
  }
}

/// 圈子类型枚举
enum CircleType {
  couple,
  family,
  friends,
}