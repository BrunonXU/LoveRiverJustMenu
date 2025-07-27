import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/typography.dart';
import '../../../../core/themes/spacing.dart';
import '../../domain/models/memory.dart';

/// 3D时光机组件 - 响应式版本
/// 修复全屏模式显示问题，恢复旋转动画
class Timeline3DWidget extends StatefulWidget {
  final List<Memory> memories;
  final Function(Memory)? onMemoryTap;

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
  double _rotationY = 0.0;
  double _scale = 1.0;
  
  late AnimationController _rotationController;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    // 监听旋转动画值变化
    _rotationController.addListener(() {
      setState(() {
        _rotationY = _rotationController.value * 2 * math.pi;
      });
    });
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
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
        color: AppColors.backgroundColor,
      ),
      child: Column(
        children: [
          // 3D时间轴
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (details) {
                setState(() {
                  if (details.pointerCount == 1) {
                    _rotationY += details.focalPointDelta.dx * 0.01;
                  }
                  _scale = details.scale.clamp(0.5, 2.0);
                });
                HapticFeedback.lightImpact();
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
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
          
          const SizedBox(height: 24),
          
          // 控制按钮
          _buildMinimalControls(),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }
  
  Widget _build3DMemoryCard(Memory memory, int index) {
    final totalMemories = widget.memories.length;
    final angle = (index / totalMemories) * 2 * math.pi;
    final radius = 150.0;
    final x = math.sin(angle) * radius;
    final z = math.cos(angle) * radius;
    final y = index * 50.0 - 100;
    
    return RepaintBoundary(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(x, y, z)
          ..rotateY(-angle),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            widget.onMemoryTap?.call(memory);
            HapticFeedback.mediumImpact();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 响应式尺寸，适配全屏模式
              final cardWidth = (constraints.maxWidth * 0.15).clamp(120.0, 200.0);
              final cardHeight = (constraints.maxHeight * 0.25).clamp(180.0, 280.0);
              
              return Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: memory.special 
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.shadow,
                      blurRadius: memory.special ? 16 : 8,
                      offset: const Offset(0, 4),
                      spreadRadius: memory.special ? 2 : 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji图标
                      Text(
                        memory.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 标题
                      Text(
                        memory.title,
                        style: AppTypography.titleMediumStyle(
                          isDark: false,
                        ).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // 日期
                      Text(
                        _formatDate(memory.date),
                        style: AppTypography.bodySmallStyle(
                          isDark: false,
                        ).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // 情绪标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          memory.mood,
                          style: AppTypography.captionStyle(
                            isDark: false,
                          ).copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildMinimalControls() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMinimalButton(
            icon: Icons.remove,
            onTap: () {
              setState(() {
                _scale = (_scale - 0.1).clamp(0.5, 2.0);
              });
              HapticFeedback.lightImpact();
            },
          ),
          
          const SizedBox(width: 48),
          
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
          
          const SizedBox(width: 48),
          
          _buildMinimalButton(
            icon: Icons.add,
            onTap: () {
              setState(() {
                _scale = (_scale + 0.1).clamp(0.5, 2.0);
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
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
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
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}