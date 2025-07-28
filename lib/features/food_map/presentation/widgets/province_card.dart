import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/province_cuisine.dart';

/// 省份美食卡片组件
class ProvinceCard extends StatefulWidget {
  final ProvinceCuisine province;
  final bool isCompact;
  final VoidCallback? onTap;

  const ProvinceCard({
    super.key,
    required this.province,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<ProvinceCard> createState() => _ProvinceCardState();
}

class _ProvinceCardState extends State<ProvinceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // 即将解锁的省份添加脉冲动画
    if (widget.province.isNearUnlock && !widget.province.isUnlocked) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = widget.isCompact ? _buildCompactCard() : _buildFullCard();
    
    // 已解锁的省份添加呼吸动画
    if (widget.province.isUnlocked) {
      card = BreathingWidget(child: card);
    }
    
    // 即将解锁的省份添加脉冲动画
    if (widget.province.isNearUnlock && !widget.province.isUnlocked) {
      card = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.03),
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

  Widget _buildFullCard() {
    final isUnlocked = widget.province.isUnlocked;
    final isNearUnlock = widget.province.isNearUnlock;
    final completedDishes = widget.province.dishes.where((d) => d.isCompleted).length;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: isUnlocked 
              ? widget.province.themeColor.withOpacity(0.3)
              : isNearUnlock 
                  ? AppColors.emotionGradient.colors.first.withOpacity(0.3)
                  : AppColors.textSecondary.withOpacity(0.1),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? widget.province.themeColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isUnlocked ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 省份图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? widget.province.themeColor.withOpacity(0.1)
                        : AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                    border: isUnlocked
                        ? Border.all(
                            color: widget.province.themeColor.withOpacity(0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.province.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                
                Space.w16,
                
                // 省份信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.province.provinceName,
                            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                              fontWeight: FontWeight.w500,
                              color: isUnlocked 
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Space.w8,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.province.themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            ),
                            child: Text(
                              widget.province.cuisineStyle,
                              style: AppTypography.captionStyle(isDark: false).copyWith(
                                color: widget.province.themeColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Space.h4,
                      
                      Text(
                        widget.province.description,
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 状态指示
                if (isUnlocked)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4ECB71),
                    size: 24,
                  )
                else if (isNearUnlock)
                  Icon(
                    Icons.hourglass_empty,
                    color: AppColors.emotionGradient.colors.first,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.lock,
                    color: AppColors.textSecondary.withOpacity(0.5),
                    size: 24,
                  ),
              ],
            ),
            
            Space.h16,
            
            // 进度条
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '解锁进度',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$completedDishes/${widget.province.requiredDishes} 道菜',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: isUnlocked 
                            ? const Color(0xFF4ECB71)
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                Space.h4,
                
                LinearProgressIndicator(
                  value: widget.province.unlockProgress,
                  backgroundColor: AppColors.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked 
                        ? const Color(0xFF4ECB71)
                        : isNearUnlock 
                            ? AppColors.emotionGradient.colors.first
                            : AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            if (!isUnlocked && widget.province.unlockTips.isNotEmpty) ...[
              Space.h12,
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.emotionGradient.colors.first,
                      size: 16,
                    ),
                    Space.w8,
                    Expanded(
                      child: Text(
                        widget.province.unlockTips.first,
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (isUnlocked && widget.province.unlockDate != null) ...[
              Space.h8,
              Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: widget.province.themeColor,
                    size: 16,
                  ),
                  Space.w4,
                  Text(
                    '已于${_formatUnlockDate(widget.province.unlockDate!)}解锁',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: widget.province.themeColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    final isUnlocked = widget.province.isUnlocked;
    final isNearUnlock = widget.province.isNearUnlock;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: isUnlocked 
              ? widget.province.themeColor.withOpacity(0.3)
              : isNearUnlock 
                  ? AppColors.emotionGradient.colors.first.withOpacity(0.3)
                  : AppColors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? widget.province.themeColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 省份图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? widget.province.themeColor.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.province.iconEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            Space.h8,
            
            // 省份名称
            Text(
              widget.province.provinceName,
              style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                fontWeight: FontWeight.w500,
                color: isUnlocked 
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            
            Space.h4,
            
            // 进度
            Text(
              '${widget.province.progressPercentage}%',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: isUnlocked 
                    ? const Color(0xFF4ECB71)
                    : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            Space.h4,
            
            // 迷你进度条
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.province.unlockProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? const Color(0xFF4ECB71)
                        : isNearUnlock 
                            ? AppColors.emotionGradient.colors.first
                            : AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUnlockDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '刚刚';
      }
      return '${difference.inHours}小时前';
    }
    if (difference.inDays == 1) return '昨天';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    return '${date.month}月${date.day}日';
  }
}