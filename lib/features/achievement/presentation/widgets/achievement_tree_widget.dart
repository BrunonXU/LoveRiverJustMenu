import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../domain/models/achievement.dart';

/// 3D成就成长树组件
class AchievementTreeWidget extends StatefulWidget {
  final List<Achievement> achievements;

  const AchievementTreeWidget({
    super.key,
    required this.achievements,
  });

  @override
  State<AchievementTreeWidget> createState() => _AchievementTreeWidgetState();
}

class _AchievementTreeWidgetState extends State<AchievementTreeWidget>
    with TickerProviderStateMixin {
  double _rotationY = 0.0;
  double _scale = 1.0;
  
  late AnimationController _rotationController;
  late AnimationController _breathingController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30), // 慢速旋转
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 启动动画
    _rotationController.repeat();
    _breathingController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _breathingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount == 1) {
            _rotationY += details.focalPointDelta.dx * 0.01;
          }
          _scale = details.scale.clamp(0.5, 2.0);
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _breathingController,
          _glowController,
        ]),
        builder: (context, child) {
          final currentRotationY = _rotationY + (_rotationController.value * 2 * math.pi);
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透视效果
              ..rotateY(currentRotationY)
              ..scale(_scale),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景光环效果
                _buildGlowEffect(),
                
                // 成长树主体
                _buildTree(),
                
                // 成就节点
                ..._buildAchievementNodes(),
                
                // 连接线
                ..._buildConnections(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_glowController.value * 0.2);
        
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(glowIntensity),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTree() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        final breathingScale = 1.0 + (_breathingController.value * 0.03);
        
        return Transform.scale(
          scale: breathingScale,
          child: Container(
            width: 12,
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.6),
                  AppColors.primary.withOpacity(0.8),
                  const Color(0xFF8B4513), // 树干色
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAchievementNodes() {
    final nodes = <Widget>[];
    final unlockedAchievements = widget.achievements.where((a) => a.isUnlocked).toList();
    final nearCompleteAchievements = widget.achievements.where((a) => a.isNearComplete && !a.isUnlocked).toList();
    
    // 已解锁成就 - 在树上发光
    for (int i = 0; i < unlockedAchievements.length && i < 12; i++) {
      final achievement = unlockedAchievements[i];
      final position = _calculateNodePosition(i, unlockedAchievements.length, true);
      
      nodes.add(_buildAchievementNode(
        achievement,
        position,
        isUnlocked: true,
      ));
    }
    
    // 接近完成的成就 - 在树周围闪烁
    for (int i = 0; i < nearCompleteAchievements.length && i < 6; i++) {
      final achievement = nearCompleteAchievements[i];
      final angle = (i / 6) * 2 * math.pi;
      final radius = 120.0;
      final x = math.sin(angle) * radius;
      final y = math.cos(angle) * radius * 0.5; // 椭圆形分布
      
      nodes.add(_buildAchievementNode(
        achievement,
        Offset(x, y),
        isUnlocked: false,
        isPulsing: true,
      ));
    }
    
    return nodes;
  }

  Widget _buildAchievementNode(
    Achievement achievement,
    Offset position, {
    bool isUnlocked = false,
    bool isPulsing = false,
  }) {
    Widget node = Container(
      width: isUnlocked ? 50 : 40,
      height: isUnlocked ? 50 : 40,
      decoration: BoxDecoration(
        color: isUnlocked 
            ? achievement.levelColor.withOpacity(0.9)
            : AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked 
              ? achievement.levelColor
              : AppColors.textSecondary.withOpacity(0.3),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: achievement.levelColor.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          achievement.emoji,
          style: TextStyle(
            fontSize: isUnlocked ? 24 : 18,
            color: isUnlocked ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
    
    // 添加脉冲动画
    if (isPulsing) {
      node = AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final pulseScale = 1.0 + (_breathingController.value * 0.1);
          return Transform.scale(
            scale: pulseScale,
            child: node,
          );
        },
      );
    }
    
    // 添加呼吸动画（已解锁）
    if (isUnlocked) {
      node = AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final breathingOpacity = 0.8 + (_breathingController.value * 0.2);
          return Opacity(
            opacity: breathingOpacity,
            child: node,
          );
        },
      );
    }
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => _showAchievementTooltip(achievement),
        child: node,
      ),
    );
  }

  Offset _calculateNodePosition(int index, int total, bool isUnlocked) {
    if (!isUnlocked) return Offset.zero;
    
    // 螺旋分布在树上
    final levels = [
      [-100, -80, -60, -40], // 树的不同高度层级
      [-20, 0, 20, 40],
      [60, 80, 100, 120],
    ];
    
    final levelIndex = (index / 4).floor() % levels.length;
    final positionIndex = index % 4;
    final level = levels[levelIndex];
    
    if (positionIndex < level.length) {
      final y = level[positionIndex].toDouble();
      final x = (positionIndex % 2 == 0 ? -1 : 1) * (30 + (levelIndex * 10)).toDouble();
      return Offset(x, y);
    }
    
    return Offset.zero;
  }

  List<Widget> _buildConnections() {
    // TODO: 实现成就节点之间的连接线
    // 这里可以添加从树干到各个成就节点的连接线动画
    return [];
  }

  void _showAchievementTooltip(Achievement achievement) {
    HapticFeedback.lightImpact();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 50,
        top: position.dy + 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(
                color: achievement.isUnlocked 
                    ? achievement.levelColor.withOpacity(0.3)
                    : AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Space.w8,
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: AppTypography.bodyMediumStyle(isDark: false).copyWith(
                          fontWeight: FontWeight.w500,
                          color: achievement.isUnlocked 
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                Space.h8,
                
                Text(
                  achievement.description,
                  style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                
                if (!achievement.isUnlocked) ...[
                  Space.h8,
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor: AppColors.backgroundSecondary,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                      Space.w8,
                      Text(
                        '${(achievement.progress * 100).round()}%',
                        style: AppTypography.captionStyle(isDark: false).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (achievement.isUnlocked) ...[
                  Space.h8,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: achievement.levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Text(
                      '${achievement.levelName} • +${achievement.points}积分',
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: achievement.levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // 3秒后自动移除
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}