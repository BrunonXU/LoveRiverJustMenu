import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../shared/widgets/breathing_widget.dart';
import '../../domain/models/challenge.dart';

/// 挑战卡片组件
/// 显示挑战信息，支持接受/拒绝操作
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return BreathingWidget(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            // 特殊状态的边框效果
            border: _getBorderForStatus(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部状态栏
              _buildStatusHeader(),
              
              // 主要内容
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 菜谱信息
                    _buildRecipeInfo(),
                    
                    const SizedBox(height: 16),
                    
                    // 挑战消息
                    _buildChallengeMessage(),
                    
                    const SizedBox(height: 16),
                    
                    // 挑战详情
                    _buildChallengeDetails(),
                    
                    // 操作按钮
                    if (_shouldShowActions()) ...[
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Border? _getBorderForStatus() {
    switch (challenge.status) {
      case ChallengeStatus.pending:
        return Border.all(
          color: Color(0xFFFF6B6B).withOpacity(0.3),
          width: 1,
        );
      case ChallengeStatus.accepted:
        return Border.all(
          color: Color(0xFF5B6FED).withOpacity(0.3),
          width: 1,
        );
      case ChallengeStatus.completed:
        return Border.all(
          color: Color(0xFF4ECB71).withOpacity(0.3),
          width: 1,
        );
      default:
        return null;
    }
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    IconData statusIcon;
    
    switch (challenge.status) {
      case ChallengeStatus.pending:
        statusColor = Color(0xFFFF6B6B);
        statusIcon = Icons.schedule;
        break;
      case ChallengeStatus.accepted:
        statusColor = Color(0xFF5B6FED);
        statusIcon = Icons.play_circle;
        break;
      case ChallengeStatus.completed:
        statusColor = Color(0xFF4ECB71);
        statusIcon = Icons.check_circle;
        break;
      case ChallengeStatus.rejected:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.cancel;
        break;
      case ChallengeStatus.expired:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLarge),
          topRight: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            challenge.statusText,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(challenge.createdAt),
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo() {
    return Row(
      children: [
        // 菜谱图标
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Center(
            child: Text(
              challenge.recipeIcon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 菜谱信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.recipeName,
                style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.timer,
                    text: '${challenge.estimatedTime}分钟',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.star,
                    text: challenge.difficultyText,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 超时提示
        if (challenge.isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Text(
              '超时',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              challenge.message,
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeDetails() {
    final details = <Widget>[];
    
    // 接受时间
    if (challenge.acceptedAt != null) {
      details.add(_buildDetailRow(
        icon: Icons.play_circle_outline,
        label: '开始时间',
        value: _formatDetailTime(challenge.acceptedAt!),
      ));
    }
    
    // 完成时间
    if (challenge.completedAt != null) {
      details.add(_buildDetailRow(
        icon: Icons.check_circle_outline,
        label: '完成时间',
        value: _formatDetailTime(challenge.completedAt!),
      ));
    }
    
    // 用时
    if (challenge.duration != null) {
      details.add(_buildDetailRow(
        icon: Icons.hourglass_empty,
        label: '用时',
        value: '${challenge.duration!.inMinutes}分钟',
      ));
    }
    
    // 评分
    if (challenge.rating != null) {
      details.add(_buildDetailRow(
        icon: Icons.star,
        label: '评分',
        value: '${challenge.rating}⭐',
      ));
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Divider(color: AppColors.backgroundSecondary),
        const SizedBox(height: 8),
        ...details,
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.captionStyle(isDark: false).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowActions() {
    return challenge.status == ChallengeStatus.pending &&
           (onAccept != null || onReject != null);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onReject != null)
          Expanded(
            child: _buildActionButton(
              text: '拒绝',
              color: AppColors.textSecondary,
              onTap: onReject!,
            ),
          ),
        
        if (onAccept != null && onReject != null)
          const SizedBox(width: 16),
        
        if (onAccept != null)
          Expanded(
            child: _buildActionButton(
              text: '接受挑战',
              color: Color(0xFF5B6FED),
              onTap: onAccept!,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  String _formatDetailTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}