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
  late Animation<double> _rotationAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // 使用CurvedAnimation优化性能
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    );
    
    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );
    
    // 延迟启动动画，避免页面加载时卡顿
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rotationController.repeat();
        _breathingController.repeat(reverse: true);
      }
    });
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
            child: RepaintBoundary( // 隔离动画区域
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
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rotationAnimation, _breathingAnimation]),
                  builder: (context, child) {
                    final currentRotationY = _rotationY + (_rotationAnimation.value * 2 * math.pi);
                    
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(currentRotationY)
                        ..scale(_scale),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none, // 避免裁剪问题
                        children: widget.memories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final memory = entry.value;
                          return _build3DMemoryCard(memory, index, _breathingAnimation.value);
                        }).toList(),
                      ),
                    );
                  },
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
  
  Widget _build3DMemoryCard(Memory memory, int index, double breathingValue) {
    final totalMemories = widget.memories.length;
    final angle = (index / totalMemories) * 2 * math.pi;
    final radius = 150.0;
    final x = math.sin(angle) * radius;
    final z = math.cos(angle) * radius;
    final y = index * 50.0 - 100;
    
    // 计算呼吸动画值
    final breathingScale = 1.0 + (breathingValue * 0.05);
    final breathingOpacity = 0.8 + (breathingValue * 0.2);
    
    // 固定卡片尺寸，避免LayoutBuilder
    const cardWidth = 160.0;
    const cardHeight = 240.0;
    
    return RepaintBoundary(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(x, y, z)
          ..rotateY(-angle)
          ..scale(breathingScale),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            widget.onMemoryTap?.call(memory);
            HapticFeedback.mediumImpact();
          },
          child: Opacity(
            opacity: breathingOpacity,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: memory.special 
                      ? AppColors.primary.withOpacity(0.3 * breathingOpacity)
                      : AppColors.shadow.withOpacity(breathingOpacity),
                    blurRadius: memory.special ? 16 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: memory.special ? 2 : 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji图标
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        memory.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 标题
                  Flexible(
                    flex: 2,
                    child: Text(
                      memory.title,
                      style: AppTypography.bodyMediumStyle(
                        isDark: false,
                      ).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                      
                      const SizedBox(height: 6),
                      
                  // 日期
                  Text(
                    _formatDate(memory.date),
                    style: AppTypography.captionStyle(
                      isDark: false,
                    ).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // 情绪标签
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
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
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              // 🔥 修复：使用正确的暂停/恢复逻辑
              if (_rotationController.isAnimating) {
                _rotationController.stop(); // 完全停止
              } else {
                _rotationController.repeat(); // 重新开始循环
              }
              HapticFeedback.lightImpact();
              setState(() {}); // 更新按钮图标
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