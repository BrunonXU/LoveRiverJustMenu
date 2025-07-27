import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../domain/models/challenge.dart';

/// 挑战通知弹窗组件
/// 接收到新挑战时的全屏提醒界面
class ChallengeNotification extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewDetail;

  const ChallengeNotification({
    super.key,
    required this.challenge,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetail,
  });

  @override
  State<ChallengeNotification> createState() => _ChallengeNotificationState();
}

class _ChallengeNotificationState extends State<ChallengeNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 启动动画
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主要通知卡片
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: _buildNotificationCard(),
                ),
                
                const SizedBox(height: 32),
                
                // 操作按钮
                _buildActionButtons(),
                
                const SizedBox(height: 16),
                
                // 查看详情按钮
                _buildDetailButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部装饰
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLarge),
                topRight: Radius.circular(AppSpacing.radiusLarge),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // 挑战图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B6FED), Color(0xFF8B9BF3)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5B6FED).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.challenge.recipeIcon,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 挑战标题
                Text(
                  '新挑战来了！',
                  style: AppTypography.titleLargeStyle(isDark: false).copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // 菜谱名称
                Text(
                  widget.challenge.recipeName,
                  style: AppTypography.titleMediumStyle(isDark: false).copyWith(
                    color: Color(0xFF5B6FED),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // 挑战消息
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Text(
                    widget.challenge.message,
                    style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 挑战信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(
                      icon: Icons.timer,
                      label: '预估时间',
                      value: '${widget.challenge.estimatedTime}分钟',
                    ),
                    
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.backgroundSecondary,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    
                    _buildInfoItem(
                      icon: Icons.star,
                      label: '难度',
                      value: widget.challenge.difficultyText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.captionStyle(isDark: false).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmallStyle(isDark: false).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 拒绝按钮
        Expanded(
          child: _buildActionButton(
            text: '拒绝',
            color: AppColors.textSecondary,
            backgroundColor: AppColors.backgroundColor,
            onTap: () {
              HapticFeedback.lightImpact();
              _slideController.reverse().then((_) {
                widget.onReject();
              });
            },
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 接受按钮
        Expanded(
          child: _buildActionButton(
            text: '接受挑战',
            color: Colors.white,
            backgroundColor: Color(0xFF5B6FED),
            onTap: () {
              HapticFeedback.mediumImpact();
              _slideController.reverse().then((_) {
                widget.onAccept();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: backgroundColor == AppColors.backgroundColor
              ? Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 1,
                )
              : null,
          boxShadow: backgroundColor != AppColors.backgroundColor
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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

  Widget _buildDetailButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _slideController.reverse().then((_) {
          widget.onViewDetail();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              '查看详情',
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}