import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/challenge.dart';

/// 评分页面
/// 挑战发起方对完成的菜品进行评分
class RatingScreen extends StatefulWidget {
  final Challenge challenge;
  
  const RatingScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  double _currentRating = 0;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  
  // 预设的评分短语
  final List<String> _ratingPhrases = [
    '还需要多练习呢～',
    '有进步空间',
    '做得不错！',
    '很棒，超出预期！',
    '完美！厨神级别！',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // 如果已经有评分，填入现有数据
    if (widget.challenge.rating != null) {
      _currentRating = widget.challenge.rating!;
      _noteController.text = widget.challenge.ratingNote ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
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
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: CustomScrollView(
              slivers: [
                // 自定义AppBar
                _buildSliverAppBar(isDark),
                
                // 内容区域
                SliverPadding(
                  padding: AppSpacing.pagePadding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 挑战信息卡片
                      _buildChallengeInfo(isDark),
                      
                      Space.h32,
                      
                      // 评分区域
                      _buildRatingSection(isDark),
                      
                      Space.h32,
                      
                      // 评价输入区域
                      _buildNoteSection(isDark),
                      
                      Space.h48,
                      
                      // 提交按钮
                      _buildSubmitButton(isDark),
                      
                      Space.h24,
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: BreathingWidget(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getBackgroundSecondaryColor(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.getTextPrimaryColor(isDark),
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        '评分',
        style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
      centerTitle: true,
    );
  }
  
  Widget _buildChallengeInfo(bool isDark) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadowColor(isDark),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 菜谱图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundSecondaryColor(isDark),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Center(
                child: Text(
                  widget.challenge.recipeIcon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            
            Space.w16,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.challenge.recipeName,
                    style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  Space.h8,
                  
                  Text(
                    '完成时间：${_formatDateTime(widget.challenge.completedAt!)}',
                    style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                      color: AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                  
                  if (widget.challenge.completionNote != null) ...[
                    Space.h8,
                    Text(
                      '"${widget.challenge.completionNote}"',
                      style: AppTypography.bodySmallStyle(isDark: isDark).copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRatingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '给这道菜打个分吧！',
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        
        Space.h16,
        
        // 星级评分
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = index < _currentRating;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentRating = index + 1.0;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: BreathingWidget(
                    child: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      size: 48,
                      color: isSelected 
                          ? const Color(0xFFFFD700) // 金色
                          : AppColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        Space.h16,
        
        // 评分文字提示
        if (_currentRating > 0)
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _ratingPhrases[_currentRating.toInt() - 1],
                key: ValueKey(_currentRating),
                style: AppTypography.bodyLargeStyle(isDark: isDark).copyWith(
                  color: AppColors.getTextSecondaryColor(isDark),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildNoteSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '留个评价吧～（可选）',
          style: AppTypography.titleMediumStyle(isDark: isDark).copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        
        Space.h16,
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.getBackgroundSecondaryColor(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '分享一下这道菜的味道、卖相或制作感受...',
              hintStyle: AppTypography.bodyMediumStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              counterStyle: AppTypography.captionStyle(isDark: isDark).copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
            style: AppTypography.bodyMediumStyle(isDark: isDark),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton(bool isDark) {
    final canSubmit = _currentRating > 0 && !_isSubmitting;
    
    return BreathingWidget(
      child: GestureDetector(
        onTap: canSubmit ? _submitRating : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: canSubmit
                ? AppColors.primaryGradient
                : null,
            color: canSubmit
                ? null
                : AppColors.getTextSecondaryColor(isDark).withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: canSubmit ? [
              BoxShadow(
                color: AppColors.getShadowColor(isDark),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Center(
            child: _isSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    widget.challenge.rating != null ? '更新评分' : '提交评分',
                    style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  void _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // 模拟API调用延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里应该调用真实的API来保存评分
      final updatedChallenge = widget.challenge.copyWith(
        rating: _currentRating,
        ratingNote: _noteController.text.trim().isEmpty 
            ? null 
            : _noteController.text.trim(),
      );
      
      HapticFeedback.mediumImpact();
      
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '评分已提交！',
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.getTextPrimaryColor(false),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
        ),
      );
      
      // 返回上一页，并传递更新后的挑战数据
      Navigator.of(context).pop(updatedChallenge);
      
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '提交失败，请重试',
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}