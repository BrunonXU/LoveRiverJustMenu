import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/themes/spacing.dart';
import '../../../../core/themes/typography.dart';
import '../../domain/models/memory.dart';

/// 3D时光机组件
/// 严格遵循95%黑白灰设计原则，呼吸动画和手势识别
class Timeline3DWidget extends StatefulWidget {
  final List<Memory> memories;
  final Function(Memory memory)? onMemoryTap;
  
  const Timeline3DWidget({
    super.key,
    required this.memories,
    this.onMemoryTap,
  });

  @override
  State<Timeline3DWidget> createState() => _Timeline3DWidgetState();
}

class _Timeline3DWidgetState extends State<Timeline3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _breathingController;
  double _rotationY = 0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    // 呼吸动画：4s循环，符合设计规范
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 95%使用黑白灰背景
        color: AppColors.backgroundColor,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 标题 - 使用设计系统
            Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                '美食时光机',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w100, // 超轻字重
                ),
              ),
            ),
            
            Space.h32,
            
            // 3D时间轴
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _rotationY += details.delta.dx * 0.01;
                  });
                  HapticFeedback.lightImpact();
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = details.scale.clamp(0.5, 2.0);
                  });
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 透视效果
                    ..rotateY(_rotationY)
                    ..scale(_scale),
                  child: Stack(
                    alignment: Alignment.center,
                    children: widget.memories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final memory = entry.value;
                      return _build3DMemoryCard(memory, index);
                    }).toList(),
                  ),
                ),
              ),
            ),
            
            Space.h32,
            
            // 极简控制按钮
            _buildMinimalControls(),
            
            Space.h48,
          ],
        ),
      ),
    );
  }
  
  Widget _build3DMemoryCard(Memory memory, int index) {
    // 螺旋布局算法
    final angle = (index / widget.memories.length) * 2 * math.pi;
    final radius = AppSpacing.magneticRadius; // 使用设计系统中的150px
    final x = math.sin(angle) * radius;
    final z = math.cos(angle) * radius;
    final y = index * 50.0 - 100;
    
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        // 呼吸动画：微妙的浮动效果
        final breathingOffset = math.sin(_breathingController.value * math.pi) * 8;
        final breathingScale = 1.0 + (_breathingController.value * AppSpacing.breathingScale);
        
        return Transform(
          transform: Matrix4.identity()
            ..translate(x, y + breathingOffset, z)
            ..rotateY(-angle)
            ..scale(breathingScale),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              widget.onMemoryTap?.call(memory);
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                // 95%黑白灰 + 5%彩色焦点设计
                color: memory.special 
                  ? AppColors.backgroundColor
                  : AppColors.backgroundSecondary,
                gradient: memory.special 
                  ? AppColors.primaryGradient // 5%彩色焦点
                  : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(false),
                    blurRadius: AppSpacing.shadowBlurRadius,
                    offset: AppSpacing.shadowOffset,
                    spreadRadius: memory.special ? 2 : 0,
                  ),
                ],
              ),
              padding: AppSpacing.cardContentPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji图标
                  Text(
                    memory.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  
                  Space.h16,
                  
                  // 标题 - 使用设计系统
                  Text(
                    memory.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: memory.special 
                        ? Colors.white 
                        : AppColors.textPrimary,
                      fontWeight: FontWeight.w300, // 轻字重
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  Space.h8,
                  
                  // 日期
                  Text(
                    _formatDate(memory.date),
                    style: AppTypography.bodySmall.copyWith(
                      color: memory.special 
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textSecondary,
                    ),
                  ),
                  
                  Space.h8,
                  
                  // 情绪标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: memory.special 
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Text(
                      memory.mood,
                      style: AppTypography.caption.copyWith(
                        color: memory.special 
                          ? Colors.white
                          : AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMinimalControls() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMinimalButton(
            icon: Icons.chevron_left,
            onTap: () {
              setState(() {
                _rotationY -= math.pi / 3;
              });
              HapticFeedback.lightImpact();
            },
          ),
          
          Space.w48,
          
          _buildMinimalButton(
            icon: _rotationController.isAnimating ? Icons.pause : Icons.play_arrow,
            onTap: () {
              if (_rotationController.isAnimating) {
                _rotationController.stop();
              } else {
                _rotationController.repeat();
              }
              HapticFeedback.lightImpact();
            },
          ),
          
          Space.w48,
          
          _buildMinimalButton(
            icon: Icons.chevron_right,
            onTap: () {
              setState(() {
                _rotationY += math.pi / 3;
              });
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMinimalButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final breathingScale = 1.0 + (_breathingController.value * 0.01);
          
          return Transform.scale(
            scale: breathingScale,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getShadowColor(false),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}