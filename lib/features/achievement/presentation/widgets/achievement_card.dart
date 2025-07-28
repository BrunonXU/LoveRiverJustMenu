import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/achievement.dart';

/// 成就卡片组件
class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool isCompact;
  final bool showUnlockAnimation;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.isCompact = false,
    this.showUnlockAnimation = false,
    this.onTap,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _unlockController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _unlockScaleAnimation;
  late Animation<double> _unlockOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _unlockScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: Curves.elasticOut,
    ));
    
    _unlockOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _unlockController,
      curve: const Interval(0.0, 0.5),
    ));
    
    // 启动脉冲动画（接近完成的成就）
    if (widget.achievement.isNearComplete && !widget.achievement.isUnlocked) {
      _pulseController.repeat(reverse: true);
    }
    
    // 启动解锁动画
    if (widget.showUnlockAnimation) {
      _unlockController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showUnlockAnimation) {
      return AnimatedBuilder(
        animation: _unlockController,
        builder: (context, child) {
          return Transform.scale(
            scale: _unlockScaleAnimation.value,
            child: Opacity(
              opacity: _unlockOpacityAnimation.value,
              child: _buildCard(),
            ),
          );
        },
      );
    }
    
    if (widget.achievement.isNearComplete && !widget.achievement.isUnlocked) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: _buildCard(),
          );
        },
      );
    }
    
    return _buildCard();
  }

  Widget _buildCard() {
    final isUnlocked = widget.achievement.isUnlocked;
    final isSecret = widget.achievement.isSecret && !isUnlocked;
    
    Widget cardContent = widget.isCompact 
        ? _buildCompactContent(isSecret)
        : _buildFullContent(isSecret);
    
    // 添加呼吸动画（已解锁的成就）
    if (isUnlocked) {
      cardContent = BreathingWidget(child: cardContent);
    }
    
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        } else if (isUnlocked) {
          _showAchievementDetail();
        }
      },
      child: cardContent,
    );
  }

  Widget _buildFullContent(bool isSecret) {
    final isUnlocked = widget.achievement.isUnlocked;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isUnlocked 
            ? Border.all(
                color: widget.achievement.levelColor.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? widget.achievement.levelColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
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
                // 成就图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSecret 
                        ? AppColors.textSecondary.withOpacity(0.1)
                        : widget.achievement.levelColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: isUnlocked
                        ? Border.all(
                            color: widget.achievement.levelColor.withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      isSecret ? '❓' : widget.achievement.emoji,
                      style: TextStyle(
                        fontSize: isUnlocked ? 28 : 24,
                        color: isSecret ? AppColors.textSecondary : null,
                      ),
                    ),
                  ),
                ),
                
                Space.w16,
                
                // 成就信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isSecret ? '隐藏成就' : widget.achievement.title,
                              style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                                fontWeight: FontWeight.w500,
                                color: isUnlocked 
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isUnlocked) _buildLevelBadge(),
                        ],
                      ),
                      
                      Space.h4,
                      
                      Text(
                        isSecret 
                            ? (widget.achievement.tip ?? '完成特定条件解锁')
                            : widget.achievement.description,
                        style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (!isSecret && !isUnlocked) ...[
                        Space.h8,
                        Text(
                          widget.achievement.conditions.first.description,
                          style: AppTypography.captionStyle(isDark: false).copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (!isSecret && !isUnlocked) ...[
              Space.h16,
              _buildProgressBar(),
            ],
            
            if (isUnlocked) ...[
              Space.h12,
              _buildUnlockedInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(bool isSecret) {
    final isUnlocked = widget.achievement.isUnlocked;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: isUnlocked 
            ? Border.all(
                color: widget.achievement.levelColor.withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? widget.achievement.levelColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // 紧凑图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSecret 
                    ? AppColors.textSecondary.withOpacity(0.1)
                    : widget.achievement.levelColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isSecret ? '❓' : widget.achievement.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            Space.w12,
            
            // 紧凑信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSecret ? '隐藏成就' : widget.achievement.title,
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      fontWeight: FontWeight.w500,
                      color: isUnlocked 
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (!isSecret && !isUnlocked) ...[
                    Space.h4,
                    _buildCompactProgressBar(),
                  ],
                  
                  if (isUnlocked) ...[
                    Space.h2,
                    Text(
                      '+${widget.achievement.points} 积分',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: widget.achievement.levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (isUnlocked) _buildLevelBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(widget.achievement.progress * 100).round()}%',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        Space.h4,
        
        LinearProgressIndicator(
          value: widget.achievement.progress,
          backgroundColor: AppColors.backgroundSecondary,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.achievement.isNearComplete 
                ? AppColors.emotionGradient.colors.first
                : AppColors.primary,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildCompactProgressBar() {
    return LinearProgressIndicator(
      value: widget.achievement.progress,
      backgroundColor: AppColors.backgroundSecondary,
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.achievement.isNearComplete 
            ? AppColors.emotionGradient.colors.first
            : AppColors.primary,
      ),
      minHeight: 4,
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: widget.achievement.levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: widget.achievement.levelColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.achievement.levelName,
        style: AppTypography.captionStyle(isDark: false).copyWith(
          color: widget.achievement.levelColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUnlockedInfo() {
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          color: widget.achievement.levelColor,
          size: 16,
        ),
        Space.w4,
        Text(
          '+${widget.achievement.points} 积分',
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: widget.achievement.levelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const Spacer(),
        
        if (widget.achievement.unlockedAt != null)
          Text(
            _formatUnlockDate(widget.achievement.unlockedAt!),
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  void _showAchievementDetail() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: widget.achievement.levelColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 庆祝图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.achievement.levelColor,
                      widget.achievement.levelColor.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.achievement.levelColor.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.achievement.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              
              Space.h16,
              
              Text(
                widget.achievement.title,
                style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w300,
                  color: widget.achievement.levelColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              Space.h8,
              
              Text(
                widget.achievement.description,
                style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              Space.h16,
              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: widget.achievement.levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: widget.achievement.levelColor,
                      size: 20,
                    ),
                    Space.w8,
                    Text(
                      '${widget.achievement.levelName}成就 • +${widget.achievement.points}积分',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: widget.achievement.levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Space.h16,
              
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      '关闭',
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUnlockDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return '今天解锁';
    if (difference.inDays == 1) return '昨天解锁';
    if (difference.inDays < 7) return '${difference.inDays}天前解锁';
    return '${date.month}月${date.day}日解锁';
  }
}