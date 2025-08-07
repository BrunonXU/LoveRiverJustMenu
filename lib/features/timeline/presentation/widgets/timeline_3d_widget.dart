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
  
  // 两周分组相关状态
  int _currentPeriodIndex = 0;
  List<List<Memory>> _memoryPeriods = [];
  List<String> _periodLabels = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _groupMemoriesByPeriod();
  }
  
  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30), // 减慢旋转速度，更优雅
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
  
  /// 按两周分组Memory数据
  void _groupMemoriesByPeriod() {
    _memoryPeriods.clear();
    _periodLabels.clear();
    
    if (widget.memories.isEmpty) return;
    
    // 按日期排序
    final sortedMemories = List<Memory>.from(widget.memories)
      ..sort((a, b) => b.date.compareTo(a.date)); // 最新的在前
    
    final Map<String, List<Memory>> periodMap = {};
    
    for (final memory in sortedMemories) {
      final periodStart = _getTwoWeekPeriodStart(memory.date);
      final periodEnd = periodStart.add(const Duration(days: 13));
      final periodKey = '${_formatDate(periodStart)} - ${_formatDate(periodEnd)}';
      
      periodMap[periodKey] ??= [];
      periodMap[periodKey]!.add(memory);
    }
    
    // 转换为列表，最新的期间在前
    final sortedPeriods = periodMap.entries.toList()
      ..sort((a, b) {
        // 根据第一个记忆的日期排序
        final aDate = a.value.first.date;
        final bDate = b.value.first.date;
        return bDate.compareTo(aDate);
      });
    
    _periodLabels = sortedPeriods.map((e) => e.key).toList();
    _memoryPeriods = sortedPeriods.map((e) => e.value).toList();
    
    // 默认显示最新的时间段
    _currentPeriodIndex = 0;
  }
  
  /// 获取两周期间的开始日期（每月1号和15号）
  DateTime _getTwoWeekPeriodStart(DateTime date) {
    if (date.day <= 15) {
      return DateTime(date.year, date.month, 1);
    } else {
      return DateTime(date.year, date.month, 15);
    }
  }
  
  /// 格式化日期显示
  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
  
  /// 获取当前时间段的记忆
  List<Memory> _getCurrentPeriodMemories() {
    if (_memoryPeriods.isEmpty || _currentPeriodIndex >= _memoryPeriods.length) {
      return [];
    }
    return _memoryPeriods[_currentPeriodIndex];
  }
  
  /// 切换到上一个时间段
  void _goToPreviousPeriod() {
    if (_currentPeriodIndex > 0) {
      setState(() {
        _currentPeriodIndex--;
      });
      HapticFeedback.lightImpact();
    }
  }
  
  /// 切换到下一个时间段
  void _goToNextPeriod() {
    if (_currentPeriodIndex < _memoryPeriods.length - 1) {
      setState(() {
        _currentPeriodIndex++;
      });
      HapticFeedback.lightImpact();
    }
  }
  
  /// 获取当前时间段标签
  String _getCurrentPeriodLabel() {
    if (_periodLabels.isEmpty || _currentPeriodIndex >= _periodLabels.length) {
      return '暂无记忆';
    }
    return _periodLabels[_currentPeriodIndex];
  }
  
  /// 构建3D卡片并正确排序（全新的圆形3D布局）
  List<Widget> _build3DCards() {
    final memories = _getCurrentPeriodMemories();
    if (memories.isEmpty) return [];
    
    final cardData = <Map<String, dynamic>>[];
    const double radius = 250.0; // 进一步增大半径，让卡片分布更开阔
    
    for (int i = 0; i < memories.length; i++) {
      final memory = memories[i];
      
      // 计算圆形3D位置
      final angle = (i / memories.length) * 2 * math.pi + (_rotationY + _rotationAnimation.value * 2 * math.pi);
      final x = math.sin(angle) * radius;
      final z = math.cos(angle) * radius;
      final y = 0.0; // 所有卡片在同一水平面上
      
      // 计算卡片朝向（始终面向中心）
      final cardRotationY = angle + math.pi;
      
      cardData.add({
        'memory': memory,
        'index': i,
        'x': x,
        'y': y,
        'z': z,
        'angle': angle,
        'cardRotationY': cardRotationY,
        'opacity': _calculateDepthOpacity(z),
        'scale': _calculateDepthScale(z),
      });
    }
    
    // 按z值排序，后面的先渲染
    cardData.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));
    
    return cardData.map((data) => _build3DMemoryCard(data)).toList();
  }
  
  /// 根据深度计算透明度
  double _calculateDepthOpacity(double z) {
    const double maxZ = 250.0; // 与半径保持一致
    const double minOpacity = 0.4; // 提高最小透明度，确保后面卡片依然可见
    const double maxOpacity = 1.0;
    
    // z值范围：-250到250，映射到透明度0.4-1.0
    final normalizedZ = (z + maxZ) / (2 * maxZ);
    return minOpacity + (maxOpacity - minOpacity) * normalizedZ;
  }
  
  /// 根据深度计算缩放比例
  double _calculateDepthScale(double z) {
    const double maxZ = 250.0; // 与半径保持一致
    const double minScale = 0.7; // 提高最小缩放，减少过小的卡片
    const double maxScale = 1.0;
    
    // 近大远小的透视效果
    final normalizedZ = (z + maxZ) / (2 * maxZ);
    return minScale + (maxScale - minScale) * normalizedZ;
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
          // 时间段指示器
          _buildPeriodIndicator(),
          
          const SizedBox(height: 16),
          
          // 3D时间轴
          Expanded(
            child: RepaintBoundary( // 隔离动画区域
              child: GestureDetector(
                onScaleUpdate: (details) {
                  setState(() {
                    if (details.pointerCount == 1) {
                      _rotationY += details.focalPointDelta.dx * 0.008; // 降低手势敏感度
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
                        ..setEntry(3, 2, 0.001) // 恢复原始透视效果
                        ..rotateY(currentRotationY)
                        ..scale(_scale),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none, // 避免裁剪问题
                        children: _build3DCards(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 时间段切换控制
          _buildPeriodControls(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  /// 构建3D记忆卡片（全新设计，简洁高效）
  Widget _build3DMemoryCard(Map<String, dynamic> cardData) {
    final memory = cardData['memory'] as Memory;
    final x = cardData['x'] as double;
    final y = cardData['y'] as double;
    final z = cardData['z'] as double;
    final cardRotationY = cardData['cardRotationY'] as double;
    final opacity = cardData['opacity'] as double;
    final scale = cardData['scale'] as double;
    
    // 应用呼吸动画 - 更轻微的效果
    final breathingScale = scale * (1.0 + _breathingAnimation.value * 0.02);
    final finalOpacity = opacity * (0.85 + _breathingAnimation.value * 0.15);
    
    return RepaintBoundary(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 设置透视
          ..translate(x, y, z)
          ..rotateY(cardRotationY)
          ..scale(breathingScale),
        alignment: Alignment.center,
        child: Opacity(
          opacity: finalOpacity,
          child: GestureDetector(
            onTap: () {
              widget.onMemoryTap?.call(memory);
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: 140,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: memory.special 
                        ? AppColors.primary.withAlpha((0.4 * finalOpacity * 255).round())
                        : Colors.black.withAlpha((0.1 * finalOpacity * 255).round()),
                    blurRadius: memory.special ? 20 : 10,
                    offset: const Offset(0, 8),
                    spreadRadius: memory.special ? 2 : 0,
                  ),
                  if (memory.special)
                    BoxShadow(
                      color: AppColors.primary.withAlpha((0.2 * finalOpacity * 255).round()),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: -5,
                    ),
                ],
                border: memory.special
                    ? Border.all(
                        color: AppColors.primary.withAlpha(77), // 0.3 * 255
                        width: 1,
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji图标
                  Text(
                    memory.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 标题
                  Text(
                    memory.title,
                    style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 日期
                  Text(
                    '${memory.date.month}/${memory.date.day}',
                    style: AppTypography.captionStyle(isDark: false).copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // 情绪标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: memory.special 
                          ? AppColors.primary.withAlpha(26) // 0.1 * 255
                          : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      memory.mood,
                      style: AppTypography.captionStyle(isDark: false).copyWith(
                        color: memory.special ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
  
  /// 构建时间段指示器
  Widget _buildPeriodIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            _getCurrentPeriodLabel(),
            style: AppTypography.titleMediumStyle(isDark: false).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w300,
            ),
          ),
          if (_memoryPeriods.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_getCurrentPeriodMemories().length} 个美食记忆',
              style: AppTypography.bodySmallStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 构建时间段切换控制
  Widget _buildPeriodControls() {
    if (_memoryPeriods.length <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上一个时间段
          _buildPeriodButton(
            icon: Icons.chevron_left,
            label: '上一期',
            onTap: _currentPeriodIndex > 0 ? _goToPreviousPeriod : null,
          ),
          
          // 时间段指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPeriodIndex + 1} / ${_memoryPeriods.length}',
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 下一个时间段
          _buildPeriodButton(
            icon: Icons.chevron_right,
            label: '下一期',
            onTap: _currentPeriodIndex < _memoryPeriods.length - 1 ? _goToNextPeriod : null,
          ),
        ],
      ),
    );
  }
  
  /// 构建时间段切换按钮
  Widget _buildPeriodButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled 
              ? AppColors.backgroundSecondary 
              : AppColors.backgroundSecondary.withAlpha(128), // 0.5 * 255
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.captionStyle(isDark: false).copyWith(
                color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}