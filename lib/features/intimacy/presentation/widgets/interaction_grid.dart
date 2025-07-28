import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/intimacy_level.dart';

/// 🥰 互动网格组件
class InteractionGrid extends StatelessWidget {
  final List<InteractionBehavior> interactions;
  final Function(InteractionType) onInteractionTap;
  final int Function(InteractionType) getRemainingCount;

  const InteractionGrid({
    super.key,
    required this.interactions,
    required this.onInteractionTap,
    required this.getRemainingCount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: interactions.length,
        itemBuilder: (context, index) {
          final interaction = interactions[index];
          final remainingCount = getRemainingCount(interaction.type);
          
          return BreathingWidget(
            duration: Duration(milliseconds: 2000 + (index * 200)), // 错开动画时间
            child: InteractionCard(
              interaction: interaction,
              remainingCount: remainingCount,
              onTap: () => onInteractionTap(interaction.type),
            ),
          );
        },
      ),
    );
  }
}

/// 🥰 单个互动卡片
class InteractionCard extends StatefulWidget {
  final InteractionBehavior interaction;
  final int remainingCount;
  final VoidCallback onTap;

  const InteractionCard({
    super.key,
    required this.interaction,
    required this.remainingCount,
    required this.onTap,
  });

  @override
  State<InteractionCard> createState() => _InteractionCardState();
}

class _InteractionCardState extends State<InteractionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.remainingCount > 0;
    
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapCancel(),
      onTap: isAvailable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: isAvailable 
                    ? AppColors.backgroundColor 
                    : AppColors.backgroundSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(
                  color: isAvailable 
                      ? widget.interaction.iconColor.withValues(alpha: 0.3)
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: isAvailable ? [
                  BoxShadow(
                    color: widget.interaction.iconColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : null,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 互动图标
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isAvailable ? LinearGradient(
                          colors: [
                            widget.interaction.iconColor,
                            widget.interaction.iconColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) : null,
                        color: isAvailable ? null : AppColors.textSecondary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        boxShadow: isAvailable ? [
                          BoxShadow(
                            color: widget.interaction.iconColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          widget.interaction.emoji,
                          style: TextStyle(
                            fontSize: 24,
                            color: isAvailable ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    
                    Space.h8,
                    
                    // 互动标题
                    Text(
                      widget.interaction.title,
                      style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                        fontWeight: FontWeight.w500,
                        color: isAvailable ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    Space.h4,
                    
                    // 积分和剩余次数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 积分
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable 
                                ? widget.interaction.iconColor.withValues(alpha: 0.1)
                                : AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          ),
                          child: Text(
                            '+${widget.interaction.basePoints}',
                            style: AppTypography.captionStyle(isDark: false).copyWith(
                              color: isAvailable 
                                  ? widget.interaction.iconColor
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        
                        Space.w8,
                        
                        // 剩余次数
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable 
                                ? AppColors.emotionGradient.colors.first.withValues(alpha: 0.1)
                                : AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          ),
                          child: Text(
                            '${widget.remainingCount}次',
                            style: AppTypography.captionStyle(isDark: false).copyWith(
                              color: isAvailable 
                                  ? AppColors.emotionGradient.colors.first
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // 不可用时显示提示
                    if (!isAvailable) ...[
                      Space.h4,
                      Text(
                        '今日已用完',
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTapDown() {
    if (widget.remainingCount > 0) {
      setState(() {
        _isPressed = true;
      });
      _scaleController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
    }
  }
}

/// 🥰 互动历史展示组件
class InteractionHistory extends StatelessWidget {
  final List<InteractionRecord> records;
  final int maxItems;

  const InteractionHistory({
    super.key,
    required this.records,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayRecords = records.take(maxItems).toList();
    
    if (displayRecords.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: displayRecords.map((record) => 
        _buildRecordItem(record)
      ).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Text('💭', style: TextStyle(fontSize: 40)),
          Space.h8,
          Text(
            '暂无互动记录',
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Space.h4,
          Text(
            '快来开始第一次互动吧～',
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(InteractionRecord record) {
    final behavior = InteractionBehavior.getBehavior(record.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        children: [
          // 互动图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: behavior?.iconColor.withValues(alpha: 0.2) ?? AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                record.getEmoji(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          Space.w12,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.getDisplayText(),
                  style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatTime(record.timestamp),
                  style: AppTypography.captionStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // 积分
          Text(
            '+${record.pointsEarned}',
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: behavior?.iconColor ?? AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}