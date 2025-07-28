import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/province_cuisine.dart';

/// 菜品进度卡片组件
class DishProgressCard extends StatefulWidget {
  final RegionalDish dish;
  final bool showProgress;
  final VoidCallback? onTap;

  const DishProgressCard({
    super.key,
    required this.dish,
    this.showProgress = true,
    this.onTap,
  });

  @override
  State<DishProgressCard> createState() => _DishProgressCardState();
}

class _DishProgressCardState extends State<DishProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 已完成的菜品添加发光效果
    if (widget.dish.isCompleted) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCard();
    
    // 已完成的菜品添加呼吸动画
    if (widget.dish.isCompleted) {
      card = BreathingWidget(child: card);
    }
    
    // 添加发光效果
    if (widget.dish.isCompleted) {
      card = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: _getDifficultyColor().withOpacity(0.3 * _glowController.value),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: card,
          );
        },
      );
    }
    
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      child: card,
    );
  }

  Widget _buildCard() {
    final isCompleted = widget.dish.isCompleted;
    final difficultyColor = _getDifficultyColor();
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: isCompleted 
              ? const Color(0xFF4ECB71).withOpacity(0.3)
              : difficultyColor.withOpacity(0.2),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted 
                ? const Color(0xFF4ECB71).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: isCompleted ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部信息
            Row(
              children: [
                // 菜品图标
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? const Color(0xFF4ECB71).withOpacity(0.1)
                        : difficultyColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted 
                          ? const Color(0xFF4ECB71).withOpacity(0.3)
                          : difficultyColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.dish.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                Space.w12,
                
                // 菜品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.dish.name,
                              style: AppTypography.bodyLargeStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w500,
                                color: isCompleted 
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          
                          // 招牌标识
                          if (widget.dish.isSignature) ...[
                            Space.w8,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.emotionGradient,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: Text(
                                '招牌',
                                style: AppTypography.captionStyle(isDark: false).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      Space.h4,
                      
                      // 难度和时间
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.trending_up,
                            label: widget.dish.difficultyText,
                            color: difficultyColor,
                          ),
                          Space.w8,
                          _buildInfoChip(
                            icon: Icons.schedule,
                            label: '${widget.dish.cookTime}分钟',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 完成状态
                if (isCompleted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ECB71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.radio_button_unchecked,
                      color: AppColors.textSecondary.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
              ],
            ),
            
            Space.h12,
            
            // 菜品描述
            Text(
              widget.dish.description,
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 进度信息
            if (widget.showProgress && isCompleted) ...[
              Space.h12,
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECB71).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(
                    color: const Color(0xFF4ECB71).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: const Color(0xFF4ECB71),
                      size: 16,
                    ),
                    Space.w8,
                    Expanded(
                      child: Text(
                        '已于${_formatCompletedTime()}完成',
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: const Color(0xFF4ECB71),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // 制作提示
            if (!isCompleted) ...[
              Space.h12,
              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        difficultyColor.withOpacity(0.1),
                        difficultyColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    border: Border.all(
                      color: difficultyColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: difficultyColor,
                        size: 16,
                      ),
                      Space.w8,
                      Text(
                        '开始制作',
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: difficultyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.dish.difficulty) {
      case 1:
        return const Color(0xFF4CAF50); // 入门 - 绿色
      case 2:
        return const Color(0xFF2196F3); // 简单 - 蓝色
      case 3:
        return const Color(0xFFFF9800); // 中等 - 橙色
      case 4:
        return const Color(0xFFFF5722); // 困难 - 深橙色
      case 5:
        return const Color(0xFFE91E63); // 大师 - 粉红色
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatCompletedTime() {
    if (widget.dish.completedAt == null) return '';
    
    final now = DateTime.now();
    final completedAt = widget.dish.completedAt!;
    final difference = now.difference(completedAt);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 5) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    }
    if (difference.inDays == 1) return '昨天';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    return '${completedAt.month}月${completedAt.day}日';
  }
}